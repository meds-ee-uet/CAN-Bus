module can_bit_stuffer (
  input  logic clk,
  input  logic rst_n,
  input  logic reset_mode,
  input  logic sample_point,
  input  logic bit_start_point,
  input  logic tx_frame_tx_bit,      // Actual frame bit to transmit
  input  logic bit_stuffing_en,      // Enable bit stuffing

  output logic stuffed_tx_bit,       // Bit transmitted after stuffing logic
  output logic insert_stuff_bit      // High when a stuff bit is inserted
);

  // Internal registers and signals
  logic [2:0] bit_stuff_counter_ff, bit_stuff_counter_next;
  logic       bit_stuffing_ff, bit_stuffing_next;
  logic       tx_bit_prev, tx_bit_curr, tx_bit_next;
  logic       insert_stuff_bit_ff, insert_stuff_bit_next;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      bit_stuffing_ff <= 1'b0;
    else
      bit_stuffing_ff <= bit_stuffing_next;
  end

  always_comb begin
    if (reset_mode)
      bit_stuffing_next = 1'b0;
    else
      bit_stuffing_next = bit_stuffing_en; // Controlled by enable
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      bit_stuff_counter_ff <= 3'h1;
    else
      bit_stuff_counter_ff <= bit_stuff_counter_next;
  end

  always_comb begin
    bit_stuff_counter_next = bit_stuff_counter_ff;

    if (reset_mode)
      bit_stuff_counter_next = 3'h1;
    else if (sample_point && bit_stuffing_ff) begin
      if (insert_stuff_bit_ff)
        bit_stuff_counter_next = 3'h1;
      else if (tx_bit_curr == tx_bit_prev)
        bit_stuff_counter_next = bit_stuff_counter_ff + 1'b1;
      else
        bit_stuff_counter_next = 3'h1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      insert_stuff_bit_ff <= 1'b0;
    else
      insert_stuff_bit_ff <= insert_stuff_bit_next;
  end

    always_comb begin
    insert_stuff_bit_next = 1'b0;  // default low

    if (reset_mode)
        insert_stuff_bit_next = 1'b0;
    else if (sample_point && bit_stuffing_ff && (bit_stuff_counter_ff == 3'h5))
        insert_stuff_bit_next = 1'b1; // one-cycle pulse when counter hits 5
    else
        insert_stuff_bit_next = 1'b0;
    end


  assign insert_stuff_bit = insert_stuff_bit_ff;

  always_comb begin
    if (insert_stuff_bit_ff)
      tx_bit_next = ~tx_bit_prev;       // Insert opposite bit (stuffed)
    else
      tx_bit_next = tx_frame_tx_bit;    // Normal bit
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      tx_bit_curr <= 1'b1;
    else if (reset_mode)
      tx_bit_curr <= 1'b1;
    else if (bit_start_point)
      tx_bit_curr <= tx_bit_next;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      tx_bit_prev <= 1'b1;
    else if (reset_mode)
      tx_bit_prev <= 1'b1;
    else if (bit_start_point)
      tx_bit_prev <= tx_bit_curr;
  end

  assign stuffed_tx_bit = tx_bit_curr;

endmodule 