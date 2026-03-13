/*
 * Copyright (c) 2025 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module vga_gamepad (
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,

    input wire clk,
    input wire rst_n,
    input wire video_active,

    output wire [1:0] R,
    output wire [1:0] G,
    output wire [1:0] B
);

  // Colors
  localparam [5:0] BLACK = {2'b00, 2'b00, 2'b00};
  localparam [5:0] WHITE = {2'b11, 2'b11, 2'b11};

  // Glyph definitions (8x8), packed into 64-bit vectors.
  localparam [63:0] LEFT_GLYPH = {
    8'b00010000,
    8'b00110000,
    8'b01110000,
    8'b11111111,
    8'b01110000,
    8'b00110000,
    8'b00010000,
    8'b00000000
  };
  localparam [63:0] RIGHT_GLYPH = {
    8'b00001000,
    8'b00001100,
    8'b00001110,
    8'b11111111,
    8'b00001110,
    8'b00001100,
    8'b00001000,
    8'b00000000
  };
  localparam [63:0] UP_GLYPH = {
    8'b00010000,
    8'b00111000,
    8'b01111100,
    8'b11111110,
    8'b00010000,
    8'b00010000,
    8'b00010000,
    8'b00010000
  };
  localparam [63:0] DOWN_GLYPH = {
    8'b00010000,
    8'b00010000,
    8'b00010000,
    8'b00010000,
    8'b11111110,
    8'b01111100,
    8'b00111000,
    8'b00010000
  };
  localparam [63:0] A_GLYPH = {
    8'b00111100,
    8'b01100110,
    8'b01100110,
    8'b01111110,
    8'b01100110,
    8'b01100110,
    8'b01100110,
    8'b00000000
  };
  localparam [63:0] B_GLYPH = {
    8'b01111100,
    8'b01100110,
    8'b01100110,
    8'b01111100,
    8'b01100110,
    8'b01100110,
    8'b01111100,
    8'b00000000
  };
  localparam [63:0] X_GLYPH = {
    8'b11000011,
    8'b01100110,
    8'b00111100,
    8'b00011000,
    8'b00011000,
    8'b00111100,
    8'b01100110,
    8'b11000011
  };
  localparam [63:0] Y_GLYPH = {
    8'b11000011,
    8'b01100110,
    8'b00111100,
    8'b00011000,
    8'b00011000,
    8'b00011000,
    8'b00011000,
    8'b00011000
  };
  localparam [63:0] L_GLYPH = {
    8'b11100000,
    8'b11100000,
    8'b11100000,
    8'b11100000,
    8'b11100000,
    8'b11111110,
    8'b11111110,
    8'b00000000
  };
  localparam [63:0] R_GLYPH = {
    8'b11111100,
    8'b11100110,
    8'b11100110,
    8'b11111100,
    8'b11111000,
    8'b11111100,
    8'b11101110,
    8'b00000000
  };
  localparam [63:0] SELECT_GLYPH = {
    8'b00011000,
    8'b00100100,
    8'b01000010,
    8'b10000001,
    8'b10000001,
    8'b01000010,
    8'b00100100,
    8'b00011000
  };
  localparam [63:0] START_GLYPH = {
    8'b00011000,
    8'b01011010,
    8'b10011001,
    8'b10011001,
    8'b10011001,
    8'b10000001,
    8'b01000010,
    8'b00111100
  };

  // Glyph positions
  localparam LEFT_X = 48, LEFT_Y = 240;
  localparam RIGHT_X = 144, RIGHT_Y = 240;
  localparam UP_X = 96, UP_Y = 192;
  localparam DOWN_X = 96, DOWN_Y = 288;
  localparam A_X = 560, A_Y = 240;
  localparam B_X = 512, B_Y = 296;
  localparam X_X = 512, X_Y = 184;
  localparam Y_X = 464, Y_Y = 240;
  localparam L_X = 32, L_Y = 92;
  localparam R_X = 592, R_Y = 92;
  localparam SEL_X = 264, SEL_Y = 240;
  localparam STRT_X = 328, STRT_Y = 240;

  // Glyph activation logic
  wire left_act = glyph_active(LEFT_X, LEFT_Y, LEFT_GLYPH);
  wire right_act = glyph_active(RIGHT_X, RIGHT_Y, RIGHT_GLYPH);
  wire up_act = glyph_active(UP_X, UP_Y, UP_GLYPH);
  wire down_act = glyph_active(DOWN_X, DOWN_Y, DOWN_GLYPH);
  wire a_act = glyph_active(A_X, A_Y, A_GLYPH);
  wire b_act = glyph_active(B_X, B_Y, B_GLYPH);
  wire x_act = glyph_active(X_X, X_Y, X_GLYPH);
  wire y_act = glyph_active(Y_X, Y_Y, Y_GLYPH);
  wire l_act = glyph_active(L_X, L_Y, L_GLYPH);
  wire r_act = glyph_active(R_X, R_Y, R_GLYPH);
  wire sel_act = glyph_active(SEL_X, SEL_Y, SELECT_GLYPH);
  wire strt_act = glyph_active(STRT_X, STRT_Y, START_GLYPH);

  // Pressed state logic
  wire any_active = left_act | right_act | up_act | down_act | a_act | b_act |
                   x_act | y_act | l_act | r_act | sel_act | strt_act;

  reg [1:0] r_out;
  reg [1:0] g_out;
  reg [1:0] b_out;
  assign {R, G, B} = {r_out, g_out, b_out};
  // RGB output logic
  always @(posedge clk) begin
    if (~rst_n) begin
      r_out <= 0;
      g_out <= 0;
      b_out <= 0;
    end else begin
      if (video_active) begin
        {r_out, g_out, b_out} <= any_active ? WHITE : BLACK;
      end else begin
        {r_out, g_out, b_out} <= 0;
      end
    end
  end
  // Scaled glyph activation function (4x size)
  // Now uses a 64-bit vector for the glyph.
  function glyph_active;
    input [9:0] x0, y0;
    input [63:0] glyph;
    reg [9:0] x_rel, y_rel;
    /* verilator lint_off UNUSEDSIGNAL */
    reg [63:0] glyph_shifted;
    /* verilator lint_on UNUSEDSIGNAL */
    reg [ 7:0] row;
    begin
      if ((pix_x >= x0) && (pix_x < x0 + 32) && (pix_y >= y0) && (pix_y < y0 + 32)) begin
        x_rel = (pix_x - x0) >> 2;  // Scale coordinates
        y_rel = (pix_y - y0) >> 2;
        // Extract the correct row from the 64-bit glyph.
        // (Row 0 is in bits 63:56, row 7 is in bits 7:0.)
        glyph_shifted = glyph >> ((7 - y_rel) * 8);
        row = glyph_shifted[7:0];
        glyph_active = row[7-x_rel];
      end else begin
        glyph_active = 0;
      end
    end
  endfunction
endmodule
