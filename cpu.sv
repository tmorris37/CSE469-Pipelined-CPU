`timescale 1ns/10ps
module cpu (clk, Reg_clk, reset, instruction, PC, MEM_Address, MemWrite, MemRead, mem_xfer_size, MEM_Write_Data, MEM_Read_Data);
	input  logic clk, Reg_clk, reset;
	input  logic [31:0] instruction;
	output logic [63:0] PC;
	
	
	output logic	[63:0]	MEM_Address;
	output logic				MemWrite;
	output logic				MemRead;
	output logic	[3:0]		mem_xfer_size;
	output logic	[63:0]	MEM_Write_Data;
	input  logic	[63:0]	MEM_Read_Data;
	
// -------- Logic Declaration ---------
	
	// ---------------- IF ----------------
		logic [63:0] IF_PC, IF_PC_Next, IF_PC_Plus_4, IF_PC_Next_No_Prediction, IF_PC_Branch_Predicted;
		
		// Ignored, but needed to use the adder
		logic [3:0]  IF_PC_Adder_Flags, IF_PC_Adder_Flags2;
		
		logic [31:0] IF_Instruction;
	
	// ---------------- ID ----------------
		// ID Control Signals
		logic ID_Reg2Loc, ID_Is_Zero, ID_Is_Less, ID_PCSrc;
		
		// EX Control Signals
		logic ID_ALUSrc;
		logic [2:0] ID_ALUOp;
		
		// MEM Control Signals
		logic ID_MemWrite, ID_MemRead;
		logic [3:0] ID_mem_xfer_size;
		
		// WB Control Signals
		logic ID_Mem2Reg, ID_RegWrite;
		
		logic [63:0] ID_PC;
		logic [31:0] ID_Instruction_Initial;
	
		logic [63:0] ID_PC_Branch;
	
		// Ignored, but needed to use the adder
		logic [3:0]  ID_PC_Adder_Flags;
		
		logic [31:0] ID_Instruction;
		
		logic [10:0] ID_OP_Code;
		
		logic [4:0] ID_Rn, ID_Rm, ID_Rd, ID_Read_Reg_1, ID_Read_Reg_2, ID_Write_Reg;
		
		logic [63:0] ID_Read_Data_1, ID_Read_Data_2;
	
		logic [11:0] ID_ALU_Immediate;
		
		logic [8:0] ID_DT_Address;
		
		logic [25:0] ID_BR_Address;
		
		logic [18:0] ID_COND_BR_Address;
		
		logic [63:0] ID_ALU_Immediate_Extended,
						 ID_DT_Address_Extended,
						 ID_BR_Address_Extended,
						 ID_COND_BR_Address_Extended,
						 IF_Address;
				 
		logic [63:0] ID_Address;
		
		logic [63:0] ID_ALU_Constant;
		
		logic Reg2Loc, ALUSrc, Mem2Reg, RegWrite, C_Unit_MemWrite, C_Unit_MemRead;
		logic ID_UnCondBr, ID_update_flags, ID_store_PC, ID_D_Type, ID_Pc_From_Reg;
		
		logic ID_CondBr;
		
		logic ActualBranch, TakeBranch;
		
		logic Stall, Not_Stall;
		logic Flush;
		
		
		
	// ---------------- EX ----------------
		// EX Control Signals
		logic EX_ALUSrc;
		logic [2:0] EX_ALUOp;
		
		// MEM Control Signals
		logic EX_MemWrite, EX_MemRead;
		logic [3:0] EX_mem_xfer_size;
		
		// WB Control Signals
		logic EX_Mem2Reg, EX_RegWrite;
		
		// The Register Written to in WB
		logic [4:0]  EX_Write_Reg;
		
		// The Registers for the Forwarding Unit
		logic [4:0]  EX_Rn, EX_Rm;
		
		// The Register Data
		logic [63:0] EX_Read_Data_1, EX_Read_Data_2, EX_Write_Data;
		
		// The ALU Constant (ALU_Imm or DT_Address)
		logic [63:0] EX_ALU_Constant;
		
			// Ignored, but needed to use the ALU
		logic negative, zero, overflow, carry_out;
		
		// The ALU Result
		logic [63:0] EX_ALU_Result;
		
		// The Forwarding Selectors
		logic [1:0]  ForwardA, ForwardB;
		
		logic [63:0] EX_ALU_A, EX_ALU_B, EX_ForwardedA, EX_ForwardedB;
		
	// ---------------- MEM ---------------
		// MEM Control Signals
		logic MEM_MemWrite, MEM_MemRead;
		
		logic [3:0] MEM_mem_xfer_size;

		// WB Control Signals
		logic MEM_Mem2Reg, MEM_RegWrite;
		
		logic [63:0] MEM_ALU_Result;
		
		// The Register Written to in WB
		logic [4:0]  MEM_Write_Reg;
		
	// ---------------- WB ----------------
		// WB Control Signals
		logic WB_Mem2Reg, WB_RegWrite;
		
		// The Output Data from the Memory
		logic [63:0] WB_Read_Data;
		
		// The ALU Result from EX
		logic [63:0] WB_ALU_Result;
		
		// The Register Being Written to
		logic [4:0]  WB_Write_Reg;
		
		logic [63:0] WB_Write_Data;
		
	
// ---------------- IF ----------------

	assign PC = IF_PC;
	
	assign IF_Instruction = instruction;
	
	// The Program Counter
	DFF_multi #(64) PC_Register (.clk, .reset, .wr_en(Not_Stall), .d(IF_PC_Next), .q(IF_PC));
	
	// PC = PC + 4
	adder IF_PC_Adder (.A(IF_PC), .B(64'd4), .sub(1'b0), .sum(IF_PC_Plus_4), .flags(IF_PC_Adder_Flags));
	
	// Selects the PC Input
	mux64x2_1 PC_MUX (.sel(Flush), .in0(IF_PC_Plus_4), .in1(ID_PC_Branch), .out(IF_PC_Next_No_Prediction));
	mux64x2_1 PC_MUX_Prediction (.sel(TakeBranch), .in0(IF_PC_Next_No_Prediction), .in1(IF_PC_Branch_Predicted), .out(IF_PC_Next));
	
// ========== IF/ID Register ==========

	IF_ID_Register IF_ID (
	                      .clk,
								 .reset,
								 .IF_PC, 
	                      .IF_Instruction,
								 .ID_PC,
								 .ID_Instruction(ID_Instruction_Initial)
								);
	
// ---------------- ID ----------------
	
	// Converts the Instruction to a NOP if we Flush

	mux32x2_1 NOP_Selector (.sel(1'b0), .in0(ID_Instruction_Initial), .in1(32'd0), .out(ID_Instruction));
	
	assign ID_OP_Code = ID_Instruction[31:21];
	
	// The Registers
	assign ID_Rn = ID_Instruction[9:5];
	assign ID_Rm = ID_Instruction[20:16];
	assign ID_Rd = ID_Instruction[4:0];
	assign ID_Read_Reg_1 = ID_Rn;
	
	// Selects the Input for Read Register 2
	mux5x2_1 ID_Read_Register_2_MUX (.sel(ID_Reg2Loc), .in0(ID_Rm), .in1(ID_Rd), .out(ID_Read_Reg_2));
	assign ID_Write_Reg = ID_Rd;
	
	// The Constants Extracted from the Instruction
	assign ID_ALU_Immediate = ID_Instruction[21:10];
	assign ID_DT_Address = ID_Instruction[20:12];
	assign ID_BR_Address = ID_Instruction[25:0];
	assign ID_COND_BR_Address = ID_Instruction[23:5];
	
	// The Sign/Zero Extended Constants
	zero_extender #(12) ALU_Immediate_Extender   (.in(ID_ALU_Immediate), .out(ID_ALU_Immediate_Extended));
	sign_extender #(9)  DT_Address_Extender      (.in(ID_DT_Address), .out(ID_DT_Address_Extended));
	sign_extender #(28) BR_Address_Extender      (.in({ID_BR_Address, 2'b0}), .out(ID_BR_Address_Extended));
	sign_extender #(21) COND_BR_Address_Extender (.in({ID_COND_BR_Address, 2'b0}), .out(ID_COND_BR_Address_Extended));
		
	// Selects the Address for the PC (Conditional vs Unconditional)
	mux64x2_1 Address_MUX (.sel(ID_UnCondBr), .in0(ID_COND_BR_Address_Extended), .in1(ID_BR_Address_Extended), .out(ID_Address));
	
	// Selects the Constant for the ALU
	mux64x2_1 ALU_Constant_MUX (.sel(ID_D_Type), .in0(ID_ALU_Immediate_Extended), .in1(ID_DT_Address_Extended), .out(ID_ALU_Constant));
		
	// PC = PC + {Address}
	adder ID_PC_Adder (.A(ID_PC), .B(ID_Address), .sub(1'b0), .sum(ID_PC_Branch), .flags(ID_PC_Adder_Flags));
	
	// The Register File
	regfile ID_RegFile (
	                    .clk(Reg_clk),
	                    .RegWrite(WB_RegWrite),
							  .ReadRegister1(ID_Read_Reg_1),
							  .ReadRegister2(ID_Read_Reg_2),
							  .WriteRegister(WB_Write_Reg),
							  .WriteData(WB_Write_Data),
							  .ReadData1(ID_Read_Data_1),
							  .ReadData2(ID_Read_Data_2)
							 );
	
	// Checks if Read Data 2 is 0 (For Branching)
	zero_check ID_CBZ_Check (.in(ID_Read_Data_2), .out(ID_Is_Zero));
	assign ID_Is_Less = ID_Read_Data_2[63];
	
	// Outputs the Control Signals Based on the OP Code

	control_unit C_Unit (
								.opcode(ID_OP_Code),
								.ID_Is_Zero,
								.ID_Is_Less,
	                     .Reg2Loc,
								.ALUSrc,
								.Mem2Reg,
								.RegWrite,
								.MemWrite(C_Unit_MemWrite),
								.MemRead(C_Unit_MemRead),
								.PCSrc(ID_PCSrc),
								.UnCondBr(ID_UnCondBr),
								.update_flags(ID_update_flags),
								.store_pc(ID_store_PC),
								.d_type(ID_D_Type),
								.pc_from_reg(ID_Pc_From_Reg),
								.ALUop(ID_ALUOp),
								.mem_xfer_size(ID_mem_xfer_size)
							  );

	assign ID_Reg2Loc = Reg2Loc;
	assign ID_ALUSrc  = ALUSrc;
	assign ID_Mem2Reg = Mem2Reg;
	
	
	// Hazard Detection Unit
	
	not #10 (ID_CondBr, ID_UnCondBr);
	and #10 (ActualBranch, ID_PCSrc, ID_CondBr);
	
	hazard_detection_unit hdu (
	                           .clk,
										.reset,
										.en(ID_PCSrc),
										.IF_Instruction,
										.ActualBranch,
										.TakeBranch,
										.ID_Read_Reg_1,
	                           .ID_Read_Reg_2,
										.EX_Write_Reg,
										.EX_MemRead,
										.Stall,
										.Flush,
										.IF_Address
									  );
	// Predicted Branch Address
	adder ID_PC_Adder_Prediction (.A(IF_PC), .B(IF_Address), .sub(1'b0), .sum(IF_PC_Branch_Predicted), .flags(IF_PC_Adder_Flags2));

	// Stall when LDUR(Xi) is followed by a read(Xi)
	// To Convert to a nop, Read/Write control signals are set to 0

	not #10 (Not_Stall, Stall);
	and #10 (ID_RegWrite, RegWrite, Not_Stall);
	and #10 (ID_MemWrite, C_Unit_MemWrite, Not_Stall);
	and #10 (ID_MemRead, C_Unit_MemRead, Not_Stall);
	
	// Flush when CB is mis-predicted
	
	

	
	
// ========== ID/EX Register ==========
	
	ID_EX_Register ID_EX (
								 .clk,
								 .reset,
								 .ID_ALUSrc,
								 .ID_ALUOp,
								 .ID_MemWrite,
								 .ID_MemRead,
								 .ID_mem_xfer_size,
								 .ID_Mem2Reg,
								 .ID_RegWrite,
								 .ID_Read_Data_1,
								 .ID_Read_Data_2,
								 .ID_ALU_Constant,
								 .ID_Write_Reg,
								 .ID_Rn,
								 .ID_Rm,
								 .EX_ALUSrc,
								 .EX_ALUOp,
								 .EX_MemWrite,
								 .EX_MemRead,
								 .EX_mem_xfer_size,
								 .EX_Mem2Reg,
								 .EX_RegWrite,
								 .EX_Read_Data_1,
								 .EX_Read_Data_2,
								 .EX_ALU_Constant,
								 .EX_Write_Reg,
								 .EX_Rn,
								 .EX_Rm
								);
	
// ---------------- EX ----------------

	assign EX_Write_Data = EX_Read_Data_2;
	
	// Selects the Inputs of the ALU (Read Data, ALU Constant, EX/MEM Forwarding, MEM/WB Forwarding)
	mux64x4_1 EX_ForwardA_Selector (
				 .sel(ForwardA),
				 .in00(EX_Read_Data_1),
				 .in01(WB_Write_Data), 
				 .in10(MEM_ALU_Result),
				 .in11(MEM_ALU_Result),
				 .out(EX_ForwardedA)
				);
	assign EX_ALU_A = EX_ForwardedA;
	mux64x4_1 EX_ForwardB_Selector (
				 .sel(ForwardB),
				 .in00(EX_Read_Data_2),
				 .in01(WB_Write_Data), 
				 .in10(MEM_ALU_Result),
				 .in11(MEM_ALU_Result),
				 .out(EX_ForwardedB)
				);
	mux64x2_1 EX_ALUSrc_Selector (
				 .sel(EX_ALUSrc),
				 .in0(EX_ForwardedB),
				 .in1(EX_ALU_Constant),
				 .out(EX_ALU_B)
				);
	
	alu EX_ALU (
	            .A(EX_ALU_A),
	            .B(EX_ALU_B),
					.cntrl(EX_ALUOp),
					.result(EX_ALU_Result),
					.negative,
					.zero, 
					.overflow,
					.carry_out
				  );
				  
	// Forwarding Unit
	forwarding_unit Forwarding_Unit (
	                                 .MEM_RegWrite,
												.WB_RegWrite,
	                                 .EX_Rn,
	                                 .EX_Rm,
												.MEM_Rd(MEM_Write_Reg),
												.WB_Rd(WB_Write_Reg),
												.ForwardA,
												.ForwardB
											  );
	
// ========== EX/MEM Register =========
		
	EX_MEM_Register EX_MEM (
	                        .clk,
								   .reset,
									.EX_MemWrite,
									.EX_MemRead,
									.EX_mem_xfer_size,
									.EX_Mem2Reg,
									.EX_RegWrite,
	                        .EX_ALU_Result,
									.EX_Write_Data,
									.EX_Write_Reg,
									.MEM_MemWrite,
									.MEM_MemRead,
									.MEM_mem_xfer_size,
									.MEM_Mem2Reg,
									.MEM_RegWrite,
									.MEM_ALU_Result,
									.MEM_Write_Data,
									.MEM_Write_Reg
	                       );
	
// --------------- MEM ----------------

	assign MemWrite = MEM_MemWrite;
	assign MemRead  = MEM_MemRead;

	assign mem_xfer_size = MEM_mem_xfer_size;
	
	// The ALU Result from EX
	assign MEM_Address = MEM_ALU_Result;
	
	
// ========== MEM/WB Register =========	
	
	MEM_WB_Register MEM_WB (
	                        .clk,
								   .reset,
									.MEM_Mem2Reg,
	                        .MEM_RegWrite,
	                        .MEM_Read_Data,
									.MEM_ALU_Result,
									.MEM_Write_Reg,
									.WB_Mem2Reg,
									.WB_RegWrite,
									.WB_Read_Data,
									.WB_ALU_Result,
									.WB_Write_Reg
								  );
	
// --------------- WB -----------------
	
	// Selects the Write Data
	mux64x2_1 Reg_Write_MUX (.sel(WB_Mem2Reg), .in0(WB_ALU_Result), .in1(WB_Read_Data), .out(WB_Write_Data));
	
	
endmodule  // cpu