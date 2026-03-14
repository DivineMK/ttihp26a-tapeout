/*
 * Copyright (c) 2024 Renaldas Zioma
 * based on the VGA examples by Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module vga_checker (
    input wire [7:0] ui_in,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,

    input wire clk,
    input wire rst_n,
    input wire vsync,
    input wire video_active,

    output wire [1:0] R,
    output wire [1:0] G,
    output wire [1:0] B
);
  // increase counter every frame (vsync happens once per frame)
  reg [9:0] counter_d, counter_q;

  wire [1:0] speed;
  assign speed = ui_in[0] ? 2'd3 : 2'd0;
  wire direction = ui_in[1];
  reg  vsync_q;

  always @(*) begin
    counter_d = counter_q;
    if (vsync_q && !vsync) begin
      counter_d = direction ? counter_d + speed : counter_d - speed;
    end
  end

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      counter_q <= 0;
      vsync_q   <= 0;
    end else begin
      vsync_q   <= vsync;
      counter_q <= counter_d;
    end
  end

  // animate layers
  wire [9:0] layer_a_x = pix_x + counter_q * 16;
  wire [9:0] layer_a_y = pix_y + counter_q * 2;

  wire [9:0] layer_b_x = pix_x + counter_q * 7;
  wire [9:0] layer_b_y = pix_y + counter_q + counter_q / 2;

  wire [9:0] layer_c_x = pix_x + counter_q * 4;
  wire [9:0] layer_c_y = pix_y + counter_q / 2;

  wire [9:0] layer_d_x = pix_x + counter_q * 2;
  wire [9:0] layer_d_y = pix_y + counter_q / 4;

  wire [9:0] layer_e_x = pix_x + counter_q / 2;
  wire [9:0] layer_e_y = pix_y + counter_q / 6;

  //                    checker shape          * transparency using pixel dithering
  wire layer_a = (layer_a_x[8] ^ layer_a_y[8]) & (pix_y[1] ^ pix_x[0]);
  wire layer_b = (layer_b_x[7] ^ layer_b_y[7]) & (~pix_y[0] ^ pix_x[1]);
  wire layer_c = layer_c_x[6] ^ layer_c_y[6];
  wire layer_d = layer_d_x[5] ^ layer_d_y[5];
  wire layer_e = (layer_e_x[4] ^ layer_e_y[4]) & (pix_y[1] ^ pix_x[0]);

  wire [5:0] color_a = ~ui_in[7:2];  // color of the closest layer
  wire [5:0] color_b = color_a ^ 6'b00_10_10;
  wire [5:0] color_c = color_b & 6'b10_10_10;
  wire [5:0] color_de = color_c >> 1;  // color of the two farthest layers
                                       // the layer e also using dithering to darken the color

  assign {R, G, B} =
      video_active ?
        (layer_a ? color_a :
          (layer_b ? color_b : 
            (layer_c ? color_c : 
              (layer_d ? color_de :
                (layer_e ? color_de : 6'b00_00_00))))) : 6'b00_00_00;

endmodule
