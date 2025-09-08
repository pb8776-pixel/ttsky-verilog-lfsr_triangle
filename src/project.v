/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_sierpinski_lfs (
    input  wire clk,         // system clock
    input  wire rst_n,       // active-low reset
    input  wire ena,         // enable signal from Tiny Tapeout
    input  wire [7:0] ui_in, // unused in this design
    output wire [7:0] uo_out,// map LFSR output here
    input  wire [7:0] uio_in,// unused
    output wire [7:0] uio_out, // unused
    output wire [7:0] uio_oe   // unused
);

    // LFSR registers
    reg [7:0] lfsr;      // internal state
    reg [7:0] lfsr_out;  // output register to delay 1 cycle

    // Feedback taps for maximal-length LFSR (x^8 + x^6 + x^5 + x^4 + 1)
    wire feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

    // Update internal LFSR
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            lfsr <= 8'b0000_0001;  // seed value
        else if (ena)
            lfsr <= {lfsr[6:0], feedback};
    end

    // Delay output by 1 cycle so first cycle outputs seed
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            lfsr_out <= 8'b0000_0001;
        else if (ena)
            lfsr_out <= lfsr;
    end

    // Drive outputs
    assign uo_out  = lfsr_out;   // LFSR output
    assign uio_out = 8'b0;       // not used
    assign uio_oe  = 8'b0;       // not used

endmodule
