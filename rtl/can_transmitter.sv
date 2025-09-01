`include "can_defs.svh"
`timescale 1ns / 10ps

module can_transmitter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        sample_point,
    input  logic        start_tx,

    input  logic [7:0]  tx_data_0,
    input  logic [7:0]  tx_data_1,
    input  logic [7:0]  tx_data_2,
    input  logic [7:0]  tx_data_3,
    input  logic [7:0]  tx_data_4,
    input  logic [7:0]  tx_data_5,
    input  logic [7:0]  tx_data_6,
    input  logic [7:0]  tx_data_7,
    input  logic [7:0]  tx_data_8,
    input  logic [7:0]  tx_data_9,

    output logic        tx_bit,
    output logic        tx_done,
    output logic        rd_tx_data_byte,
    output logic        arbitration_active
);

    
    can_frame_t tx_frame_local;
    logic [14:0] calculated_crc; // Placeholder – implement separately
    logic       tx_remote_req;
    
    assign tx_frame_local.ide    = 1'b0; 
    assign tx_frame_local.id_std = {tx_data_0, tx_data_1[7:5]};
    assign tx_frame_local.id_ext = {tx_data_2, tx_data_3, tx_data_1[4:0]};
    assign tx_frame_local.rtr1   = tx_data_1[4];
    assign tx_frame_local.dlc    = tx_data_1[3:0];
    assign tx_frame_local.crc    = calculated_crc;
    assign tx_remote_req = (~(tx_frame_local.ide) & tx_frame_local.rtr1) | (tx_frame_local.ide & tx_frame_local.rtr2) | (~(|tx_frame_local.dlc));

    
    logic [7:0] tx_data_array [0:7];
    assign tx_data_array[0] = tx_data_2;
    assign tx_data_array[1] = tx_data_3;
    assign tx_data_array[2] = tx_data_4;
    assign tx_data_array[3] = tx_data_5;
    assign tx_data_array[4] = tx_data_6;
    assign tx_data_array[5] = tx_data_7;
    assign tx_data_array[6] = tx_data_8;
    assign tx_data_array[7] = tx_data_9;


    type_can_frame_states_e tx_state_ff, tx_state_next;
    logic [5:0] tx_bit_cnt_ff, tx_bit_cnt_next;
    logic [3:0] tx_byte_cnt_ff, tx_byte_cnt_next;
    logic [7:0] tx_data_byte_ff, tx_data_byte_next;
    logic       bit_stuffing_ff, bit_stuffing_next;
    logic       tx_frame_tx_bit;
    

    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_byte_cnt_ff  <= '0;
            tx_data_byte_ff <= '0;
        end else if (sample_point) begin
            if (rd_tx_data_byte) begin
                tx_data_byte_ff <= tx_data_array[tx_byte_cnt_next];
                tx_byte_cnt_ff  <= tx_byte_cnt_next;
            end else begin
                tx_data_byte_ff <= tx_data_byte_next;
            end
        end
    end

    // FSM Sequential Block
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            tx_state_ff <= STATE_IDLE; 
            tx_bit_cnt_ff <= '0; 
        end 
        else if (sample_point) begin 
            tx_state_ff <= tx_state_next; 
            tx_bit_cnt_ff <= tx_bit_cnt_next; 
            bit_stuffing_ff <= bit_stuffing_next;

        end 
    end

    // FSM Combinational Block
    always_comb begin
        tx_bit_cnt_next   = tx_bit_cnt_ff;
        tx_byte_cnt_next  = tx_byte_cnt_ff;
        tx_data_byte_next = tx_data_byte_ff;
        tx_state_next     = tx_state_ff;
        tx_frame_tx_bit   = 1'b1;
        tx_done           = 1'b0;
        arbitration_active = 1'b0;
        bit_stuffing_next = 1'b0;
        bit_stuffing_next = bit_stuffing_ff;
        rd_tx_data_byte   = 1'b0;

        case (tx_state_ff)
            STATE_IDLE: begin
                bit_stuffing_next = 1'b0;
                if (start_tx) begin
                    tx_frame_tx_bit = 1'b0;
                    tx_state_next   = STATE_ID_STD;
                    tx_bit_cnt_next = 10;
                    arbitration_active = 1'b0;
                    bit_stuffing_next = 1'b1;
                end
            end

             STATE_ID_STD: begin
                   arbitration_active = 1;
                   tx_frame_tx_bit = tx_frame_local.id_std[tx_bit_cnt_ff];
                   if (tx_bit_cnt_ff == 0) begin
                       tx_state_next = STATE_BIT_RTR_1;
                    //   bit_cnt_next  = '0;
                   end else begin
                       tx_bit_cnt_next = tx_bit_cnt_ff - 1;
                   end
             end

             STATE_BIT_RTR_1: begin
                arbitration_active = 1;
                tx_frame_tx_bit = tx_frame_local.rtr1; 
                tx_state_next = STATE_BIT_IDE;
             end 
             STATE_BIT_IDE: begin
                arbitration_active = 1;
                tx_frame_tx_bit = tx_frame_local.ide; 
                if (tx_frame_local.ide == 1) begin
                    tx_state_next = STATE_ID_EXT;
                    tx_bit_cnt_next  = 17;
                end else begin
                    arbitration_active = 0;
                    tx_state_next = STATE_BIT_R_0;
                end
            end 
            STATE_ID_EXT: begin
                    arbitration_active = 1;
                    tx_frame_tx_bit = tx_frame_local.id_ext[tx_bit_cnt_ff];
                    if (tx_bit_cnt_ff == '0) begin
                        tx_state_next = STATE_BIT_RTR_2;
                       // tx_bit_cnt_next  = '0;
                    end else begin
                        tx_bit_cnt_next = tx_bit_cnt_ff - 1;
                    end
                
            end
             STATE_BIT_RTR_2: begin
                arbitration_active = 1;
                tx_frame_tx_bit = tx_frame_local.rtr2; 
                
                tx_state_next = STATE_BIT_R_1;
            end 
             STATE_BIT_R_1: begin
                tx_frame_tx_bit = 1'b0; 
                tx_state_next = STATE_BIT_R_0;
            end 
             STATE_BIT_R_0: begin
                tx_frame_tx_bit = 1'b0; 
                tx_state_next = STATE_DLC;
                tx_bit_cnt_next  = 3;
            end 


            STATE_DLC: begin
                tx_frame_tx_bit = tx_frame_local.dlc[tx_bit_cnt_ff];
                if (tx_bit_cnt_ff == 0) begin
                    if (tx_remote_req) begin
                        tx_state_next = STATE_CRC;
                        tx_bit_cnt_next = 14; // CRC start
                    end else begin
                        tx_state_next   = STATE_DATA;
                        tx_bit_cnt_next = '0;
                        rd_tx_data_byte = 1'b1;
                        tx_byte_cnt_next  = '0;
                    end
                end else begin
                    tx_bit_cnt_next = tx_bit_cnt_ff - 1;
                end
            end


            STATE_DATA: begin            
                tx_frame_tx_bit   = tx_data_byte_ff[7];
                tx_data_byte_next = {tx_data_byte_ff[6:0], 1'b0};
                tx_bit_cnt_next   = tx_bit_cnt_ff + 1;

                if (tx_bit_cnt_ff[2:0] == 3'd7) begin
                    tx_byte_cnt_next = tx_byte_cnt_ff + 1'b1;
                    rd_tx_data_byte  = 1'b1;
                    if (tx_bit_cnt_ff == ((tx_frame_local.dlc << 3) - 1'b1))begin
                        tx_state_next = STATE_CRC;
                        tx_byte_cnt_next = '0;                   
                        tx_bit_cnt_next  = 14;
                        rd_tx_data_byte   = 1'b0;
                    end else begin
                        rd_tx_data_byte   = 1'b1;
                    end
                end
            end

            STATE_CRC: begin
                tx_frame_tx_bit = tx_frame_local.crc[tx_bit_cnt_ff];
                if (tx_bit_cnt_ff == 0)
                    tx_state_next = STATE_CRC_DELIMIT;
                    // tx_bit_cnt_next  = '0;
                else
                    tx_bit_cnt_next = tx_bit_cnt_ff - 1;
            end

            STATE_CRC_DELIMIT: begin
                tx_frame_tx_bit = 1'b1;
                tx_state_next   = STATE_ACK;
                bit_stuffing_next = 1'b0;
            end

            STATE_ACK: begin
                tx_frame_tx_bit = 1'b1;
                tx_state_next   = STATE_ACK_DELIMIT;
            end

            STATE_ACK_DELIMIT: begin
                tx_frame_tx_bit = 1'b1;
                tx_state_next   = STATE_EOF;
                tx_bit_cnt_next = 6;
            end

            STATE_EOF: begin
                tx_frame_tx_bit = 1'b1;
                if (tx_bit_cnt_ff == '0) begin
                    tx_state_next   = STATE_IFS;
                    tx_bit_cnt_next = 2;
                end else
                    tx_bit_cnt_next = tx_bit_cnt_ff - 1;
            end

            STATE_IFS: begin
                tx_frame_tx_bit = 1'b1;
                if (tx_bit_cnt_ff == 0) begin
                    tx_done       = 1'b1;
                    tx_state_next = STATE_IDLE;

                end else
                    tx_bit_cnt_next = tx_bit_cnt_ff - 1;
            end
            default: tx_state_next = STATE_IDLE;
        endcase
    end
assign tx_bit = tx_frame_tx_bit;


endmodule
