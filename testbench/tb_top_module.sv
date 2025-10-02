`timescale 1ns/1ps
`include "can_defs.svh"

module tb_can_top;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic sample_point;
    logic start_tx;

    logic [7:0] tx_data_0, tx_data_1, tx_data_2, tx_data_3;
    logic [7:0] tx_data_4, tx_data_5, tx_data_6, tx_data_7;
    logic [7:0] tx_data_8, tx_data_9;
    logic [14:0] calculated_crc;
    logic        crc_active;
    logic tx_bit;
    logic tx_done;
    
    logic arbitration_active;


    // Instantiate DUT
    can_top dut (
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
        .crc_active          (crc_active),
        .tx_bit             (tx_bit),
        .tx_done            (tx_done),
        .arbitration_active (arbitration_active)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Reset + stimulus
    initial begin
        // Init
        rst_n = 0;
        start_tx = 0;
        sample_point = 1'b1;   // <-- keep it high all the time

        tx_data_0 = 8'h11;
        tx_data_1 = 8'h22;
        tx_data_2 = 8'h33;
        tx_data_3 = 8'h44;
        tx_data_4 = 8'h55;
        tx_data_5 = 8'h66;
        tx_data_6 = 8'h77;
        tx_data_7 = 8'h88;
        tx_data_8 = 8'h99;
        tx_data_9 = 8'hAA;

        // Release reset
        #20 rst_n = 1;

        // Start transmission
        #50 start_tx = 1;
        #10 start_tx = 0;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t tx_bit=%b tx_done=%b arb_active=%b crc=%h", 
                  $time, tx_bit, tx_done, arbitration_active, dut.calculated_crc);
    end

    // End simulation
    initial begin
        #1000;
        $display("Simulation finished");
        $stop;
    end

endmodule
