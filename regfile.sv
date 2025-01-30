// this code is written for CSE 469 Lab 1, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// the following code represents an array of 32 registers
// while the last register is always 0 no matter what is written to it

// the register controller has two 5-bit read register and one 5-bit write register
// the controller also has a 64-bit data input 

`timescale 1ns/10ps

module regfile (
    input  logic clk,
    input  logic RegWrite,
    input  logic [4:0] ReadRegister1,
    input  logic [4:0] ReadRegister2,
    input  logic [4:0] WriteRegister,
    input  logic [63:0] WriteData,
    output logic [63:0] ReadData1,
    output logic [63:0] ReadData2
);

    // decode the write_reg
    logic [31:0] write_reg_bus;
    reg_decoder write_reg_decoder (.addr(WriteRegister), .bus(write_reg_bus));

    // 32 register outs
    logic [31:0] [63:0] register_outs;
	 
	 logic [31:0] wr_en_bus;

    // 31 normal registers
	 genvar i;
	 generate
		for (i = 0; i < 31; i = i + 1) begin: X
			and #10 (wr_en_bus[i], RegWrite, write_reg_bus[i]);
			register register_unit (.clk, .reset(1'b0), .wr_en(wr_en_bus[i]), .data_in(WriteData), .data_out(register_outs[i]));
		end
	 endgenerate

    // the last register is always 0
    assign register_outs[31] = 64'h0;

    // use mux to select the read data
    mux64x32_1 mux1 (.sel(ReadRegister1), .in(register_outs), .out(ReadData1));
    mux64x32_1 mux2 (.sel(ReadRegister2), .in(register_outs), .out(ReadData2));

endmodule  // regfile

// the following code represents a single 64 bit register
module register (
    input  logic clk,
    input  logic reset,
	 input  logic wr_en,
    input  logic [63:0] data_in,
    output logic [63:0] data_out
);

    DFF_16 d0(.clk, .reset, .wr_en, .d(data_in[15:0]),  .q(data_out[15:0]));
    DFF_16 d1(.clk, .reset, .wr_en, .d(data_in[31:16]), .q(data_out[31:16]));
    DFF_16 d2(.clk, .reset, .wr_en, .d(data_in[47:32]), .q(data_out[47:32]));
    DFF_16 d3(.clk, .reset, .wr_en, .d(data_in[63:48]), .q(data_out[63:48]));
    
endmodule  // 


