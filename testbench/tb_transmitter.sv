// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//Description: 
// CAN Transmiter 
// Author: Nimra javaid
// Date: 22-Dec-2025

`timescale 1ns/1ps
`include "can_defs.svh"

module tb_can_transmitter;

  logic clk;
  logic rst_n;

  always #5 clk = ~clk;

  logic        sample_point;
  logic        bit_start_point;
  logic        start_tx;
  logic        ide;
  logic [10:0] id_std;
  logic [17:0] id_ext;
  logic        rtr;
  logic [3:0]  dlc;
  logic        insert_stuff_bit;
  logic [7:0] tx_data_0, tx_data_1, tx_data_2, tx_data_3;
  logic [7:0] tx_data_4, tx_data_5, tx_data_6, tx_data_7;
  logic [14:0] calculated_crc;
  logic tx_bit;
  logic tx_done;
  logic rd_tx_data_byte;
  logic crc_active;
  logic bit_stuffing_en;
  logic arbitration_active;
  int error_count = 0;

  can_transmitter dut (.*);

  always @(posedge clk) begin
    sample_point    <= 1'b1;
    bit_start_point <= 1'b1;
    insert_stuff_bit <= 1'b0;
  end


  task reset_dut;
    begin
      rst_n = 0;
      start_tx = 0;
      repeat (5) @(posedge clk);
      rst_n = 1;
    end
  endtask

  task start_frame;
    begin
      @(posedge clk);
      start_tx = 1;
      @(posedge clk);
      start_tx = 0;
    end
  endtask


  task wait_done(input string testname);
    begin
      wait (tx_done == 1);
      @(posedge clk);
      if (tx_done !== 1'b1) begin
        $display("[ERROR] %s : tx_done not asserted", testname);
        error_count++;
      end else begin
        $display("[PASS ] %s completed successfully", testname);
      end
    end
  endtask

  initial begin
    clk = 0;
    reset_dut();

    // ======================================================
    // CASE 1: Standard Data Frame
    // ======================================================
    $display("\n--- CASE 1: STANDARD DATA FRAME ---");

    ide = 0;
    rtr = 0;
    id_std = 11'h123;
    id_ext = '0;
    dlc = 4'd2;

    tx_data_0 = 8'hAA;
    tx_data_1 = 8'hBB;
    tx_data_2 = 0;
    tx_data_3 = 0;
    tx_data_4 = 0;
    tx_data_5 = 0;
    tx_data_6 = 0;
    tx_data_7 = 0;

    calculated_crc = 15'h5555;

    start_frame();
    wait_done("Standard Frame");

    // ======================================================
    // CASE 2: Extended Data Frame
    // ======================================================
    $display("\n--- CASE 2: EXTENDED DATA FRAME ---");

    ide = 1;
    rtr = 0;
    id_std = 11'h456;
    id_ext = 18'h2AAAA;
    dlc = 4'd4;

    tx_data_0 = 8'h11;
    tx_data_1 = 8'h22;
    tx_data_2 = 8'h33;
    tx_data_3 = 8'h44;

    calculated_crc = 15'h1234;

    start_frame();
    wait_done("Extended Frame");

    // ======================================================
    // CASE 3: Remote Frame (Standard)
    // ======================================================
    $display("\n--- CASE 3: STANDARD REMOTE FRAME ---");

    ide = 0;
    rtr = 1;
    id_std = 11'h321;
    dlc = 4'd4;   // DLC valid, but no data

    start_frame();
    wait_done("Standard Remote Frame");

    // ======================================================
    // CASE 4: Remote Frame (Extended)
    // ======================================================
    $display("\n--- CASE 4: EXTENDED REMOTE FRAME ---");

    ide = 1;
    rtr = 1;
    id_ext = 18'h1FFFF;
    dlc = 4'd8;

    start_frame();
    wait_done("Extended Remote Frame");

    // ======================================================
    // CASE 5: DLC boundary (0 and 8)
    // ======================================================
    $display("\n--- CASE 5: DLC BOUNDARY TEST ---");

    ide = 0;
    rtr = 0;
    id_std = 11'h055;

    dlc = 0;
    start_frame();
    wait_done("DLC = 0");

    dlc = 8;
    start_frame();
    wait_done("DLC = 8");

    // ======================================================
    // FINAL RESULT
    // ======================================================
    #50;
    if (error_count == 0)
      $display("\n**** ALL TESTS PASSED SUCCESSFULLY ****\n");
    else
      $display("\n**** TEST FAILED WITH %0d ERRORS ****\n", error_count);

    $finish;
  end

endmodule
