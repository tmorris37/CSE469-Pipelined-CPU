// This code is written for CSE 469 Lab 3, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// This file extend N-bit input bus to 64-bit output bus

`timescale 1ns/10ps
module sign_extender #(parameter N = 32) (in, out);
	input  logic [N-1:0] in;
	output logic [63:0] out;

	// the first 64-N bits equals to the most significant bit of in (Nth bit)
	assign out = {{(64-N){in[N-1]}}, in};

endmodule  // sign_extender
