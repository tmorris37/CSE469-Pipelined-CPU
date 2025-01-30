
// 00 - No Forwarding
// 01 - MEM/WB Forwarding
// 10 - EX/MEM Forwarding
// 11 - EX/MEM Forwarding
`timescale 1ns/10ps
module forwarding_unit (MEM_RegWrite, WB_RegWrite, EX_Rn, EX_Rm, MEM_Rd, WB_Rd, ForwardA, ForwardB);

	input  logic MEM_RegWrite, WB_RegWrite;
	input  logic [4:0] EX_Rn, EX_Rm;
	input  logic [4:0] MEM_Rd, WB_Rd;
	
	output logic [1:0] ForwardA, ForwardB;

	// Comparator Outputs
	logic MEM_Rd_equals_X31, MEM_Rd_not_equals_X31,
	      WB_Rd_equals_X31, WB_Rd_not_equals_X31,
	      MEM_Rd_equals_EX_Rn, MEM_Rd_equals_EX_Rm,
			WB_Rd_equals_EX_Rn, WB_Rd_equals_EX_Rm;
	
	// EX/MEM.RegisterRd != 31
	comparator c1 (.Reg1(MEM_Rd), .Reg2(5'b11111), .equal(MEM_Rd_equals_X31));
		not #10 (MEM_Rd_not_equals_X31, MEM_Rd_equals_X31);
		
	// MEM/WB.RegisterRd != 31
	comparator c2 (.Reg1(WB_Rd), .Reg2(5'b11111), .equal(WB_Rd_equals_X31));
		not #10 (WB_Rd_not_equals_X31, WB_Rd_equals_X31);
		
	// EX/MEM.RegisterRd = ID/EX.RegisterRn
	comparator c3 (.Reg1(MEM_Rd), .Reg2(EX_Rn), .equal(MEM_Rd_equals_EX_Rn));
	
	// EX/MEM.RegisterRd = ID/EX.RegisterRm
	comparator c4 (.Reg1(MEM_Rd), .Reg2(EX_Rm), .equal(MEM_Rd_equals_EX_Rm));
	
	// MEM/WB.RegisterRd = ID/EX.RegisterRn
	comparator c5 (.Reg1(WB_Rd), .Reg2(EX_Rn), .equal(WB_Rd_equals_EX_Rn));
	
	// MEM/WB.RegisterRd = ID/EX.RegisterRm
	comparator c6 (.Reg1(WB_Rd), .Reg2(EX_Rm), .equal(WB_Rd_equals_EX_Rm));
	
	
	// EX/MEM Forward Bit
	logic and1, and2;
	and #10 (and1, MEM_RegWrite, MEM_Rd_not_equals_X31);
	and #10 (ForwardA[1], and1, MEM_Rd_equals_EX_Rn);
	
	// EX/MEM Forward Bit
	and #10 (and2, MEM_RegWrite, MEM_Rd_not_equals_X31);
	and #10 (ForwardB[1], and2, MEM_Rd_equals_EX_Rm);
	
	// MEM/WB Forward Bit
	logic and3, and4;
	and #10 (and3, WB_RegWrite, WB_Rd_not_equals_X31);
	and #10 (ForwardA[0], and3, WB_Rd_equals_EX_Rn);
	
	// MEM/WB Forward Bit
	and #10 (and4, WB_RegWrite, WB_Rd_not_equals_X31);
	and #10 (ForwardB[0], and4, WB_Rd_equals_EX_Rm);

endmodule  // forwarding_unit
