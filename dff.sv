// this code is written for CSE 469 Lab 3, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// This file contains all the dffs used in the CPU

`timescale 1ns/10ps

module DFF_multi #(parameter N = 1) (
	input  logic clk,
	input  logic reset,
	 input  logic wr_en,
	input  logic [N-1:0] d,
	output logic [N-1:0] q
);

	genvar i;
	generate
		for (i = 0; i < N; i = i + 1) begin : dff_gen
			D_FF_en d0(.clk(clk), .reset(reset), .wr_en(wr_en), .d(d[i]), .q(q[i]));
		end
	endgenerate

endmodule  // DFF_multi



module DFF_32 (
	input  logic clk,
	input  logic reset,
	 input  logic wr_en,
	input  logic [31:0] d,
	output logic [31:0] q
);

	DFF_16 d0(.clk, .reset, .wr_en, .d(d[15:0]),   .q(q[15:0]));
	DFF_16 d1(.clk, .reset, .wr_en, .d(d[31:16]),  .q(q[31:16]));

endmodule  // DFF_32

module DFF_16 (
    input  logic clk,
    input  logic reset,
	 input  logic wr_en,
    input  logic [15:0] d,
    output logic [15:0] q
);

    DFF_4 d0(.clk, .reset, .wr_en, .d(d[3:0]),   .q(q[3:0]));
    DFF_4 d1(.clk, .reset, .wr_en, .d(d[7:4]),   .q(q[7:4]));
    DFF_4 d2(.clk, .reset, .wr_en, .d(d[11:8]),  .q(q[11:8]));
    DFF_4 d3(.clk, .reset, .wr_en, .d(d[15:12]), .q(q[15:12]));

endmodule  // DFF_16

module DFF_4 (
    input  logic clk,
    input  logic reset,
	 input  logic wr_en,
    input  logic [3:0] d,
    output logic [3:0] q
);
    D_FF_en d0(.clk, .reset, .wr_en, .d(d[0]), .q(q[0]));
	 D_FF_en d1(.clk, .reset, .wr_en, .d(d[1]), .q(q[1]));
	 D_FF_en d2(.clk, .reset, .wr_en, .d(d[2]), .q(q[2]));
	 D_FF_en d3(.clk, .reset, .wr_en, .d(d[3]), .q(q[3]));

endmodule  // DFF_4


module D_FF_en (clk, reset, wr_en, d, q);
	input  logic clk, reset;
	input  logic wr_en, d;
	output logic q;
	
	logic and1, and2, or1, not_wr_en;
	
	not #10 (not_wr_en, wr_en);
	
	and #10 (and1, q, not_wr_en);
	and #10 (and2, d, wr_en);
	
	or (or1, and1, and2);
	
	D_FF d0(.q, .d(or1), .reset, .clk);

endmodule  // D_FF_en


module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
	always_ff @(posedge clk)
		if (reset)
			q <= 0; // On reset, set to 0
		else
			q <= d; // Otherwise out = d
endmodule 