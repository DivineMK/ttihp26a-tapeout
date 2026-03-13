/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module vga_stripe (
    input wire [1:0] ui_in,
    input wire pix_x,
    input wire pix_y,

    output wire [1:0] R,
    output wire [1:0] G,
    output wire [1:0] B
);

  reg  [9:0] counter;
  wire [9:0] moving_x = pix_x + counter;

  assign R = video_active ? {moving_x[5], pix_y[2]} : 2'b00;
  assign G = video_active ? {moving_x[6], pix_y[2]} : 2'b00;
  assign B = video_active ? {moving_x[7], pix_y[5]} : 2'b00;

  wire speed = ui_in[0] ? 2'd3 : 1'd0;
  wire direction = ui_in[1];

  always @(posedge vsync, negedge rst_n) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= direction ? counter + speed : counter - speed;
    end
  end

  // Suppress unused signals warning
  wire _unused_ok_ = &{moving_x, pix_y};

endmodule
