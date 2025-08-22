module can_error_handling (
    input  logic clk,
    input  logic rst,
    input  logic rx_bit,          
    input  logic tx_bit,          
    input  logic tx_active,       
    input  logic sample_point,    

    // For stuff error detection
    input  logic bit_de_stuffing_ff,
    input  logic remove_stuff_bit,
    input  logic rx_bit_curr,
    input  logic rx_bit_prev,

    // For bit error exceptions
    input  logic in_arbitration,
    input  logic in_ack_slot,

    // For form error
    input logic in_crc_delimiter,
    input logic in_ack_delimiter,
    input logic in_eof,

    // For CRC error
    input  logic crc_check_done,
    input  logic crc_rx_valid,
    input  logic crc_rx_match,
    input  logic overload_request,
    input logic  dominant_after_flag,

    output logic bit_error,
    output logic stuff_error,
    output logic crc_error,
    output logic form_error,
    output logic ack_error,
    output logic [7:0] tec,
    output logic [7:0] rec,
    output logic error_active,
    output logic error_passive,
    output logic bus_off
);

//  STUFF ERROR 
assign stuff_error = sample_point & bit_de_stuffing_ff & remove_stuff_bit & (rx_bit_curr == rx_bit_prev) & ~(in_arbitration);

// BIT ERROR
assign bit_error = sample_point & tx_active & 
    (tx_bit != rx_bit) & ~((tx_bit == 1'b1) && (rx_bit == 1'b0) && (in_arbitration || in_ack_slot || error_passive));

// ACK ERROR
assign ack_error = sample_point & tx_active & in_ack_slot & (rx_bit == 1'b1);

// FORM ERROR
assign form_error = sample_point & !rx_bit & (in_crc_delimiter || in_ack_delimiter || in_eof);

// CRC ERROR
assign crc_error = crc_check_done & crc_rx_valid & ~crc_rx_match;

// Track previous error conditions for single increment
logic prev_tx_error, prev_rx_error;
logic tx_error, rx_error;
logic rx_bitprev;
logic flag_fourteen;
logic [3:0] dominant_count;          // counts consecutive dominant bits

assign tx_error = tx_active && (bit_error || form_error || ack_error);
assign rx_error = !tx_active && (bit_error ||form_error || stuff_error || crc_error);

// Successful transmission: tx_active ends without error
logic success_tx, success_rx;
assign success_tx = sample_point & tx_active & !(bit_error || form_error || ack_error);
assign success_rx = sample_point & !tx_active & !(bit_error ||form_error || stuff_error || crc_error);

always_ff @(posedge clk or negedge rst )begin
    if(!rst)begin
        rx_bitprev <= 1;
    end else begin
        rx_bitprev <= rx_bit;
    end
end

// Dominant Bit Logic
always_ff @(posedge clk or negedge rst)begin
    if(!rst)begin
        dominant_count <=1;
        flag_fourteen <=0;
    end else if(rx_bitprev==0 && rx_bit ==0)begin
         dominant_count <= dominant_count + 1;
         if (dominant_count==14)begin
            flag_fourteen <=1;
            dominant_count <= 0;
         end 
    end else if(rx_bit==1)begin
             flag_fourteen <=0;
             dominant_count <=1;
    end
end

always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        tec <= 8'd0;
        rec <= 8'd0;
        prev_tx_error <= 1'b0;
        prev_rx_error <= 1'b0;
    end else begin

        // Default: hold values
        tec <= tec;
        rec <= rec;

        // --- TEC/REC update priority ---
        if (dominant_count==14 || (flag_fourteen && dominant_count==8)) begin
            // Special dominant bit sequence → both counters +8
            tec <= (tec <= 8'd247) ? tec + 8 : 8'd255;
            rec <= (rec <= 8'd247) ? rec + 8 : 8'd255;

        end else if (tx_error && !prev_tx_error) begin
            // Transmit error → TEC +8 (except passive + ack error)
            if (!(error_passive && ack_error))
                tec <= (tec <= 8'd247) ? tec + 8 : 8'd255;

        end else if (rx_error && !prev_rx_error) begin
            // Receive error → REC +1
            if (!(bit_error && error_active))
                rec <= (rec < 8'd255) ? rec + 1 : 8'd255;

        end else if (dominant_after_flag) begin
            // Dominant after error flag → REC +8
            rec <= (rec <= 8'd247) ? rec + 8 : 8'd255;

        end else if (success_tx && tec > 0) begin
            // Successful TX frame → TEC –1
            tec <= tec - 1;

        end else if (success_rx && rec > 0) begin
            // Successful RX frame → REC –1
            rec <= rec - 1;
        end

        // Latch previous error state
        prev_tx_error <= tx_error;
        prev_rx_error <= rx_error;
    end
end

    
// ERROR STATE LOGIC
always_comb begin
    if (tec >= 8'd255) begin
        bus_off       = 1'b1;
        error_passive = 1'b0;
        error_active  = 1'b0;
    end else if ((tec >= 8'd128) || (rec >= 8'd128)) begin
        bus_off       = 1'b0;
        error_passive = 1'b1;
        error_active  = 1'b0;
    end else begin
        bus_off       = 1'b0;
        error_passive = 1'b0;
        error_active  = 1'b1;
    end
end

endmodule
