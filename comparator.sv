`timescale 1ns/10ps
module comparator (Reg1, Reg2, equal);

	input  logic [4:0] Reg1, Reg2;
	output logic equal;
	
	 logic [4:0] xor_results;
    logic all_zero;

    // xor each bit of in0 and in1
    genvar i;

    generate
        for (i = 0; i < 5; i = i + 1) begin: generated_xor
            xor #10 (xor_results[i], Reg1[i], Reg2[i]);
        end
    endgenerate

    // check if all bits are zero
	 logic or1, or2, or3;
	 
	 or #10 (or1, xor_results[0], xor_results[1]);
	 or #10 (or2, xor_results[2], xor_results[3]);
	 or #10 (or3, xor_results[4], or1);
	 or #10 (all_zero, or2, or3);

    // negate the result
	 not #10 (equal, all_zero);
	 
endmodule  // comparator
