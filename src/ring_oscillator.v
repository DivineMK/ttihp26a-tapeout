/*******************************************************************************
 * Credit: https://github.com/anujic/anujic_ttihp26a/blob/main/src/ring_oscillator.sv
 * Module: ring_oscillator
 * Project: Tiny Tapeout TRNG
 * * Description:
 * A free-running combinatorial ring oscillator used as the primary 
 * physical entropy source for the TRNG. It relies on the inherent phase 
 * noise (jitter) of standard logic gates to generate unpredictability.
 * * IMPORTANT SYNTHESIS NOTICE: 
 * To prevent synthesis tools (like Yosys) from optimizing away the 
 * combinatorial loop, this module MUST manually instantiate foundry-specific 
 * standard cells (e.g., IHP inverters) and utilize synthesis 
 * compiler directives such as (* keep = "true" *).
 * * Parameters:
 * - DEPTH : Controls the length of the inverter chain. To maintain 
 * oscillation, the total number of instantiated inverters must 
 * always be odd (e.g., 2 * DEPTH + 1).
 * * I/O Interface:
 * Outputs:
 * - bit_o : The raw, asynchronous, high-frequency oscillating signal. 
 * (Note: This signal is highly unstable and must be routed into 
 * the D-input of a synchronous sampling flip-flop externally).
 ******************************************************************************/

module ring_oscillator #(
    parameter DEPTH = 3
) (
    output logic bit_o  // randomly sampled bit
);
  localparam NUM_INVS = (2 * DEPTH) + 1;
`ifdef SIM
  logic sim_osc;

  // Initialize the oscillator so it doesn't get stuck at 'X'
  initial begin
    sim_osc = 1'b0;
  end

  // Toggle the signal with an artificial delay. 
  // The delay scales with DEPTH so ro_3, ro_5, and ro_7 will drift apart.
  always begin
    #(DEPTH * 2 + 1) sim_osc = ~sim_osc;
  end

  assign bit_o = sim_osc;

`else
  (* keep = "true" *) logic [NUM_INVS-1:0] inv_array;

  genvar i;
  generate
    for (i = 0; i < NUM_INVS; i = i + 1) begin
      if (i == 0) begin
        (* keep = "true" *) sg13g2_inv_1 inv (
            .Y(inv_array[0]),
            .A(inv_array[NUM_INVS-1])
        );
      end else begin
        (* keep = "true" *) sg13g2_inv_1 inv (
            .Y(inv_array[i]),
            .A(inv_array[i-1])
        );
      end
    end
  endgenerate

  assign bit_o = inv_array[0];
`endif

endmodule
