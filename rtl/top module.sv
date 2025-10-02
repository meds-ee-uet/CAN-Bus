
`include "can_defs.svh"
`timescale 1ns / 10ps

module can_top (
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
    output logic [14:0] calculated_crc,
    output logic        tx_bit,
    output logic        tx_done,
    output logic        crc_active,
    output logic        arbitration_active
); 

    // Internal signals
    
    logic        rd_tx_data_byte;
    logic        crc_en;
    logic        crc_init;
    
    

    // CRC enable logic - stops when CRC field starts
    assign crc_en = crc_active && sample_point;
    assign crc_init = start_tx;

    // CRC Generator Module
    can_crc15_gen u_crc (
        .clk        (clk),
        .rst_n      (rst_n),
        .crc_en     (crc_en),
        .data_bit   (tx_bit),
        .crc_init   (crc_init),
        .crc_out    (calculated_crc)
    );

    // CAN Transmitter Module
    can_transmitter u_transmitter (
        .clk                (clk),
        .rst_n              (rst_n),
        .sample_point       (sample_point),
        .start_tx           (start_tx),
        .tx_data_0          (tx_data_0),
        .tx_data_1          (tx_data_1),
        .tx_data_2          (tx_data_2),
        .tx_data_3          (tx_data_3),
        .tx_data_4          (tx_data_4),
        .tx_data_5          (tx_data_5),
        .tx_data_6          (tx_data_6),
        .tx_data_7          (tx_data_7),
        .tx_data_8          (tx_data_8),
        .tx_data_9          (tx_data_9),
        .calculated_crc     (calculated_crc),
        .tx_bit             (tx_bit),
        .tx_done            (tx_done),
        .crc_active          (crc_active),
        .rd_tx_data_byte    (rd_tx_data_byte),
        .arbitration_active (arbitration_active)
    );

endmodule