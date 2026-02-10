`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 06:33:44 PM
// Design Name: 
// Module Name: control_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// This module decodes the instruction's opcode to generate
// the main control signals for the datapath.

module control_unit(
    input wire [6:0] opcode,

    output reg reg_write,
    output reg mem_to_reg,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg jump,
    output reg [1:0] op_a_sel, // <--- NEW: Select ALU Input A
    output reg alu_src,        // Select ALU Input B (0=Reg2, 1=Imm)
    output reg [1:0] alu_op
    );

    always @(*) begin
        // Defaults
        reg_write = 0; mem_to_reg = 0; mem_read = 0; mem_write = 0;
        branch = 0; jump = 0; 
        alu_src = 0;        // Default B = Reg2
        op_a_sel = 2'b00;   // Default A = Reg1 (RS1)
        alu_op = 0;

        case(opcode)
            // LW
            7'b0000011: begin
                reg_write = 1; mem_to_reg = 1; mem_read = 1; 
                alu_src = 1; // B = Imm
                alu_op = 2'b00; // ADD
            end

            // I-Type Arith (ADDI)
            7'b0010011: begin
                reg_write = 1; 
                alu_src = 1; // B = Imm
                alu_op = 2'b11; // I-Type
            end

            // SW
            7'b0100011: begin
                mem_write = 1; 
                alu_src = 1; // B = Imm
                alu_op = 2'b00; // ADD
            end

            // R-Type
            7'b0110011: begin
                reg_write = 1; 
                alu_op = 2'b10; // R-Type
            end

            // Branch (BEQ)
            7'b1100011: begin
                branch = 1; 
                alu_op = 2'b01; 
                // A = Reg1, B = Reg2 (alu_src=0)
            end
            
            // LUI (Load Upper Immediate)
            7'b0110111: begin
                reg_write = 1;
                alu_src = 1;      // B = Imm
                op_a_sel = 2'b10; // A = Zero  <--- CRITICAL FIX
                alu_op = 2'b00;   // ADD (0 + Imm)
            end

            // AUIPC (Add Upper Imm to PC)
            7'b0010111: begin
                reg_write = 1;
                alu_src = 1;      // B = Imm
                op_a_sel = 2'b01; // A = PC    <--- CRITICAL FIX
                alu_op = 2'b00;   // ADD (PC + Imm)
            end

            // JAL
            7'b1101111: begin
                jump = 1; reg_write = 1; 
                // ALU not used for JAL target, but usually writes PC+4.
                // Our Datapath handles PC+4 in the WB stage muxing logic (execute_stage output)
            end
            
            // JALR
            7'b1100111: begin
                jump = 1; reg_write = 1;
                alu_src = 1;      // B = Imm
                op_a_sel = 2'b00; // A = RS1
                alu_op = 2'b00;   // ADD (RS1 + Imm) -> This calculates Target
            end
        endcase
    end
endmodule
