
`timescale 1ns/10ps
module ripple_carry_adder_64 (sub, A, B, sum, overflow, carry_out);
	input  logic sub;
	input  logic [63:0] A, B;
	output logic [63:0] sum;
	output logic overflow, carry_out;
	
	logic [64:0] C;
	assign C[0] = sub;
	
	xor #10 (overflow, C[64], C[63]);
	assign carry_out = C[64];
	
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin: ALU_adder
			full_adder generated_adder(.sub(sub), .a(A[i]), .b(B[i]), .c_in(C[i]), .c_out(C[i+1]), .sum(sum[i]));
		end
	endgenerate
	
	
endmodule  // ripple_carry_adder_64

module full_adder (sub, a, b, c_in, c_out, sum);
	input  logic sub, a, b, c_in;
	output logic c_out, sum;
	
	logic b_adj;
	
	// Changes b if the adder is set to subtract mode
	xor #10 (b_adj, b, sub);
	
	// Sum
	logic sum_temp;
	xor #10 (sum_temp, a, b_adj);
	xor #10 (sum, sum_temp, c_in);
	
	// Carry Out
	
	logic and1, and2, and3, or1;
	
	and #10 (and1, a, b_adj);
	and #10 (and2, b_adj, c_in);
	and #10 (and3, c_in, a);
	
	 or #10 (or1, and1, and2);
	 or #10 (c_out, or1, and3);
	
endmodule  // full_adder