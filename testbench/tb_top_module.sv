// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//Description: 
// top module of CAN Bus IP Core
// Author: Nimrajavaid
// Date: 22-Dec-2025

`timescale 1ns / 1ps
`include "can_defs.svh"

module tb_can_top;
    logic clk;
    logic rst_n;
    logic start_tx;
    logic ide;
    logic [10:0] id_std;
    logic [17:0] id_ext;
    logic rtr;
    logic [3:0]  dlc;
    logic [7:0]  tx_data_0, tx_data_1, tx_data_2, tx_data_3;
    logic [7:0]  tx_data_4, tx_data_5, tx_data_6, tx_data_7;
    logic go_error_frame;
    logic go_overload_frame;
    logic send_ack;
    logic transmitting;
    logic transmitter;
    logic rx_idle;
    logic rx_inter;
    logic go_tx;
    logic go_rx_inter;
    logic node_error_passive;
    logic [14:0] calculated_crc;
    logic tx_bit;
    logic tx_done;
    logic crc_active;
    logic sample_point;
    logic sampled_bit;
    logic sampled_bit_q;
    logic tx_point;
    logic bit_stuffing_en;
    logic hard_sync;
    logic arbitration_active;
    logic rx_done_flag;
    integer pass_count = 0;
    integer fail_count = 0;
    integer i;
    logic [7:0] expected [0:7];
    can_top dut (
        .clk                (clk),
        .rst_n              (rst_n),
        .start_tx           (start_tx),
        .ide                (ide),
        .id_std             (id_std),
        .id_ext             (id_ext),
        .rtr                (rtr),
        .dlc                (dlc),
        .tx_data_0          (tx_data_0),
        .tx_data_1          (tx_data_1),
        .tx_data_2          (tx_data_2),
        .tx_data_3          (tx_data_3),
        .tx_data_4          (tx_data_4),
        .tx_data_5          (tx_data_5),
        .tx_data_6          (tx_data_6),
        .tx_data_7          (tx_data_7),
        .go_error_frame     (go_error_frame),
        .go_overload_frame  (go_overload_frame),
        .send_ack           (send_ack),
        .transmitting       (transmitting),
        .transmitter        (transmitter),
        .rx_idle            (rx_idle),
        .rx_inter           (rx_inter),
        .go_tx              (go_tx),
        .go_rx_inter        (go_rx_inter),
        .node_error_passive (node_error_passive),
        .calculated_crc     (calculated_crc),
        .tx_bit             (tx_bit),
        .tx_done            (tx_done),
        .crc_active         (crc_active),
        .sample_point       (sample_point),
        .sampled_bit        (sampled_bit),
        .sampled_bit_q      (sampled_bit_q),
        .tx_point           (tx_point),
        .hard_sync          (hard_sync),
        .rx_done_flag       (rx_done_flag),
        .arbitration_active (arbitration_active)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    task pass(string msg);
        begin
            pass_count++;
            $display(" PASS: %s", msg);
        end
    endtask

    task fail(string msg);
        begin
            fail_count++;
            $display(" FAIL: %s", msg);
        end
    endtask

    task summary;
        begin
            $display("\n===============================");
            $display(" TEST SUMMARY ");
            $display(" PASSES = %0d", pass_count);
            $display(" FAILS  = %0d", fail_count);
            $display("===============================\n");

            if (fail_count == 0)
                $display(" ALL TESTS PASSED");
            else
                $display("SOME TESTS FAILED");
        end
    endtask
    initial begin
        rst_n = 0;
        start_tx = 0;
        ide = 1;
        id_std = 11'b1111110111;
        id_ext = 18'h1ABCD;
        rtr = 0;
        dlc = 4'b1000;
        tx_data_0 = 8'h7f;
        tx_data_1 = 8'h55;
        tx_data_2 = 8'h7f;
        tx_data_3 = 8'h55;
        tx_data_4 = 8'h55;
        tx_data_5 = 8'h66;
        tx_data_6 = 8'h77;
        tx_data_7 = 8'h88;
        go_error_frame = 0;
        go_overload_frame = 0;
        send_ack = 0;
        transmitting = 0;
        transmitter = 0;
        rx_idle = 1;
        rx_inter = 0;
        go_tx = 0;
        go_rx_inter = 0;
        node_error_passive = 0;
        #50 rst_n = 1;
        dut.reg2tim_i.tseg1 = 4;
        dut.reg2tim_i.tseg2 = 3;
        dut.reg2tim_i.sjw   = 1;
        dut.reg2tim_i.baud_prescaler = 1;

        #50;
        start_tx = 1;
        #500 start_tx = 0;

        #20;
        transmitting = 1;
        transmitter  = 1;
        go_tx        = 1;

        #40;
        rx_idle = 0;
    end
    initial begin
        @(posedge rst_n);
        if (tx_done == 0)
            pass("TX_DONE low after reset");
        else
            fail("TX_DONE high after reset");
    end
    initial begin
        wait(start_tx);
        @(posedge clk);
        wait(tx_bit === 0 || tx_bit === 1);
        pass("TX activity detected");
    end
    initial begin
        fork
            begin
                wait(tx_done);
                pass("TX_DONE asserted");
            end
            begin
                #700_000_000;
                fail("Timeout waiting for TX_DONE");
            end
        join
    end
    initial begin
        wait(rx_done_flag);
        $display("[%0t] RX_DONE flagged, checking received data...", $time);
        expected[0] = tx_data_0;
        expected[1] = tx_data_1;
        expected[2] = tx_data_2;
        expected[3] = tx_data_3;
        expected[4] = tx_data_4;
        expected[5] = tx_data_5;
        expected[6] = tx_data_6;
        expected[7] = tx_data_7;

        for (i=0; i<8; i=i+1) begin
            if (dut.rx_data_array[i] === expected[i])
                pass($sformatf("RX byte %0d matched: 0x%0h", i, expected[i]));
            else
                fail($sformatf("RX byte %0d mismatch: expected 0x%0h, got 0x%0h",
                               i, expected[i], dut.rx_data_array[i]));
        end
        summary();
        #100 $finish;
    end
    initial begin
        $dumpfile("can_top_tb.vcd");
        $dumpvars(0, tb_can_top);
    end

endmodule
