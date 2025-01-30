`timescale 1ns/10ps
module hazard_detection_unit (clk, reset, en, IF_Instruction, ActualBranch, TakeBranch, ID_Read_Reg_1, ID_Read_Reg_2, EX_Write_Reg, EX_MemRead, Stall, Flush, IF_Address);

	input  logic clk, reset, en, ActualBranch;
	input  logic [31:0] IF_Instruction;
	output logic TakeBranch;
	
	input  logic [4:0] ID_Read_Reg_1, ID_Read_Reg_2;
	input  logic [4:0] EX_Write_Reg;
	input  logic EX_MemRead;
	output logic Stall, Flush;
	output logic [63:0] IF_Address;
	
	logic [63:0] IF_COND_BR_Address_Extended, IF_BR_Address_Extended;
	
	// assign Stall = 1'b0;
	// assign Flush = 1'b0;
	
	logic ShouldTake;
	
	logic IF_isCondBr, IF_isUnCondBr;
	
	// if IF_Instruction[31:24] == b10110100
	//                       or == b01010100
	// isCondBr = 1
	// ~24 and ~25 and 26 and ~27 and 28 and ((31 and ~30 and 29) or (~31 and 30 and ~29))
	
	logic and1, and2, and3, and4, and5A, and5B, and6A, and6B, or1, and7, and8, and9, and10, and11;
	logic not24, not25, not27, not29, not30, not31;
	
	not #10 (not24, IF_Instruction[24]);
	not #10 (not25, IF_Instruction[25]);
	not #10 (not27, IF_Instruction[27]);
	not #10 (not29, IF_Instruction[29]);
	not #10 (not30, IF_Instruction[30]);
	not #10 (not31, IF_Instruction[31]);
	
	and #10 (and1, not24, not25);
	and #10 (and2, and1, IF_Instruction[26]);
	and #10 (and3, and2, not27);
	and #10 (and4, and3, IF_Instruction[28]);
	
	and #10 (and5A, not29, IF_Instruction[30]);
	and #10 (and5B, and5A, not31);
	
	and #10 (and6A, not30, IF_Instruction[29]);
	and #10 (and6B, and6A, IF_Instruction[31]);
	
	or  #10 (or1, and5B, and5B);
	
	and #10 (IF_isCondBr, and4, or1);
	
	and #10 (and7, IF_isCondBr, ShouldTake);
	
	and #10 (and8, IF_Instruction[26], not27);
	and #10 (and9, and8, IF_Instruction[28]);
	and #10 (and10, and9, not29);
	and #10 (and11, and10, not30);
	and #10 (IF_isUnCondBr, and11, not31);
	
	or  #10 (TakeBranch, IF_isUnCondBr, and7);
	
	logic [18:0] IF_COND_BR_Address;
		assign IF_COND_BR_Address = IF_Instruction[23:5];
	logic [25:0] IF_BR_Address;
		assign IF_BR_Address = IF_Instruction[25:0];
	sign_extender #(21) COND_BR_Address_Extender (.in({IF_COND_BR_Address, 2'b0}), .out(IF_COND_BR_Address_Extended));
	sign_extender #(28) BR_Address_Extender      (.in({IF_BR_Address, 2'b0}), .out(IF_BR_Address_Extended));
	
	mux64x2_1 Address_MUX (.sel(IF_isUnCondBr), .in0(IF_COND_BR_Address_Extended), .in1(IF_BR_Address_Extended), .out(IF_Address));
	
	// If inst. in IF is cond_branch:
	//      change PCSrc based on
	
	logic EX_Rd_equals_ID_Rn, EX_Rd_equals_ID_Rm;
	
	// ID/EX.RegisterRd = IF/ID.RegisterRn
	comparator c1 (.Reg1(EX_Write_Reg), .Reg2(ID_Read_Reg_1), .equal(EX_Rd_equals_ID_Rn));
	// ID/EX.RegisterRd = IF/ID.RegisterRm
	comparator c2 (.Reg1(EX_Write_Reg), .Reg2(ID_Read_Reg_2), .equal(EX_Rd_equals_ID_Rm));
	
	logic or2;
	or  #10 (or2, EX_Rd_equals_ID_Rn, EX_Rd_equals_ID_Rm);
	and #10 (Stall, EX_MemRead, or1);
	
	// Branch Predictor
	branch_predictor bp (.*);
	
	xor #10 (Flush, ShouldTake, ActualBranch);
	
endmodule  // hazard_detection_unit


module branch_predictor (clk, reset, en, Flush, ShouldTake);

	input  logic clk, reset, en, Flush;
	output logic ShouldTake;

	// ps[1] determines if we branch
	// ps[0] counts how many times we've consequtively mispredicted (Flushed)
	logic [1:0] ps, ns;
	
	assign ShouldTake = ps[1];
	
	DFF_multi #(2) FSM (.clk, .reset, .wr_en(en), .d(ns), .q(ps));
	
	// Simplified K-map used to determine the FSM
	logic and1, not1;
	and #10 (and1, ps[0], Flush);
	xor #10 (ns[1], ps[1], and1);
	
	not #10 (not1, ps[0]);
	and #10 (ns[0], not1, Flush);

endmodule  // branch_predictor
