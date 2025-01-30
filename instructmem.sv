// Instruction ROM.  Supports reads only, but is initialized based upon the file specified.
// All accesses are 32-bit.  Addresses are byte-addresses, and must be word-aligned (bottom
// two words of the address must be 0).
//
// To change the file that is loaded, edit the filename here:
`define BENCHMARK1  "../benchmarks/test01_AddiB.arm"
`define BENCHMARK2  "../benchmarks/test02_AddsSubs.arm"
`define BENCHMARK3  "../benchmarks/test03_CbzB.arm"
`define BENCHMARK4  "../benchmarks/test04_LdurStur.arm"
`define BENCHMARK5  "../benchmarks/test05_Blt.arm"
`define BENCHMARK6  "../benchmarks/test06_BlBr.arm"

`define BENCHMARK10 "../benchmarks/test10_forwarding.arm"
`define BENCHMARK11 "../benchmarks/test11_Sort.arm"
`define BENCHMARK12 "../benchmarks/test12_Fibonacci.arm"

`timescale 1ns/10ps

// How many bytes are in our memory?  Must be a power of two.
`define INSTRUCT_MEM_SIZE		1024
	
module instructmem (
	input		logic		[63:0]	address,
	input		logic		[3:0]		test_selector,
	output	logic		[31:0]	instruction,
	input		logic					clk	// Memory is combinational, but used for error-checking
	);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	// Make sure size is a power of two and reasonable.
	initial assert((`INSTRUCT_MEM_SIZE & (`INSTRUCT_MEM_SIZE-1)) == 0 && `INSTRUCT_MEM_SIZE > 4);
	
	// Make sure accesses are reasonable.
	always_ff @(posedge clk) begin
		if (address !== 'x) begin // address or size could be all X's at startup, so ignore this case.
			assert(address[1:0] == 0);	// Makes sure address is aligned.
			assert(address + 3 < `INSTRUCT_MEM_SIZE);	// Make sure address in bounds.
		end
	end
	
	// The data storage itself.
	logic [31:0] mem   [`INSTRUCT_MEM_SIZE/4-1:0];
	
	logic [31:0] mem1  [`INSTRUCT_MEM_SIZE/4-1:0];
	logic [31:0] mem2  [`INSTRUCT_MEM_SIZE/4-1:0];
	logic [31:0] mem3  [`INSTRUCT_MEM_SIZE/4-1:0];
	logic [31:0] mem4  [`INSTRUCT_MEM_SIZE/4-1:0];
	logic [31:0] mem5  [`INSTRUCT_MEM_SIZE/4-1:0];
	logic [31:0] mem6  [`INSTRUCT_MEM_SIZE/4-1:0];
	
	logic [31:0] mem10 [`INSTRUCT_MEM_SIZE/4-1:0];
	logic [31:0] mem11 [`INSTRUCT_MEM_SIZE/4-1:0];
	logic [31:0] mem12 [`INSTRUCT_MEM_SIZE/4-1:0];
	
	// Load the program - change the filename to pick a different program.
	initial begin
		$readmemb(`BENCHMARK1,  mem1);
		$readmemb(`BENCHMARK2,  mem2);
		$readmemb(`BENCHMARK3,  mem3);
		$readmemb(`BENCHMARK4,  mem4);
		$readmemb(`BENCHMARK5,  mem5);
		$readmemb(`BENCHMARK6,  mem6);

		$readmemb(`BENCHMARK10, mem10);
		$readmemb(`BENCHMARK11, mem11);
		$readmemb(`BENCHMARK12, mem12);
		
	end
	
	
	// Handle the reads.
	integer i;
	always_comb begin
		if (address + 3 >= `INSTRUCT_MEM_SIZE)
			instruction = 'x;
		else
			instruction = mem[address/4];
	end
	
	always_comb begin
		case (test_selector)
			4'd1:	   mem = mem1;
			4'd2:    mem = mem2;
			4'd3:    mem = mem3;
			4'd4:    mem = mem4;
			4'd5:    mem = mem5;
			4'd6:    mem = mem6;
			4'd10:   mem = mem10;
			4'd11:   mem = mem11;
			4'd12:   mem = mem12;
			default: mem = mem1;
		endcase
	end
		
endmodule

module instructmem_testbench ();

	parameter ClockDelay = 5000;

	logic		[63:0]	address;
	logic					clk;
	logic		[31:0]	instruction;
	
	instructmem dut (.address, .instruction, .clk);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		// Read every location, including just past the end of the memory.
		for (i=0; i <= `INSTRUCT_MEM_SIZE; i = i + 4) begin
			address <= i;
			@(posedge clk); 
		end
		$stop;
		
	end
endmodule
