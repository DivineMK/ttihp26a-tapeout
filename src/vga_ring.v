/*
 * Hypnotic concentric rings effect
 * ui_in[0] = speed (0=slow, 1=fast)
 * ui_in[1] = direction (0=outward, 1=inward)
 *
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module vga_ring (
    input wire [1:0] ui_in,
    input wire clk,
    input wire rst_n,

    input wire [9:0] pix_x,
    input wire [9:0] pix_y,
    input wire video_active,

    output wire [1:0] R,
    output wire [1:0] G,
    output wire [1:0] B
);

  // Frame counter for animation
  reg [9:0] frame;

  // Control inputs
  wire speed = ui_in[0];  // 0=slow, 1=fast
  wire direction = ui_in[1];  // 0=outward, 1=inward

  // Centered coordinates (signed)
  wire signed [10:0] cx = $signed({1'b0, pix_x}) - 11'sd320;
  wire signed [10:0] cy = $signed({1'b0, pix_y}) - 11'sd240;

  // Absolute values
  wire [9:0] abs_x = cx[10] ? (~cx[9:0] + 1'b1) : cx[9:0];
  wire [9:0] abs_y = cy[10] ? (~cy[9:0] + 1'b1) : cy[9:0];

  // Distance approximation (max + min/2)
  wire [9:0] max_d = (abs_x > abs_y) ? abs_x : abs_y;
  wire [9:0] min_d = (abs_x < abs_y) ? abs_x : abs_y;
  wire [9:0] radius = max_d + {1'b0, min_d[9:1]};

  // Animated radius for concentric rings with direction control
  wire [7:0] anim_offset = frame[6:0] + frame[6:0];
  wire [7:0] anim_radius = direction ? (radius[7:0] - anim_offset) : (radius[7:0] + anim_offset);

  // Final color outputs (hypnotic concentric rings)
  assign R = anim_radius[5:4] & {2{video_active}};
  assign G = anim_radius[6:5] & {2{video_active}};
  assign B = anim_radius[7:6] & {2{video_active}};

  // Frame counter for animation with variable speed
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      frame <= 0;
    end else begin
      if (pix_x == 0 && pix_y == 0) frame <= frame + (speed ? 10'd2 : 10'd1);
    end
  end

  // Unused inputs
  // wire _unused = &{ena, uio_in, ui_in[7:2], radius[9:8], frame[9:7], min_d[0], anim_radius[3:0], 1'b0};

endmodule
