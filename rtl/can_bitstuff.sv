module can_bit_stuffer (
    input  logic clk,
    input  logic rst_n,
    input  logic reset_mode,
    input  logic sample_point,
    input   logic bit_start_point,
    input  logic bit_stuffing_en,      // enable from your main TX module
    input  logic tx_frame_tx_bit,      // raw bit from TX FSM
    output logic stuffed_tx_bit,       // output bit after stuffing
    output logic insert_stuff_bit      // pulse
);
    logic [2:0] bit_stuff_counter_ff, bit_stuff_counter_next;
    logic       tx_bit_curr, tx_bit_prev, tx_bit_next;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bit_stuff_counter_ff <= 3'h1;
        else
            bit_stuff_counter_ff <= bit_stuff_counter_next;
    end
    always_comb begin
        bit_stuff_counter_next = bit_stuff_counter_ff;

        if (reset_mode) begin
            bit_stuff_counter_next = 3'h1;
        end else if (sample_point & bit_stuffing_en) begin    
            if (bit_stuff_counter_ff == 3'h5)
                bit_stuff_counter_next = 3'h1;
            else if (tx_bit_curr == tx_bit_prev)
                bit_stuff_counter_next = bit_stuff_counter_ff + 1'b1;
            else
                bit_stuff_counter_next = 3'h1;
        end
    end
    assign insert_stuff_bit = (bit_stuff_counter_ff == 3'h5);
    always_comb begin
        if (insert_stuff_bit & bit_stuff_counter_ff == 3'h5)
            tx_bit_next = ~tx_bit_prev; 

        else
            tx_bit_next = tx_frame_tx_bit;     
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            tx_bit_curr <= 1'b1;
        else if (reset_mode)
            tx_bit_curr <= 1'b1;
        else if (sample_point)
            tx_bit_curr <= tx_bit_next;
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            tx_bit_prev <= 1'b1;
        else if (reset_mode)
            tx_bit_prev <= 1'b1;
        else if (sample_point)
            tx_bit_prev <= tx_bit_curr;
    end
    assign stuffed_tx_bit = tx_bit_curr;

endmodule
