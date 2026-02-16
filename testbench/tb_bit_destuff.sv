// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: A SystemVerilog testbench designed to verify the functionality of the can_bit_destuffer module.
// It ensures the module correctly detects and flags the stuffed bit  inserted 
// during transmission, enabling proper CAN frame de-stuffing on the receiver side.
//
// Author: Nimrajavaid
// Date: 01-Aug-2025
`timescale 1ns / 10ps

module tb_can_bit_de_stuffer;

    logic clk;
    logic rst_n;
    logic reset_mode;
    logic bit_start_point;
    logic rx_bit_curr;
    logic rx_bit_prev;
    logic bit_de_stuffing_en;
    logic remove_stuff_bit;
    can_bit_de_stuffer dut (.*);
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    task drive_bit(input logic bit_val, input logic de_stuff_en);
        begin
            @(posedge clk);
            bit_start_point <= #1 1'b1;
            rx_bit_prev     <= #1 rx_bit_curr; 
            rx_bit_curr     <= #1 bit_val;
            bit_de_stuffing_en <= #1 de_stuff_en;
            
            @(posedge clk);
            bit_start_point <= #1 1'b0;
        end
    endtask

    // MONITOR & CHECKER (Task)

    task monitor_and_check(input logic expected_remove);
        begin

            #2; 
            if (remove_stuff_bit !== expected_remove) begin
                $display("ERROR: Time=%0t | Expected Remove=%b, Got=%b | Internal Count=%d", 
                         $time, expected_remove, remove_stuff_bit, dut.bit_de_stuff_counter_ff);

                $display("!!! VERIFICATION FAILED !!!");
            end else begin
                $display("PASS : Time=%0t | Bit=%b | Count=%d | Remove=%b", 
                         $time, rx_bit_curr, dut.bit_de_stuff_counter_ff, remove_stuff_bit);
            end
        end
    endtask

    initial begin
        automatic logic rand_bit;
        automatic logic is_stuff_bit;
        rst_n = 0;
        reset_mode = 0;
        bit_start_point = 0;
        rx_bit_curr = 0;
        rx_bit_prev = 1; 
        bit_de_stuffing_en = 0;
        #20 rst_n = 1;

        $display("\n--- Starting Directed Test: 5 Consecutive Bits + 1 Stuff Bit ---");
        repeat(5) begin
            drive_bit(1'b1, 1'b1);
            monitor_and_check(1'b0); 
        end
        drive_bit(1'b0, 1'b1); 
        monitor_and_check(1'b1); 

        $display("\n--- Starting Random Test: 100 Random Cycles ---");
        repeat (100) begin
            is_stuff_bit = (dut.bit_de_stuff_counter_ff == 3'h5);
            rand_bit = $random % 2;
            drive_bit(rand_bit, 1'b1);
            
            monitor_and_check(is_stuff_bit);
        end

        $display("\n------------------------------------------------");
        $display("Final Status: Verification loop finished.");
        $display("If no ERROR messages appeared above, the design is correct.");
        $display("------------------------------------------------");
        $finish;
    end

endmodule