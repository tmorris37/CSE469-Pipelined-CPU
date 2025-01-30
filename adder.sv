
`timescale 1ns/10ps
// flags[3] = negative
// flags[2] = zero
// flags[1] = overflow
// flags[0] = carry_out
module adder (
    input logic [63:0] A, B,
    input logic sub,
    output logic [63:0] sum,
    output logic [3:0] flags
);

    ripple_carry_adder_64 adder_unit (.sub(sub), .A(A), .B(B), .sum(sum), .overflow(flags[1]), .carry_out(flags[0]));
	 
	 // negative flag
	 assign flags[3] = sum[63];
	 // zero flag
	 logic not_zero;
	 or64_1 or_gate_64 (.in(sum), .out(not_zero));
	 not #10 (flags[2], not_zero);

endmodule  // adder