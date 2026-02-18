// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//Description: 
// top module of CAN Bus IP Core
// Author: Nimrajavaid
// Date: 22-Dec-2025
`include "can_defs.svh"
`timescale 1ns / 10ps

module can_top (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start_tx,
    input  logic        ide,
    input  logic [10:0] id_std,       
    input  logic [17:0] id_ext,
    input  logic        rtr,
    input  logic [3:0]  dlc,
    input  logic [7:0]  tx_data_0,
    input  logic [7:0]  tx_data_1,
    input  logic [7:0]  tx_data_2,
    input  logic [7:0]  tx_data_3,
    input  logic [7:0]  tx_data_4,
    input  logic [7:0]  tx_data_5,
    input  logic [7:0]  tx_data_6,
    input  logic [7:0]  tx_data_7,
    input  logic        go_error_frame,
    input  logic        go_overload_frame,
    input  logic        send_ack,
    input  logic        transmitting,
    input  logic        transmitter,
    input  logic        rx_idle,
    input  logic        rx_inter,
    input  logic        go_tx,
    input  logic        go_rx_inter,
    input  logic        node_error_passive,
    output logic [14:0] calculated_crc,
    output logic        tx_bit,
    output logic        tx_done,
    output logic        crc_active,
    output logic        sample_point,
    output logic        sampled_bit,
    output logic        sampled_bit_q,
    output logic        tx_point,
    output logic        hard_sync,
    output logic        rx_done_flag,
    output logic        arbitration_active
);
    // internal signals
    logic         crc_en;
    logic         bit_stuffing_en;
    logic         crc_init;
    logic         rd_tx_data_byte;
    logic [7:0]   rx_data_array [0:7];
    logic         tx_frame_tx_bit;
    logic         rx_bit_curr;
    logic         stuffed_tx_bit;
    logic [10:0]  rx_id_std;
    logic [17:0]  rx_id_ext;
    logic         rx_ide;
    logic [3:0]   rx_dlc;
    logic         rx_remote_req;
    logic                                   bit_sample_point, bit_start_point;
    logic         remove_stuff_bit_int;
    logic bit_stuffig_en;
    logic bit_de_stuffing_en;
    logic insert_stuff_bit;
    logic insert_de_stuff_bit;
    logic tx_next;

    type_reg2tim_s reg2tim_i; 

    assign crc_en   = crc_active && sample_point && ~insert_stuff_bit;
    assign bit_stuffing = bit_stuffing_en;
    assign crc_init = start_tx;
    assign tx_next = stuffed_tx_bit;
    assign tx_bit= stuffed_tx_bit ;     
    assign rx_bit_curr = sampled_bit;
    assign rx_bit_prev = sampled_bit_q;
    assign bit_sample_point = sample_point;
    assign bit_start_point = tx_point;
    // CAN CRC
    can_crc15_gen u_crc (
        .clk        (clk),
        .rst_n      (rst_n),
        .crc_en     (crc_en),
        .data_bit   (tx_frame_tx_bit),
        .crc_init   (crc_init),
        .crc_out    (calculated_crc)
    );

    // Transmitter
    can_transmitter u_transmitter (
        .clk                (clk),
        .rst_n              (rst_n),
        .sample_point       (sample_point),
        .bit_start_point    (tx_point),
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
        .rd_tx_data_byte    (rd_tx_data_byte),
        .calculated_crc     (calculated_crc),
        .insert_stuff_bit    (insert_stuff_bit),
        .crc_active         (crc_active),
        .tx_bit             (tx_frame_tx_bit),
        .tx_done            (tx_done),
        .arbitration_active (arbitration_active),
        .bit_stuffing_en    (bit_stuffing_en)
    );
    can_bit_stuffer u_stuffer (
        .clk(clk),
        .rst_n(rst_n),
        .reset_mode(reset_mode),
        .bit_start_point(tx_point),
        .sample_point(sample_point),
        .tx_frame_tx_bit(tx_frame_tx_bit),
        .bit_stuffing_en(bit_stuffing),
        .stuffed_tx_bit(stuffed_tx_bit),
        .insert_stuff_bit(insert_stuff_bit)
    );


    can_bit_de_stuffer u_de_stuffer (
    	.clk               (clk),
    	.rst_n             (rst_n),
    	.reset_mode        (rx_idle),          // reset counter in IDLE / SOF
    	.bit_start_point   (sample_point),     // count at sampling boundary
    	.rx_bit_curr       (sampled_bit),
    	.rx_bit_prev       (sampled_bit_q),
    	.bit_de_stuffing_en(bit_stuffing_en),  // same enable as stuffing
    	.remove_stuff_bit  (remove_stuff_bit_int)
    );

    can_receiver u_receiver (
        .clk             (clk),
        .rst_n           (rst_n),
        .rx_bit_curr     (sampled_bit),
        .sample_point    (sample_point),
        .remove_stuff_bit(remove_stuff_bit_int),
        .rx_data_array   (rx_data_array),
        .rx_done_flag    (rx_done_flag),
        .rx_id_std       (rx_id_std),
        .rx_id_ext       (rx_id_ext),
        .rx_ide          (rx_ide),
        .rx_dlc          (rx_dlc),
        .bit_de_stuffing_en (bit_de_stuffing_en),
        .rx_remote_req   (rx_remote_req)
    );


    // Timing
    can_timing u_can_timing (
        .rst_n              (rst_n),
        .clk                (clk),
        .go_error_frame     (go_error_frame),
        .go_overload_frame  (go_overload_frame),
        .send_ack           (send_ack),
        .rx                 (stuffed_tx_bit),
        .tx                 (stuffed_tx_bit),
        .tx_next            (tx_next),
        .transmitting       (transmitting),
        .transmitter        (transmitter),
        .rx_idle            (rx_idle),
        .rx_inter           (rx_inter),
        .go_tx              (go_tx),
        .go_rx_inter        (go_rx_inter),
        .node_error_passive (node_error_passive),
        .reg2tim_i          (reg2tim_i),
        .sample_point       (sample_point),
        .sampled_bit        (sampled_bit),
        .sampled_bit_q      (sampled_bit_q),
        .tx_point           (tx_point),
        .hard_sync          (hard_sync)
    );

endmodule
