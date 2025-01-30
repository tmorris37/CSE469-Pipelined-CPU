// this code is written for CSE 469 Lab 2, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// the following code is a mux that accept a 3 bit select signal that select among 8 
// 1-bit signals


`timescale 1ns/10ps

module mux32_1 (
  input logic [4:0] sel,
  input logic [31:0] in,
  output logic out
);

    logic v1, v2;

    mux16_1 m0(.out(v1), .in(in[15:0]), .sel(sel[3:0]));
    mux16_1 m1(.out(v2), .in(in[31:16]), .sel(sel[3:0]));
    mux2_1 m (.out(out), .i0(v1), .i1(v2), .sel(sel[4]));
    
endmodule  // mux32_1


module mux16_1 (
    input logic [3:0] sel,
    input logic [15:0] in,
    output logic out
);

    logic v0, v1, v2, v3;

    mux4_1 m0(.out(v0), .i00(in[0]), .i01(in[1]), .i10(in[2]), .i11(in[3]), .sel(sel[1:0]));
    mux4_1 m1(.out(v1), .i00(in[4]), .i01(in[5]), .i10(in[6]), .i11(in[7]), .sel(sel[1:0]));
    mux4_1 m2(.out(v2), .i00(in[8]), .i01(in[9]), .i10(in[10]), .i11(in[11]), .sel(sel[1:0]));
    mux4_1 m3(.out(v3), .i00(in[12]), .i01(in[13]), .i10(in[14]), .i11(in[15]), .sel(sel[1:0]));
    mux4_1 m4(.out(out), .i00(v0), .i01(v1), .i10(v2), .i11(v3), .sel(sel[3:2]));

endmodule  // mux16_1

module mux8_1 (
    input logic [2:0] sel,
    input logic [7:0] in,
    output logic out
);

    logic v0, v1;
    
    mux4_1 m0(.out(v0), .i00(in[0]), .i01(in[1]), .i10(in[2]), .i11(in[3]), .sel(sel[1:0]));
    mux4_1 m1(.out(v1), .i00(in[4]), .i01(in[5]), .i10(in[6]), .i11(in[7]), .sel(sel[1:0]));
    mux2_1 m (.out(out), .i0(v0), .i1(v1), .sel(sel[2]));

endmodule  // mux16_1


module mux4_1 (
  output logic out,
  input  logic i00, i01, i10, i11, 
  input logic [1:0] sel
);

  logic v0, v1;

  mux2_1 m0(.out(v0), .i0(i00), .i1(i01), .sel(sel[0]));
  mux2_1 m1(.out(v1), .i0(i10), .i1(i11), .sel(sel[0]));
  mux2_1 m (.out(out), .i0(v0), .i1(v1), .sel(sel[1]));
endmodule  // mux4_1


module mux2_1 (
  output logic out
  ,input  logic i0, i1, sel
  );

	logic not_sel, out0, out1;

	not #10 (not_sel, sel);
	and #10 (out0, i0, not_sel);
	and #10 (out1, i1, sel);

	or  #10 (out, out1, out0);

endmodule  // mux2_1