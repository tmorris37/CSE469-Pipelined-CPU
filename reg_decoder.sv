// this code is written for CSE 469 Lab 1, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// a decoder file to translate a 5-bit register address to a 32-bit binary bus where only one bit is high

`timescale 1ns/10ps

module reg_decoder (addr, bus);
    input  logic [4:0] addr;
    output logic [31:0] bus;

    demux_1_32 decoder (.sel(addr), .in(1'b1), .out(bus));

endmodule  // reg_decoder

// A 1:32 demux
module demux_1_32(sel, in, out);
	input  logic [4:0] sel;
	input  logic in;
	output logic [31:0] out;
	
	logic [1:0] d0_out;
	
	demux_1_2 d0 (.sel(sel[4]), .in, .out(d0_out));
	
	demux_1_16 d1 (.sel(sel[3:0]), .in(d0_out[0]), .out(out[15:0]));
	demux_1_16 d2 (.sel(sel[3:0]), .in(d0_out[1]), .out(out[31:16]));
	
endmodule  // demux_1_32

// A 1:16 demux
module demux_1_16(sel, in, out);
	input  logic [3:0] sel;
	input  logic in;
	output logic [15:0] out;
	
	logic [3:0] d0_out;
	
	demux_1_4 d0 (.sel(sel[3:2]), .in, .out(d0_out));
	
	demux_1_4 d1 (.sel(sel[1:0]), .in(d0_out[0]), .out(out[3:0]));
	demux_1_4 d2 (.sel(sel[1:0]), .in(d0_out[1]), .out(out[7:4]));
	demux_1_4 d3 (.sel(sel[1:0]), .in(d0_out[2]), .out(out[11:8]));
	demux_1_4 d4 (.sel(sel[1:0]), .in(d0_out[3]), .out(out[15:12]));
	
endmodule  // demux_1_16

// A 1:4 demux
module demux_1_4(sel, in, out);
	input  logic [1:0] sel;
	input  logic in;
	output logic [3:0] out;
	
	logic [1:0] d0_out;
	
	demux_1_2 d0 (.sel(sel[1]), .in, .out(d0_out));
	
	demux_1_2 d1 (.sel(sel[0]), .in(d0_out[0]), .out(out[1:0]));
	demux_1_2 d2 (.sel(sel[0]), .in(d0_out[1]), .out(out[3:2]));
	
endmodule  // demux_1_4

// A 1:2 demux
module demux_1_2(sel, in, out);
	input  logic sel;
	input  logic in;
	output logic [1:0] out;

	logic not_sel;
	not (not_sel, sel);
	
	and (out[0], not_sel, in);
	and (out[1],     sel, in);
endmodule  // demux_1_2
