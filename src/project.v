/*
 * Copyright (c) 2025 Khanh Lo
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_lkhanh_vga_trng (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out  = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  hvsync_generator i_hvsync_gen (
      .clk(clk),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(video_active),
      .hpos(pix_x),
      .vpos(pix_y)
  );

  // always @(*) begin
  //   case (ui_in[3:2])
  //     2'd0: begin
  //       R = i_vga_stripe.R;
  //       G = i_vga_stripe.G;
  //       B = i_vga_stripe.B;
  //     end
  //     2'd1: begin
  //       R = i_vga_gamepad.R;
  //       G = i_vga_gamepad.G;
  //       B = i_vga_gamepad.B;
  //     end
  //     2'd2: begin
  //       R = i_vga_checker.R;
  //       G = i_vga_checker.G;
  //       B = i_vga_checker.B;
  //     end
  //     2'd3: begin
  //       R = i_vga_ring.R;
  //       G = i_vga_ring.G;
  //       B = i_vga_ring.B;
  //     end
  //     default: begin
  //       R = i_vga_stripe.R;
  //       G = i_vga_stripe.G;
  //       B = i_vga_stripe.B;
  //     end
  //   endcase
  // end

  wire [1:0] sel = ui_in[3:2];
  assign R = (sel == 2'd0) ? i_vga_stripe.R : 
             (sel == 2'd1) ? i_vga_gamepad.R :
             (sel == 2'd2) ? i_vga_checker.R : 
             i_vga_ring.R;
  assign G = (sel == 2'd0) ? i_vga_stripe.G : 
             (sel == 2'd1) ? i_vga_gamepad.G :
             (sel == 2'd2) ? i_vga_checker.G : 
             i_vga_ring.R;
  assign B = (sel == 2'd0) ? i_vga_stripe.B : 
             (sel == 2'd1) ? i_vga_gamepad.B :
             (sel == 2'd2) ? i_vga_checker.B : 
             i_vga_ring.B;

  vga_checker i_vga_checker (
      .ui_in,
      .pix_x,
      .pix_y,

      .rst_n,
      .video_active,
      .vsync,
      .R(),
      .G(),
      .B()
  );

  vga_ring i_vga_ring (
      .ui_in(ui_in[1:0]),
      .pix_x,
      .pix_y,

      .clk,
      .rst_n,
      .video_active,
      .R(),
      .G(),
      .B()
  );

  vga_stripe i_vga_stripe (
      .ui_in(ui_in[1:0]),
      .pix_x,
      .pix_y,

      .rst_n,
      .video_active,
      .vsync,
      .R(),
      .G(),
      .B()
  );

  vga_gamepad i_vga_gamepad (
      .pix_x,
      .pix_y,

      .clk,
      .rst_n,
      .video_active,
      .R(),
      .G(),
      .B()
  );

endmodule
