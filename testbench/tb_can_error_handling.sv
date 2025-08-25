// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// This testbench applies different CAN error scenarios (bit, stuff, ACK, CRC, form) 
// plus special cases (14 consecutive dominant bits, dominant-after-flag)
// to verify error detection.
//
// Author: Aryam Shabbir
// Date: 6th August,2025

`timescale 1ns/1ps

module tb_can_error_detection;

  logic clk;
  logic rst;
  logic rx_bit;
  logic tx_bit;
  logic tx_active;
  logic sample_point;

  logic bit_de_stuffing_ff;
  logic remove_stuff_bit;
  logic in_arbitration;
  logic in_ack_slot;
  logic in_crc_delimiter;
  logic in_ack_delimiter;
  logic in_eof;
  logic crc_check_done;
  logic crc_rx_valid;
  logic crc_rx_match;
  logic overload_request;
  logic dominant_after_flag;

  logic bit_error;
  logic stuff_error;
  logic crc_error;
  logic form_error;
  logic ack_error;
  logic [7:0] tec;
  logic [7:0] rec;
  logic error_active;
  logic error_passive;
  logic bus_off;

  // DUT instantiation
  can_error_detection dut (
    .clk(clk),
    .rst(rst),
    .rx_bit(rx_bit),
    .tx_bit(tx_bit),
    .tx_active(tx_active),
    .sample_point(sample_point),
    .bit_de_stuffing_ff(bit_de_stuffing_ff),
    .remove_stuff_bit(remove_stuff_bit),
    .in_arbitration(in_arbitration),
    .in_ack_slot(in_ack_slot),
    .in_crc_delimiter(in_crc_delimiter),
    .in_ack_delimiter(in_ack_delimiter),
    .in_eof(in_eof),
    .crc_check_done(crc_check_done),
    .crc_rx_valid(crc_rx_valid),
    .crc_rx_match(crc_rx_match),
    .overload_request(overload_request),
    .dominant_after_flag(dominant_after_flag),
    .bit_error(bit_error),
    .stuff_error(stuff_error),
    .crc_error(crc_error),
    .form_error(form_error),
    .ack_error(ack_error),
    .tec(tec),
    .rec(rec),
    .error_active(error_active),
    .error_passive(error_passive),
    .bus_off(bus_off)
  );

  // Clock generator
  always #5 clk = ~clk;

  initial begin
    // Init
    clk = 0;
    rst = 0;
    rx_bit = 1;
    tx_bit = 1;
    tx_active = 0;
    sample_point = 0;
    bit_de_stuffing_ff = 0;
    remove_stuff_bit = 0;
    in_arbitration = 0;
    in_ack_slot = 0;
    in_crc_delimiter = 0;
    in_ack_delimiter = 0;
    in_eof = 0;
    crc_check_done = 0;
    crc_rx_valid = 0;
    crc_rx_match = 1;
    overload_request = 0;
    dominant_after_flag = 0;

    // Reset
    #12 rst = 1;

    // --- Test 1: Bit error ---
    #10 sample_point = 1; tx_active = 1; tx_bit = 1; rx_bit = 0;
    #10 sample_point = 0; tx_active=0;

    // --- Test 2: Stuff error ---
    #10 sample_point = 1; bit_de_stuffing_ff = 1; remove_stuff_bit = 1; rx_bit = 0;
    #10 sample_point = 0; bit_de_stuffing_ff = 0; remove_stuff_bit = 0;

    // --- Test 3: ACK error ---
    #10 sample_point = 1; tx_active = 1; in_ack_slot = 1; rx_bit = 1;
    #10 sample_point = 0; in_ack_slot = 0; tx_active=0;

    // --- Test 4: CRC error ---
    #10 sample_point=1; crc_check_done = 1; crc_rx_valid = 1; crc_rx_match = 0;
    #10 sample_point=0; crc_check_done = 0; crc_rx_valid = 0; crc_rx_match = 1;

    // --- Test 5: Form error ---
    #10 sample_point = 1; rx_bit = 0; in_crc_delimiter = 1;
    #10 sample_point = 0; in_crc_delimiter = 0;

    // --- Test 6: 14 Dominant Bits (should increment both TEC & REC) ---
       
    $display("\n--- Starting 14 Dominant Bits Test ---");
    rx_bit = 0;
    repeat(14) begin
      #10;   // just hold dominant bits for 14 clock cycles
    end

    // --- Test 7: Dominant after Error Flag ---
    $display("\n--- Dominant After Error Flag Test ---");
    #20 dominant_after_flag = 1;
    #10 dominant_after_flag = 0;

    // --- End simulation ---
    #50;
    $display("\nFinal Results -> TEC=%0d, REC=%0d, Active=%b, Passive=%b, BusOff=%b",
             tec, rec, error_active, error_passive, bus_off);
    $stop;
  end

endmodule
