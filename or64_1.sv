// this code is written for CSE 469 Lab 2, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// the following code is a 64-bit or gate that accepts a 64-bit input and output 1 bit output

`timescale 1ns/10ps
module zero_check (in, out);
	input  logic [63:0] in;
	output logic out;
	
	logic not_zero;
	
	or64_1 or_gate (.in, .out(not_zero));
	
	not #10 (out, not_zero);

endmodule  // zero_check


module or64_1(
    output logic out,
    input  logic [63:0] in
);

    logic v0, v1, v2, v3;
    or16_1 or0 (.out(v0), .in(in[15:0]));
    or16_1 or1 (.out(v1), .in(in[31:16]));
    or16_1 or2 (.out(v2), .in(in[47:32]));
    or16_1 or3 (.out(v3), .in(in[63:48]));
    or4_1 or4 (.out(out), .in({v0, v1, v2, v3}));

endmodule  // or64_1

module or32_1(
    output logic out,
    input  logic [31:0] in
);

    logic v0, v1;
    or16_1 or0 (.out(v0), .in(in[15:0]));
    or16_1 or1 (.out(v1), .in(in[31:16]));
    or #10 (out, v0, v1);

endmodule  // or32_1



module or16_1(
    output logic out,
    input  logic [15:0] in
);
    
        logic v0, v1, v2, v3;
        or4_1 or0 (.out(v0), .in({in[0], in[1], in[2], in[3]}));
        or4_1 or1 (.out(v1), .in({in[4], in[5], in[6], in[7]}));
        or4_1 or2 (.out(v2), .in({in[8], in[9], in[10], in[11]}));
        or4_1 or3 (.out(v3), .in({in[12], in[13], in[14], in[15]}));
        or4_1 or4 (.out(out), .in({v0, v1, v2, v3}));

endmodule  // or16_1


module or4_1 (
    output logic out,
    input  logic [3:0] in
);

    logic v0, v1;
    or #10 (v0, in[0], in[1]);
    or #10 (v1, in[2], in[3]);
    or #10 (out, v0, v1);

endmodule  // or4_1