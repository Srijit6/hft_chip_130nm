// Top-level chip wrapper for SkyWater 130nm ASIC macro.
// Replicates the architecture of hft-chip with 3 registered pipeline stages:
// 1. Input boundary registers: registers inbound market messages
// 2. Core top-of-book registers: registers best bid/ask between order books and traders
// 3. Output boundary registers: registers outbound trade decision before pads/pins
//
// All IHP-specific pad hard-macros have been replaced with standard digital
// macro boundary registers for clean SkyWater 130nm (sky130A) hardening and integration.

module hft_chip import orderbook_pkg::*; #(
  parameter int N = 64,
  parameter bit OB_UNSORTED = 1'b1
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic valid_i,
  input  logic message_type_i,
  input  logic [1:0] market_i,
  input  logic op_i,
  input  logic side_i,
  input  logic [PRICE_WIDTH-1:0] price_i,
  input  logic [QTY_WIDTH-1:0] qty_i,

  output logic valid_o,
  output logic [1:0] market_o,
  output logic side_o,
  output logic [PRICE_WIDTH-1:0] price_o,
  output logic [QTY_WIDTH-1:0] qty_o,

  output logic error_o,
  output logic spare0_o
);

  // registered inputs for core (Stage 1)
  logic valid_i_q;
  logic message_type_i_q;
  logic [1:0] market_i_q;
  logic op_i_q;
  logic side_i_q;
  logic [PRICE_WIDTH-1:0] price_i_q;
  logic [QTY_WIDTH-1:0] qty_i_q;

  // combinational outputs from core
  logic valid_o_d;
  logic [1:0] market_o_d;
  logic side_o_d;
  logic [PRICE_WIDTH-1:0] price_o_d;
  logic [QTY_WIDTH-1:0] qty_o_d;
  logic error_o_d;

  // registered nets for output boundary (Stage 3)
  logic valid_o_q;
  logic [1:0] market_o_q;
  logic side_o_q;
  logic [PRICE_WIDTH-1:0] price_o_q;
  logic [QTY_WIDTH-1:0] qty_o_q;
  logic error_o_q;
  logic spare0_o_q;

  // input boundary register: pin -> core
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      valid_i_q        <= '0;
      message_type_i_q <= '0;
      market_i_q       <= '0;
      op_i_q           <= '0;
      side_i_q         <= '0;
      price_i_q        <= '0;
      qty_i_q          <= '0;
    end else begin
      valid_i_q        <= valid_i;
      message_type_i_q <= message_type_i;
      market_i_q       <= market_i;
      op_i_q           <= op_i;
      side_i_q         <= side_i;
      price_i_q        <= price_i;
      qty_i_q          <= qty_i;
    end
  end

  // core instance (Stage 2 top-of-book register is inside hft_core)
  hft_core #(
    .N(N),
    .OB_UNSORTED(OB_UNSORTED)
  ) core_i (
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .valid_i(valid_i_q),
    .message_type_i(message_type_i_q),
    .market_i(market_i_q),
    .op_i(op_i_q),
    .side_i(side_i_q),
    .price_i(price_i_q),
    .qty_i(qty_i_q),

    .valid_o(valid_o_d),
    .market_o(market_o_d),
    .side_o(side_o_d),
    .price_o(price_o_d),
    .qty_o(qty_o_d),
    .error_o(error_o_d)
  );

  // output boundary register: core -> pin
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      valid_o_q  <= '0;
      market_o_q <= '0;
      side_o_q   <= '0;
      price_o_q  <= '0;
      qty_o_q    <= '0;
      error_o_q  <= '0;
      spare0_o_q <= '0;
    end else begin
      valid_o_q  <= valid_o_d;
      market_o_q <= market_o_d;
      side_o_q   <= side_o_d;
      price_o_q  <= price_o_d;
      qty_o_q    <= qty_o_d;
      error_o_q  <= error_o_d;
      spare0_o_q <= 1'b0;
    end
  end

  assign valid_o  = valid_o_q;
  assign market_o = market_o_q;
  assign side_o   = side_o_q;
  assign price_o  = price_o_q;
  assign qty_o    = qty_o_q;
  assign error_o  = error_o_q;
  assign spare0_o = spare0_o_q;

endmodule
