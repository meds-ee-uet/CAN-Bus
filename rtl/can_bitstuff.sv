
module can_bit_stuffer (
  input  logic clk,
  input  logic rst_n,
  input  logic bit_in,
  input  logic sample_point,     
  output logic bit_out,
  output logic stuff_inserted
);

  logic prev_bit;
  logic [2:0] same_count;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prev_bit   <= 0;         // Start with neutral 0
      same_count <= 3'd0;      // Start count at 0
    end else if (sample_point) begin
      if (bit_in == prev_bit)
        same_count <= same_count + 1;
      else
        same_count <= 3'd1;

      prev_bit <= bit_in;
    end
  end

  assign stuff_inserted = (same_count == 6);

  always_comb begin
    if (stuff_inserted)
      bit_out = ~prev_bit;
    else
      bit_out = bit_in;
  end

endmodule
