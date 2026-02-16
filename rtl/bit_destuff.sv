// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: A SystemVerilog testbench designed to verify the functionality of the can_bit_destuffer module.
// It ensures the module correctly detects and flags the stuffed bit (6th identical bit) inserted 
// during transmission, enabling proper CAN frame de-stuffing on the receiver side.
//
// Author: M-Tahir & Nimrajavaid
// Date: 01-Aug-2025
module can_bit_de_stuffer (
    input  logic clk,
    input  logic rst_n,
    input  logic reset_mode,          
    input  logic bit_start_point,      
    input  logic rx_bit_curr,          
    input  logic rx_bit_prev,          
    input  logic bit_de_stuffing_en,   
    output logic remove_stuff_bit      
);
    logic       bit_de_stuffing_ff;
    logic       bit_de_stuffing_next;
    logic [2:0] bit_de_stuff_counter_ff;
    logic [2:0] bit_de_stuff_counter_next;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bit_de_stuffing_ff <= 1'b0;
        else
            bit_de_stuffing_ff <= bit_de_stuffing_next;
    end
    always_comb begin
        bit_de_stuffing_next = bit_de_stuffing_en;
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bit_de_stuff_counter_ff <= 3'h1;
        else
            bit_de_stuff_counter_ff <= bit_de_stuff_counter_next;
    end
    always_comb begin
        bit_de_stuff_counter_next = bit_de_stuff_counter_ff;

        if (reset_mode) begin
            bit_de_stuff_counter_next = 3'h1;
        end
        else if (bit_start_point && bit_de_stuffing_ff) begin
            if (bit_de_stuff_counter_ff == 3'h5) begin
                bit_de_stuff_counter_next = 3'h1;
            end
            else if (rx_bit_curr == rx_bit_prev) begin
                bit_de_stuff_counter_next = bit_de_stuff_counter_ff + 1'b1;
            end
            else begin
                bit_de_stuff_counter_next = 3'h1;
            end
        end
    end

    assign remove_stuff_bit = (bit_de_stuff_counter_ff == 3'h5);

endmodule
