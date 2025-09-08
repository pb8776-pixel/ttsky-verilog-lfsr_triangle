`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a VCD file
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // Testbench signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate DUT
  tt_um_sierpinski_lfs user_project (
`ifdef GL_TEST
      .VPWR   (VPWR),
      .VGND   (VGND),
`endif
      .clk    (clk),
      .rst_n  (rst_n),
      .ena    (ena),
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe)
  );

  // Generate clock: 100MHz
  initial clk = 0;
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    // Initialize
    rst_n  = 0;
    ena    = 0;
    ui_in  = 8'b0;
    uio_in = 8'b0;

    // Apply reset
    #20;
    rst_n = 1;
    ena   = 1;

    // Run for 200ns (~20 cycles)
    #200;

    $finish;
  end

endmodule
