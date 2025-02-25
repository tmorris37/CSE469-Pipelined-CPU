// this code is written for CSE 469 Lab 3, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// This is the top level testbench  module for the CPU
`timescale 1ns/10ps

module cpu_tb();

	// define signals
	logic clk, Reg_clk, reset;
	
	logic [3:0]  test_selector;
	logic [31:0] instruction;
	logic [63:0] PC;
	
	logic	[63:0]	MEM_Address;
	logic				MemWrite;
	logic				MemRead;
	logic	[3:0]		mem_xfer_size;
	logic	[63:0]	MEM_Write_Data;
	logic	[63:0]	MEM_Read_Data;
	
	// instantiate modules
	cpu dut (.*);
	instructmem i_mem (.clk, .test_selector, .address(PC), .instruction);
	datamem d_mem (.address(MEM_Address), .write_enable(MemWrite), .read_enable(MemRead), .write_data(MEM_Write_Data), .clk, .xfer_size(mem_xfer_size), .read_data(MEM_Read_Data));
	
	// set up the clock
	parameter CLOCK_PERIOD=100000;
	initial begin
	 clk <= 0;
	 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
	 Reg_clk <= 0;
	 forever #(CLOCK_PERIOD/4) Reg_clk <= ~Reg_clk;
	end
	
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	initial begin
	
		$display("Running benchmark: test01_AddiB");
		test_selector <= 4'd1; reset <= 1; @(posedge clk);
		                       reset <= 0; @(posedge clk);
								                 @(posedge (instruction == 32'b00010100000000000000000000000000));
									   repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0] == 64'd0 &&
		       dut.ID_RegFile.register_outs[1] == 64'd1 &&
				 dut.ID_RegFile.register_outs[2] == 64'd2 &&
		       dut.ID_RegFile.register_outs[3] == 64'd3 &&
				 dut.ID_RegFile.register_outs[4] == 64'd4
				 );
				                 reset <= 1; @(posedge clk);
												  
		$display("Running benchmark: test02_AddsSubs");
		test_selector <= 4'd2; reset <= 0; @(posedge clk);
								                 @(posedge (instruction == 32'b00010100000000000000000000000000));
										repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0] ==  64'd1 &&
		       dut.ID_RegFile.register_outs[1] == -64'd1 &&
				 dut.ID_RegFile.register_outs[2] ==  64'd2 &&
		       dut.ID_RegFile.register_outs[3] == -64'd3 &&
				 dut.ID_RegFile.register_outs[4] == -64'd2 &&
				 dut.ID_RegFile.register_outs[5] == -64'd5 &&
				 dut.ID_RegFile.register_outs[6] ==  64'd0 &&
				 dut.ID_RegFile.register_outs[7] == -64'd6
				 );
				 
				                 reset <= 1; @(posedge clk);
		
		$display("Running benchmark: test03_CbzB");
		test_selector <= 4'd3; reset <= 0; @(posedge clk);
								                 @(posedge (instruction == 32'b00010100000000000000000000000000));
										repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0] == 64'd1  &&
		       dut.ID_RegFile.register_outs[1] == 64'd0  &&
				 // dut.ID_RegFile.register_outs[2] == 64'd4  &&
		       dut.ID_RegFile.register_outs[3] == 64'd1  &&
				 dut.ID_RegFile.register_outs[4] == 64'd31 && 
				 dut.ID_RegFile.register_outs[5] == 64'd0
				 );
				                 reset <= 1; @(posedge clk);
		
		$display("Running benchmark: test04_LdurStur");
		test_selector <= 4'd4; reset <= 0; @(posedge clk);
								                 @(posedge (instruction == 32'b00010100000000000000000000000000));
										repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0] == 64'd1  &&
		       dut.ID_RegFile.register_outs[1] == 64'd2  &&
				 dut.ID_RegFile.register_outs[2] == 64'd3  &&
		       dut.ID_RegFile.register_outs[3] == 64'd8  &&
				 dut.ID_RegFile.register_outs[4] == 64'd11 &&
				 dut.ID_RegFile.register_outs[5] == 64'd1  &&
				 dut.ID_RegFile.register_outs[6] == 64'd2  &&
				 dut.ID_RegFile.register_outs[7] == 64'd3  &&
				 d_mem.mem[0]  == 1 &&
				 d_mem.mem[8]  == 2 &&
				 d_mem.mem[16] == 3
				 );
				                 reset <= 1; @(posedge clk);
		
		$display("Running benchmark: test05_Blt");
		test_selector <= 4'd5; reset <= 0; @(posedge clk);
								                 @(posedge (instruction == 32'b00010100000000000000000000000000));
										repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0] == 64'd1 &&
		       dut.ID_RegFile.register_outs[1] == 64'd1 
				 );
				                 reset <= 1; @(posedge clk);
		
		$display("Running benchmark: test06_BlBr");
		test_selector <= 4'd6; reset <= 0; @(posedge clk);
								                 @(posedge (instruction == 32'b00010100000000000000000000000000));
										repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0]  == 64'd1  &&
		       dut.ID_RegFile.register_outs[1]  == 64'd0  &&
				 dut.ID_RegFile.register_outs[2]  == 64'd0  &&
		       dut.ID_RegFile.register_outs[3]  == 64'd1  &&
				 dut.ID_RegFile.register_outs[4]  == 64'd52 &&
				 dut.ID_RegFile.register_outs[5]  == 64'd64 &&
				 dut.ID_RegFile.register_outs[29] == 64'd20 &&
				 dut.ID_RegFile.register_outs[30] == 64'd68
				 );
				                 reset <= 1; @(posedge clk);
		
		$display("Running benchmark: test10_forwarding");
		test_selector <= 4'd10; reset <= 0; @(posedge clk);
								                  @(posedge (instruction == 32'b00010100000000000000000000000000));
										 repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0]  ==  64'd0  &&
		       dut.ID_RegFile.register_outs[1]  ==  64'd8  &&
				 // dut.ID_RegFile.register_outs[2]  ==  64'd4  &&
		       dut.ID_RegFile.register_outs[3]  ==  64'd5  &&
				 dut.ID_RegFile.register_outs[4]  ==  64'd7  &&
				 dut.ID_RegFile.register_outs[5]  ==  64'd2  &&
				 dut.ID_RegFile.register_outs[6]  == -64'd2  &&
				 dut.ID_RegFile.register_outs[7]  == -64'd2  &&
				 dut.ID_RegFile.register_outs[8]  ==  64'd0  &&
		       dut.ID_RegFile.register_outs[9]  ==  64'd1  &&
				 dut.ID_RegFile.register_outs[10] == -64'd4  &&
		       dut.ID_RegFile.register_outs[14] ==  64'd5  &&
				 dut.ID_RegFile.register_outs[15] ==  64'd8  &&
				 dut.ID_RegFile.register_outs[16] ==  64'd9  &&
				 dut.ID_RegFile.register_outs[17] ==  64'd1  &&
				 dut.ID_RegFile.register_outs[18] ==  64'd99 &&
				 d_mem.mem[0]  == 8 &&
				 d_mem.mem[8]  == 5
				 );
				                 reset <= 1; @(posedge clk);
		
		$display("Running benchmark: test11_Sort");
		test_selector <= 4'd11; reset <= 0; @(posedge clk);
								                  @(posedge (instruction == 32'b00010100000000000000000000000000));
										 repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[11] == 64'd1  &&
		       dut.ID_RegFile.register_outs[12] == 64'd2  &&
				 dut.ID_RegFile.register_outs[13] == 64'd3  &&
		       dut.ID_RegFile.register_outs[14] == 64'd4  &&
				 dut.ID_RegFile.register_outs[15] == 64'd5  &&
				 dut.ID_RegFile.register_outs[16] == 64'd6  &&
				 dut.ID_RegFile.register_outs[17] == 64'd7  &&
				 dut.ID_RegFile.register_outs[18] == 64'd8  &&
				 dut.ID_RegFile.register_outs[19] == 64'd9  &&
				 dut.ID_RegFile.register_outs[20] == 64'd10
				 );
				                 reset <= 1; @(posedge clk);
		
		$display("Running benchmark: test12_Fibonacci");
		test_selector <= 4'd12; reset <= 0; @(posedge clk);
								                  @(posedge (instruction == 32'b00010100000000000000000000000000));
										 repeat (5) @(posedge clk);
		assert(dut.ID_RegFile.register_outs[0]  == 64'd6  &&
		       dut.ID_RegFile.register_outs[1]  == 64'd8  &&
				 dut.ID_RegFile.register_outs[28] == 64'd8  &&
		       dut.ID_RegFile.register_outs[30] == 64'd196
				 );
				                 reset <= 1; @(posedge clk);
		
		$stop;  // pause the simulation
	end
	
endmodule