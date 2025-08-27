`timescale 1ns / 1ps

module tb_can_transmitter;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic sample_point;
    logic start_tx;

    // CAN data bytes
    logic [7:0] tx_data [0:9];

    // DUT outputs
    logic tx_bit;
    logic tx_done;
    logic rd_tx_data_byte;
    logic arbitration_active;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    // Generate sample_point pulse every 10ns (same as clock rising edge here)
    always @(posedge clk) sample_point <= 1;

    // DUT Instance
    can_transmitter dut (
        .clk(clk),
        .rst_n(rst_n),
        .sample_point(sample_point),
        .start_tx(start_tx),
        .tx_data_0(tx_data[0]),
        .tx_data_1(tx_data[1]),
        .tx_data_2(tx_data[2]),
        .tx_data_3(tx_data[3]),
        .tx_data_4(tx_data[4]),
        .tx_data_5(tx_data[5]),
        .tx_data_6(tx_data[6]),
        .tx_data_7(tx_data[7]),
        .tx_data_8(tx_data[8]),
        .tx_data_9(tx_data[9]),
        .tx_bit(tx_bit),
        .tx_done(tx_done),
        .rd_tx_data_byte(rd_tx_data_byte),
        .arbitration_active(arbitration_active)
    );

    // Initialize and run simulation
    initial begin
        $dumpfile("can_tx_wave.vcd");
        $dumpvars(0, tb_can_transmitter);

        // Reset
        rst_n = 0;
        start_tx = 0;
        sample_point = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;

        // Prepare CAN frame (Standard Frame, DLC=8)
        tx_data[0] = 8'hAA; // ID[10:3]
        tx_data[1] = 8'b1000_1000; // ID[2:0], RTR=0, DLC=8
        tx_data[2] = 8'h11;
        tx_data[3] = 8'h22;
        tx_data[4] = 8'h33;
        tx_data[5] = 8'h44;
        tx_data[6] = 8'h55;
        tx_data[7] = 8'h66;
        tx_data[8] = 8'h77;
        tx_data[9] = 8'h88;

        // Start transmission
        @(posedge clk);
        start_tx = 1;
        @(posedge clk);
        start_tx = 0;

        // Wait for end of frame
        wait (tx_done);
        $display("CAN frame transmission completed at time %0t", $time);

        #100;
        $finish;
    end

    // Monitor transmitted bits
    always @(posedge clk) if (sample_point) begin
        $write("%0t: tx_bit = %b\n", $time, tx_bit);
    end

endmodule
