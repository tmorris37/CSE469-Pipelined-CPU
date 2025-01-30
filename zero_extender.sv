// This code is written for CSE 469 Lab 3, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// This code is a zero_extender that extend a N bit bus to 64 bits

`timescale 1ns/10ps
module zero_extender #(parameter N = 32) (in, out);
	input  logic [N-1:0] in;
	output logic [63:0] out;

	// the first 64-N bits are zeros
	assign out = {{(64-N){1'b0}}, in};
 
endmodule  // zero_extender
