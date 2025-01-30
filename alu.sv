// this code is written for CSE 469 Lab 2, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// the alu here is basically a big mux that selects between the different operations. The operations are defined by the cntrl input. The operations are:
// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
// the alu is also responsible for setting the flags negative, zero, overflow, and carry_out. The flags are set based on the result of the operation
// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

`timescale 1ns/10ps
module alu (
    input logic [63:0] A, B,
    input logic [2:0] cntrl,
    output logic [63:0] result,
    output logic negative, zero, overflow, carry_out
);

	// output of the adder
	logic [63:0] adder_out;
	logic [3:0] adder_flags;
	adder adds (.A(A), .B(B), .sub(cntrl[0]), .sum(adder_out), .flags(adder_flags));

	// output of the and gate
	logic [63:0] and_out;
	logic [3:0] and_flags;
	and_unit ands (.A(A), .B(B), .result(and_out), .flags(and_flags));

	// output of the or gate
	logic [63:0] or_out;
	logic [3:0] or_flags;
	or_unit ors (.A(A), .B(B), .result(or_out), .flags(or_flags));

	// output of the xor gate
	logic [63:0] xor_out;
	logic [3:0] xor_flags;
	xor_unit xors (.A(A), .B(B), .result(xor_out), .flags(xor_flags));

	// output flags of 000
	logic [3:0] b_flags;
	assign b_flags[3] = B[63];

	logic not_zero;
	or64_1 or_gate_64 (.in(result), .out(not_zero));
	not #10 (b_flags[2], not_zero);

	// mux to select between the different operations to set output
	mux64x8_1 mux_outputs (
		 .sel(cntrl),
		 .in({64'b0, xor_out, or_out, and_out, adder_out, adder_out, 64'b0, B}),
		 .out(result)
	);
	mux4x8_1 mux_flags (
		 .sel(cntrl),
		 .in({4'b0, xor_flags, or_flags, and_flags, adder_flags, adder_flags, 4'b0, b_flags}),
		 .out({negative, zero, overflow, carry_out})
	);

endmodule  // alu
