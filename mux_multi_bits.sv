// this code is written for CSE 469 Lab 1, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// the following module is a mux that accept a 3 bit select signal that select among 8 64-bit signals

`timescale 1ns/10ps

// select from 4 64-bit signals
module mux64x4_1 (
  input  logic [1:0] sel,
  input  logic [63:0] in00, in01, in10, in11,
  output logic [63:0] out
);	 

	genvar i;
	
	generate
		for (i = 0; i < 64; i = i + 1) begin: generated_muxes	
			mux4_1 multiplexor (.sel, 
			                     .i00(in00[i]),
								 .i01(in01[i]),
								 .i10(in10[i]),
								 .i11(in11[i]),
								 .out(out[i]));
		end
	endgenerate

endmodule  // mux64x4_1


// select from 2 64-bit signals
module mux64x2_1 (
  input  logic sel,
  input  logic [63:0] in0, in1,
  output logic [63:0] out
);	 

	genvar i;

	generate
		for (i = 0; i < 64; i = i + 1) begin: generated_muxes	
			mux2_1 multiplexor (.sel(sel),
								.i0(in0[i]),
								.i1(in1[i]),	                     
								.out(out[i]));
		end
	endgenerate

endmodule  // mux64x2_1

// select from 2 32-bit signals
module mux32x2_1 (
  input  logic sel,
  input  logic [31:0] in0, in1,
  output logic [31:0] out
);	 

	genvar i;

	generate
		for (i = 0; i < 32; i = i + 1) begin: generated_muxes	
			mux2_1 multiplexor (.sel(sel),
								.i0(in0[i]),
								.i1(in1[i]),	                     
								.out(out[i]));
		end
	endgenerate

endmodule  // mux32x2_1

// select from 2 5-bit signals
module mux5x2_1 (
  input  logic sel,
  input  logic [4:0] in0, in1,
  output logic [4:0] out
);	 

	genvar i;

	generate
		for (i = 0; i < 5; i = i + 1) begin: generated_muxes	
			mux2_1 multiplexor (.sel, 
			                     .i0(in0[i]),
			                     .i1(in1[i]),
			                     .out(out[i]));
		end
	endgenerate

endmodule  // mux5x2_1

module mux64x32_1 (
  input  logic [4:0] sel,
  input  logic [31:0] [63:0] in,
  output logic [63:0] out
);	 

	genvar i;
	
	generate
		for (i = 0; i < 64; i = i + 1) begin: generated_muxes	
			mux32_1 multiplexor (.sel, 
			                     .in({in[31][i], in[30][i], in[29][i], in[28][i], in[27][i], in[26][i], in[25][i], in[24][i],
	                                in[23][i], in[22][i], in[21][i], in[20][i], in[19][i], in[18][i], in[17][i], in[16][i],
									        in[15][i], in[14][i], in[13][i], in[12][i], in[11][i], in[10][i], in[9][i],  in[8][i],
									        in[7][i],  in[6][i],  in[5][i],  in[4][i],  in[3][i],  in[2][i],  in[1][i],  in[0][i]}),
									   .out(out[i]));
		end
	endgenerate

endmodule  // mux64x32_1

module mux64x8_1 (
  input  logic [2:0] sel,
  input  logic [7:0] [63:0] in,
  output logic [63:0] out
);	 

	genvar i;
	
	generate
		for (i = 0; i < 64; i = i + 1) begin: generated_muxes	
			mux8_1 multiplexor (.sel, 
			                     .in({in[7][i], in[6][i], in[5][i], in[4][i], in[3][i], in[2][i], in[1][i], in[0][i]}),
									   .out(out[i]));
		end
	endgenerate

endmodule  // mux64x8_1


// the following module is a mux that accept a 3 bit select signaal that select among 8 4-bit signals
module mux4x8_1 (
  input  logic [2:0] sel,
  input  logic [7:0] [3:0] in,
  output logic [3:0] out
);	 

	genvar i;
	
	generate
		for (i = 0; i < 4; i = i + 1) begin: generated_muxes	
			mux8_1 multiplexor (.sel, 
			                     .in({in[7][i], in[6][i], in[5][i], in[4][i], in[3][i], in[2][i], in[1][i], in[0][i]}),
									   .out(out[i]));
		end
	endgenerate

endmodule  // mux4x8_1

// the following module is a mux select between 4 2-bit signals
module mux4x2_1 (
	input logic [1:0] sel,
	input logic [1:0] in00, in01, in10, in11,
	output logic [1:0] out
);

	genvar i;

	generate
		for (i = 0; i < 2; i = i + 1) begin: generated_muxes	
			mux4_1 multiplexor (.sel(sel),
			                     .i00(in00[i]),
								 .i01(in01[i]),
								 .i10(in10[i]),
								 .i11(in11[i]),
								 .out(out[i]));
		end
	endgenerate

endmodule  // mux2x4_1

// the following module select between 8 2-bit signals
module mux2x8_1 (
	input logic [2:0] sel,
	input logic [15:0] in,
	output logic [1:0] out
);

	genvar i;

	generate
		for (i = 0; i < 2; i = i + 1) begin: generated_muxes	
			mux8_1 multiplexor (.sel(sel),
			                .in({in[i], in[i+2], in[i+4], in[i+6], in[i+8], in[i+10], in[i+12], in[i+14]}),
								 .out(out[i]));
		end
	endgenerate

endmodule  // mux2x4_1


// the following module select between 2 4-bit signals
module mux2x4_1 (
	input logic sel,
	input logic [3:0] in0, in1,
	output logic [3:0] out
);

	genvar i;

	generate
		for (i = 0; i < 4; i = i + 1) begin: generated_muxes	
			mux2_1 multiplexor (.sel(sel),
			                     .i0(in0[i]),
								 .i1(in1[i]),
								 .out(out[i]));
		end
	endgenerate

endmodule  // mux2x4_1