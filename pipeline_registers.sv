`timescale 1ns/10ps
module IF_ID_Register (clk, reset, IF_PC, IF_Instruction, ID_PC, ID_Instruction);
	
	input  logic clk, reset;
	
	input  logic [63:0] IF_PC;
	input  logic [31:0] IF_Instruction;
	
	output logic [63:0] ID_PC;
	output logic [31:0] ID_Instruction;

	DFF_multi #(64) IF_ID_PC          (.clk, .reset, .wr_en(1'b1), .d(IF_PC), .q(ID_PC));
	DFF_multi #(32) IF_ID_Instruction (.clk, .reset, .wr_en(1'b1), .d(IF_Instruction), .q(ID_Instruction));

endmodule  // IF_ID_Register


module ID_EX_Register (clk, reset, ID_ALUSrc, ID_ALUOp, ID_MemWrite, ID_MemRead, ID_mem_xfer_size, ID_Mem2Reg, 
                       ID_RegWrite, ID_Read_Data_1, ID_Read_Data_2, ID_ALU_Constant,
							  ID_Write_Reg, ID_Rn, ID_Rm, EX_ALUSrc, EX_ALUOp, EX_MemWrite,
							  EX_MemRead, EX_mem_xfer_size, EX_Mem2Reg, EX_RegWrite, EX_Read_Data_1, EX_Read_Data_2, 
							  EX_ALU_Constant, EX_Write_Reg, EX_Rn, EX_Rm
							 );

	input  logic clk, reset;
	
	input  logic ID_ALUSrc, ID_MemWrite, ID_MemRead, ID_Mem2Reg, ID_RegWrite;
	input  logic [3:0]  ID_mem_xfer_size;
	input  logic [2:0]  ID_ALUOp;
	input  logic [63:0] ID_Read_Data_1, ID_Read_Data_2;
	input  logic [63:0] ID_ALU_Constant;
	input  logic [4:0]  ID_Write_Reg, ID_Rn, ID_Rm;
	
	output logic EX_ALUSrc, EX_MemWrite, EX_MemRead, EX_Mem2Reg, EX_RegWrite;
	output logic [3:0]  EX_mem_xfer_size;
	output logic [2:0]  EX_ALUOp;
	output logic [63:0] EX_Read_Data_1, EX_Read_Data_2;
	output logic [63:0] EX_ALU_Constant;
	output logic [4:0]  EX_Write_Reg, EX_Rn, EX_Rm;

	DFF_multi #(9)  ID_EX_Control_Signals (.clk, .reset, .wr_en(1'b1), .d({ID_ALUSrc, ID_MemWrite, ID_MemRead, ID_mem_xfer_size, ID_Mem2Reg, ID_RegWrite}),
	                                                                   .q({EX_ALUSrc, EX_MemWrite, EX_MemRead, EX_mem_xfer_size, EX_Mem2Reg, EX_RegWrite}));
	DFF_multi #(3)  ID_EX_ALUOp           (.clk, .reset, .wr_en(1'b1), .d(ID_ALUOp), .q(EX_ALUOp));
	DFF_multi #(64) ID_EX_Read_Data_1     (.clk, .reset, .wr_en(1'b1), .d(ID_Read_Data_1), .q(EX_Read_Data_1));
	DFF_multi #(64) ID_EX_Read_Data_2     (.clk, .reset, .wr_en(1'b1), .d(ID_Read_Data_2), .q(EX_Read_Data_2));
	DFF_multi #(64) ID_EX_ALU_Constant    (.clk, .reset, .wr_en(1'b1), .d(ID_ALU_Constant), .q(EX_ALU_Constant));
	DFF_multi #(5)  ID_EX_Write_Reg       (.clk, .reset, .wr_en(1'b1), .d(ID_Write_Reg), .q(EX_Write_Reg));
	DFF_multi #(5)  ID_EX_Rn              (.clk, .reset, .wr_en(1'b1), .d(ID_Rn), .q(EX_Rn));
	DFF_multi #(5)  ID_EX_Rm              (.clk, .reset, .wr_en(1'b1), .d(ID_Rm), .q(EX_Rm));
	
endmodule  // ID_EX_Register


module EX_MEM_Register (clk, reset, EX_MemWrite, EX_MemRead, EX_mem_xfer_size, EX_Mem2Reg, 
                        EX_RegWrite, EX_ALU_Result, EX_Write_Data, EX_Write_Reg, 
								MEM_MemWrite, MEM_MemRead, MEM_mem_xfer_size, MEM_Mem2Reg, 
                        MEM_RegWrite, MEM_ALU_Result, MEM_Write_Data, MEM_Write_Reg
							  );
							  
	input  logic clk, reset;
	
	input  logic EX_MemWrite, EX_MemRead, EX_Mem2Reg, EX_RegWrite;
	input  logic [3:0]  EX_mem_xfer_size;
	input  logic [63:0] EX_ALU_Result;
	input  logic [63:0] EX_Write_Data;
	input  logic [4:0]  EX_Write_Reg;
	
	output logic MEM_MemWrite, MEM_MemRead, MEM_Mem2Reg, MEM_RegWrite;
	output logic [3:0]  MEM_mem_xfer_size;
	output logic [63:0] MEM_ALU_Result;
	output logic [63:0] MEM_Write_Data;
	output logic [4:0]  MEM_Write_Reg;

	DFF_multi #(8)  EX_MEM_Control_Signals (.clk, .reset, .wr_en(1'b1), .d({EX_MemWrite, EX_MemRead, EX_Mem2Reg, EX_RegWrite, EX_mem_xfer_size}),
	                                                                    .q({MEM_MemWrite, MEM_MemRead, MEM_Mem2Reg, MEM_RegWrite, MEM_mem_xfer_size}));
	DFF_multi #(64) EX_MEM_ALU_Result      (.clk, .reset, .wr_en(1'b1), .d(EX_ALU_Result), .q(MEM_ALU_Result));
	DFF_multi #(64) EX_MEM_Write_Data      (.clk, .reset, .wr_en(1'b1), .d(EX_Write_Data), .q(MEM_Write_Data));
	DFF_multi #(5)  EX_MEM_Write_Reg       (.clk, .reset, .wr_en(1'b1), .d(EX_Write_Reg), .q(MEM_Write_Reg));

endmodule  // EX_MEM_Register
								  
								  
module MEM_WB_Register (clk, reset, MEM_Mem2Reg, MEM_RegWrite, MEM_Read_Data, MEM_ALU_Result, MEM_Write_Reg,
                        WB_Mem2Reg, WB_RegWrite, WB_Read_Data, WB_ALU_Result, WB_Write_Reg
							  );
							  
	input  logic clk, reset;
	
	input  logic MEM_Mem2Reg, MEM_RegWrite;
	input  logic [63:0] MEM_Read_Data;
	input  logic [63:0] MEM_ALU_Result;
	input  logic [4:0]  MEM_Write_Reg;

	output logic WB_Mem2Reg, WB_RegWrite;
	output logic [63:0] WB_Read_Data;
	output logic [63:0] WB_ALU_Result;
	output logic [4:0]  WB_Write_Reg;
	
	DFF_multi #(2)  MEM_WB_Control_Signals (.clk, .reset, .wr_en(1'b1), .d({MEM_Mem2Reg, MEM_RegWrite}),
	                                                                    .q({WB_Mem2Reg, WB_RegWrite}));
	DFF_multi #(64) MEM_WB_Read_Data       (.clk, .reset, .wr_en(1'b1), .d(MEM_Read_Data), .q(WB_Read_Data));
	DFF_multi #(64) MEM_WB_ALU_Result      (.clk, .reset, .wr_en(1'b1), .d(MEM_ALU_Result), .q(WB_ALU_Result));
	DFF_multi #(5)  MEM_WB_Write_Reg       (.clk, .reset, .wr_en(1'b1), .d(MEM_Write_Reg), .q(WB_Write_Reg));

endmodule  // MEM_WB_Register
