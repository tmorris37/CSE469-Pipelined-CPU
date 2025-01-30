// this code is written for CSE 469 Lab 3, Summer 2024
// Copyright @ 2024 Jason Zhao, Timothy Morris

// this code is responsible for setting the data path logics

`timescale 1ns/10ps
module control_unit (
    input  logic [10:0] opcode, // 1 bits opcode of the instruction
    input  logic ID_Is_Zero, ID_Is_Less,

    output logic Reg2Loc, ALUSrc, Mem2Reg, RegWrite, MemWrite, MemRead, PCSrc, UnCondBr, // control signals covered in class
    output logic store_pc, // 0 if from MemtoReg, 1 from the process counter, we will need this for BL instruction
    output logic pc_from_reg, // 0 if from previous logic, 1 from the read_data_2 of the register file
    output logic update_flags, // whether we need to update the flags
    output logic d_type, // 0 if it's I-type, 1 if it's D-type, x if neither, to select source for the mux of ALUSrc

    output logic [2:0] ALUop,
	 output logic [3:0] mem_xfer_size
);

    // define the opcode for each instruction
    parameter [10:0] 
                ADDI = 11'b1001000100x, 
                ADDS = 11'b10101011000, 
                B = 11'b000101xxxxx,
                B_LT = 11'b01010100xxx,
                BL = 11'b100101xxxxx,
                BR = 11'b11010110000,
                CBZ = 11'b10110100xxx,
                LDUR = 11'b11111000010,
                STUR = 11'b11111000000,
                SUBS = 11'b11101011000;

    always_comb 
		begin
            casex (opcode)
                ADDI: begin
                    Reg2Loc = 1'bx;
                    ALUSrc = 1'b1;
                    Mem2Reg = 1'b0;
                    RegWrite = 1'b1;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = 1'b0;
                    UnCondBr = 1'bx;
                    update_flags = 1'b0;
                    store_pc = 1'b0;
                    d_type = 1'b0;
                    pc_from_reg = 1'b0;
                    ALUop = 3'b010;
						  mem_xfer_size = 4'bx;
                end

                ADDS: begin
                    Reg2Loc = 1'b0;
                    ALUSrc = 1'b0;
                    Mem2Reg = 1'b0;
                    RegWrite = 1'b1;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = 1'b0;
                    UnCondBr = 1'bx;
                    update_flags = 1'b1;
                    store_pc = 1'b0;
                    d_type = 1'bx;
                    pc_from_reg = 1'b0;
                    ALUop = 3'b010;
						  mem_xfer_size = 4'bx;
                end

                B: begin
                    Reg2Loc = 1'bx;
                    ALUSrc = 1'bx;
                    Mem2Reg = 1'bx;
                    RegWrite = 1'b0;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = 1'b1;
                    UnCondBr = 1'b1;
                    update_flags = 1'b0;
                    store_pc = 1'bx;
                    d_type = 1'bx;
                    pc_from_reg = 1'b0;
                    ALUop = 3'bx; // don't care
						  mem_xfer_size = 4'bx;
                end

                B_LT: begin
                    Reg2Loc = 1'bx;
                    ALUSrc = 1'bx;
                    Mem2Reg = 1'bx;
                    RegWrite = 1'b0;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = ID_Is_Less;
                    UnCondBr = 1'b0;
                    update_flags = 1'b0;
                    store_pc = 1'bx;
                    d_type = 1'bx;
                    pc_from_reg = 1'b0;
                    ALUop = 3'bx; // don't care
						  mem_xfer_size = 4'bx;
                end

                BL: begin
                    Reg2Loc = 1'bx;
                    ALUSrc = 1'bx;
                    Mem2Reg = 1'bx;
                    RegWrite = 1'b1;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = 1'b1;
                    UnCondBr = 1'b1;
                    update_flags = 1'b0;
                    store_pc = 1'b1;
                    d_type = 1'bx;
                    pc_from_reg = 1'b0;
                    ALUop = 3'bx; // don't care
						  mem_xfer_size = 4'bx;
                end

                BR: begin
                    Reg2Loc = 1'b0;
                    ALUSrc = 1'bx;
                    Mem2Reg = 1'bx;
                    RegWrite = 1'b0;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = 1'bx;
                    UnCondBr = 1'bx;
                    update_flags = 1'b0;
                    store_pc = 1'bx;
                    d_type = 1'bx;
                    pc_from_reg = 1'b1;
                    ALUop = 3'bx; // don't care
						  mem_xfer_size = 4'bx;
                end

                CBZ: begin
                    Reg2Loc = 1'b1;
                    ALUSrc = 1'b0;
                    Mem2Reg = 1'bx;
                    RegWrite = 1'b0;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = ID_Is_Zero;
                    UnCondBr = 1'b0;
                    update_flags = 1'b0;
                    store_pc = 1'bx;
                    d_type = 1'bx;
                    pc_from_reg = 1'b0;
                    ALUop = 3'b000; // bypass B
						  mem_xfer_size = 4'bx;
                end

                LDUR: begin
                    Reg2Loc = 1'bx;
                    ALUSrc = 1'b1;
                    Mem2Reg = 1'b1;
                    RegWrite = 1'b1;
                    MemWrite = 1'b0;
                    MemRead = 1'b1;
                    PCSrc = 1'b0;
                    UnCondBr = 1'bx;
                    update_flags = 1'b0;
                    store_pc = 1'b0;
                    d_type = 1'b1;
                    pc_from_reg = 1'b0;
                    ALUop = 3'b010; // add
						  mem_xfer_size = 4'b1000;
                end

                STUR: begin
                    Reg2Loc = 1'b1;
                    ALUSrc = 1'b1;
                    Mem2Reg = 1'bx;
                    RegWrite = 1'b0;
                    MemWrite = 1'b1;
                    MemRead = 1'b0;
                    PCSrc = 1'b0;
                    UnCondBr = 1'bx;
                    update_flags = 1'b0;
                    store_pc = 1'bx;
                    d_type = 1'b1;
                    pc_from_reg = 1'b0;
                    ALUop = 3'b010; // add
						  mem_xfer_size = 4'b1000;
                end

                SUBS: begin
                    Reg2Loc = 1'b0;
                    ALUSrc = 1'b0;
                    Mem2Reg = 1'b0;
                    RegWrite = 1'b1;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = 1'b0;
                    UnCondBr = 1'bx;
                    update_flags = 1'b1;
                    store_pc = 1'b0;
                    d_type = 1'bx;
                    pc_from_reg = 1'b0;
                    ALUop = 3'b011;
						  mem_xfer_size = 4'bx;
                end

                default: begin
                    Reg2Loc = 1'bx;
                    ALUSrc = 1'bx;
                    Mem2Reg = 1'bx;
                    RegWrite = 1'b0;
                    MemWrite = 1'b0;
                    MemRead = 1'b0;
                    PCSrc = 1'b0;
                    UnCondBr = 1'bx;
                    update_flags = 1'bx;
                    store_pc = 1'bx;
                    d_type = 1'bx;
                    pc_from_reg = 1'bx;
                    ALUop = 3'bx;
						  mem_xfer_size = 4'bx;
                end

            endcase
        end

endmodule // data_path_logic