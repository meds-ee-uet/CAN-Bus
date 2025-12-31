// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0

// Description: tb_can_tx_priority — test can_tx_priority module 

// Author: Ayesha Qadir
// Date: 15 July, 2025

`timescale 1ns/1ps

module tb_can_tx_priority;

  localparam N = 4;

  // DUT signals
  logic clk, rst, we, re, start_tx, full, empty;
  logic [10:0] req_id, tx_id;
  logic [3:0]  req_dlc, tx_dlc;
  logic [7:0]  req_data [0:7], tx_data [0:7];

  // Error tracking
  int error_count = 0;

  // DUT instantiation
  can_tx_priority #(.N(N)) dut (.*);

  // Clock generator
  initial clk = 0;
  always #5 clk = ~clk;

  // --- Helper Tasks ---

  task write_frame(input [10:0] id, input [3:0] dlc);
    begin
      @(posedge clk);
      #1; // Small delay to avoid race conditions
      we = 1; req_id = id; req_dlc = dlc;
      for (int i = 0; i < 8; i++) req_data[i] = i + id[7:0]; 
      @(posedge clk);
      #1; we = 0;
    end
  endtask

  // Self-testing task: Reads and checks if the ID matches expectation
  task verify_tx(input [10:0] expected_id, input string msg);
    begin
      @(posedge clk);
      #2; // Wait for logic to settle
      if (tx_id !== expected_id) begin
        $display("[ERROR] %s | Expected ID: %h, Got: %h", msg, expected_id, tx_id);
        error_count++;
      end else begin
        $display("[PASS] %s | ID: %h", msg, tx_id);
      end
      // Acknowledge the frame
      re = 1;
      @(posedge clk);
      #1; re = 0;
    end
  endtask

  // --- Test Suites ---

  initial begin
    // Init
    we = 0; re = 0; rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;

    $display("--- Starting Case 1: Priority Sorting ---");
    write_frame(11'h300, 4'h8); // 1st: moves to tx_reg
    write_frame(11'h500, 4'h8); // 2nd: moves to buffer[0]
    write_frame(11'h400, 4'h8); // 3rd: moves to buffer[0], shifts 500 to buffer[1]
    
    verify_tx(11'h300, "Initial message"); 
    verify_tx(11'h400, "Priority check 1");
    verify_tx(11'h500, "Priority check 2");

    $display("--- Starting Case 2: Preemption ---");
    // Write a low priority ID first
    write_frame(11'h600, 4'h8); 
    // Write a higher priority ID while 600 is waiting in tx_reg
    write_frame(11'h100, 4'h8); 
    
    // 100 should now be in tx_reg because it is < 600
    verify_tx(11'h100, "Preemption check");
    verify_tx(11'h600, "Post-preemption check");

    $display("--- Starting Case 3: Boundary Flags ---");
    if (!empty) begin $display("[ERROR] Empty flag failed"); error_count++; end
    
    // Fill to capacity
    write_frame(11'h10, 4'h1);
    write_frame(11'h20, 4'h1);
    write_frame(11'h30, 4'h1);
    write_frame(11'h40, 4'h1);
    write_frame(11'h50, 4'h1); // N=4 + 1 in tx_reg = 5 total capacity

    @(posedge clk); #1;
    if (!full) begin $display("[ERROR] Full flag failed"); error_count++; end
    else $display("[PASS] Full flag verified");

    // Final Summary
    #50;
    if (error_count == 0)
      $display("\n**** TEST PASSED SUCCESSFULLY ****\n");
    else
      $display("\n**** TEST FAILED WITH %0d ERRORS ****\n", error_count);
    
    $finish;
  end

endmodule