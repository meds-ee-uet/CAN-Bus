// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0
// Description: Testbench for receiver FSM-based module
// Author: Nimra Javaid
// Date: 11-Aug-2025

// ======================================================
// Self Testing Testbench for CAN Receiver
// ======================================================

`timescale 1ns/1ps
`include "can_defs.svh"

module tb_can_receiver;

  logic clk;
  logic rst_n;
  logic rx_bit_curr;
  logic sample_point;
  logic remove_stuff_bit;

  logic [7:0]  rx_data_array [0:7];
  logic        rx_done_flag;
  logic [10:0] rx_id_std;
  logic [17:0] rx_id_ext;
  logic        rx_ide;
  logic [3:0]  rx_dlc;
  logic        rx_remote_req;
  logic        bit_de_stuffing_en;

  int pass=0, fail=0;

  // DUT
  can_receiver dut (
    .clk(clk),
    .rst_n(rst_n),
    .rx_bit_curr(rx_bit_curr),
    .sample_point(sample_point),
    .remove_stuff_bit(remove_stuff_bit),
    .rx_data_array(rx_data_array),
    .rx_done_flag(rx_done_flag),
    .rx_id_std(rx_id_std),
    .rx_id_ext(rx_id_ext),
    .rx_ide(rx_ide),
    .rx_dlc(rx_dlc),
    .bit_de_stuffing_en(bit_de_stuffing_en),
    .rx_remote_req(rx_remote_req)
  );

  initial clk=0;
  always #5 clk=~clk;
  initial sample_point=0;
  always #10 sample_point=~sample_point;
  task send_bit(input bit b);
    @(posedge sample_point);
    rx_bit_curr=b;
  endtask

  task send_byte(input [7:0] data);
    for(int i=7;i>=0;i--)
      send_bit(data[i]);
  endtask

  task PASS(string s);
    pass++; $display(" %s",s);
  endtask

  task FAIL(string s);
    fail++; $display("%s",s);
  endtask

  //---------------- TEST ----------------

  initial begin
    rx_bit_curr=1;
    remove_stuff_bit=0;
    rst_n=0;

    #40 rst_n=1;
    // SOF
    send_bit(0);
    // STD ID = 11'h7FF
    repeat(11) send_bit(1);
    // RTR
    send_bit(0);
    // IDE
    send_bit(0);
    // r0
    send_bit(0);
    // DLC = 2
    send_bit(0); send_bit(0); send_bit(1); send_bit(0);
    // DATA BYTES
    send_byte(8'hAB);
    send_byte(8'hCD);
    // CRC dummy
    repeat(15) send_bit(1);
    // CRC delimiter
    send_bit(1);
    // ACK
    send_bit(0);
    // ACK delimiter
    send_bit(1);
    // EOF
    repeat(7) send_bit(1);
    // IFS
    repeat(3) send_bit(1);
  end
  initial begin
    wait(rx_done_flag);

    $display("\nRX COMPLETE\n");

    if(rx_id_std==11'h7FF) PASS("ID matched"); else FAIL("ID mismatch");
    if(rx_dlc==2) PASS("DLC matched"); else FAIL("DLC mismatch");

    if(rx_data_array[0]==8'hAB) PASS("DATA0 OK"); else FAIL("DATA0 BAD");
    if(rx_data_array[1]==8'hCD) PASS("DATA1 OK"); else FAIL("DATA1 BAD");

    $display("\n====================");
    $display(" PASSES=%0d FAILS=%0d",pass,fail);
    $display("====================");

    if(fail==0) $display(" RECEIVER TEST PASSED");
    else        $display("RECEIVER TEST FAILED");

    #50 $finish;
  end

endmodule
