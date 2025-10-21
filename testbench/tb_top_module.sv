`timescale 1ns / 1ps
`include "can_defs.svh"

module tb_can_top;

    // Clock and reset
    logic clk;
    logic rst_n;

    // CAN transmit inputs
    logic start_tx;
    logic ide;
    logic [10:0] id_std;
    logic [28:0] id_ext;
    logic rtr;
    logic [3:0]  dlc;
    logic [7:0]  tx_data_0, tx_data_1, tx_data_2, tx_data_3;
    logic [7:0]  tx_data_4, tx_data_5, tx_data_6, tx_data_7;

    // Timing/control signals
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
    logic hard_sync;
    logic arbitration_active;
    logic rx_done_flag;

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

    initial begin
        // Initialize
        rst_n = 0;
        start_tx = 0;
        ide = 0;
        id_std = 11'b10101010101;
        id_ext = 29'h1ABCDEF;
        rtr = 0;
        dlc = 4'b0100;

        tx_data_0 = 8'h11;
        tx_data_1 = 8'h22;
        tx_data_2 = 8'h33;
        tx_data_3 = 8'h44;
        tx_data_4 = 8'h55;
        tx_data_5 = 8'h66;
        tx_data_6 = 8'h77;
        tx_data_7 = 8'h88;

        // Timing / control signals
        go_error_frame     = 0;
        go_overload_frame  = 0;
        send_ack           = 0;
        transmitting       = 0;
        transmitter        = 0;
        rx_idle            = 1;
        rx_inter           = 0;
        go_tx              = 0;
        go_rx_inter        = 0;
        node_error_passive = 0;

        // Reset
        #50 rst_n = 1;

        // Configure CAN timing
        dut.reg2tim_i.tseg1          = 4;
        dut.reg2tim_i.tseg2          = 3;
        dut.reg2tim_i.sjw            = 1;
        dut.reg2tim_i.baud_prescaler = 1;

        // Wait for timing setup
        #50;

        // Start transmission
        start_tx = 1;
        #500 start_tx = 0;
        #20;

        transmitting = 1;
        transmitter = 1;
        go_tx = 1;
        #40;

        rx_idle = 0;

    end

    initial begin
        $display("Time\tTX_BIT\tRX_BIT\tSAMPLE_PT\tCRC\tTX_DONE\tState");
        $monitor("%0t\t%b\t%b\t%b\t%h\t%b\t%s",
                $time, tx_bit, dut.rx_bit_curr, sample_point, calculated_crc, tx_done,
                dut.u_transmitter.tx_state_ff.name());

        $monitor("time=%0t state=%0d bit_cnt=%0d sample_point=%b rx_done=%b",
                $time, 
                dut.u_receiver.rx_state_ff,
                dut.u_receiver.rx_bit_cnt_ff,
                dut.u_can_timing.sample_point,
                dut.u_receiver.rx_done_flag);
    end


    always @(posedge clk) begin
        if (sample_point)
            $display("[%0t] SAMPLE: State=%s, Bit=%b, BitCnt=%0d", 
                     $time,
                     dut.u_transmitter.tx_state_ff.name(),
                     tx_bit,
                     dut.u_transmitter.tx_bit_cnt_ff);
        if (hard_sync)
            $display("[%0t] HARD_SYNC occurred!", $time);
    end

    initial begin
        $dumpfile("can_top_tb.vcd");
        $dumpvars(0, tb_can_top);

        // Wait for reset release
        @(posedge rst_n);
        $display("Reset deasserted, simulation started...");

        fork
            begin : TX_DONE_MONITOR
                wait (rx_done_flag== 1);
                $display("[%0t] ✅ Transmission completed successfully! TX_DONE = %b", $time, tx_done);
                #100;
                $display("Simulation Finished Normally");
                disable TIMEOUT;
                $finish;
            end

            begin : TIMEOUT
                #100_000_000; // 100 ms simulation limit
                $display("[%0t] ⚠️ TIMEOUT: TX_DONE not asserted! Stopping simulation.", $time);
                disable TX_DONE_MONITOR;
                $finish;
            end
        join
    end

endmodule
