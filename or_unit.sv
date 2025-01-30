// this code is written for CSE 469 Lab 2, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// the following code 64-bit or gate which also resposible for setting the flags negative, zero, overflow, and carry_out

`timescale 1ns/10ps
module or_unit (
    input logic [63:0] A, B,
    output logic [63:0] result,
    output logic [3:0] flags
);

    genvar i;
    generate 
        for (i = 0; i < 64; i = i + 1) begin: generated_or
            //TODO: Check if they like this
            or #10 or_gate (result[i], A[i], B[i]);
        end
    endgenerate

    // set flags
    assign flags[3] = result[63]; // they said they allow this
    // use a 64-bit or gate to set the zero flag
	 logic not_zero;
	 or64_1 or_gate_64 (.in(result), .out(not_zero));
	 not #10 (flags[2], not_zero);
    // we don't care about overflow and carry_out

endmodule  // or_unit