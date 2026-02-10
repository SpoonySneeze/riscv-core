`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 07:39:59 PM
// Design Name: 
// Module Name: alu_control
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


// This module acts as a secondary decoder for the ALU.
// It takes the high-level ALUOp from the main Control Unit
// and uses the instruction's function fields (funct3, funct7)
// to generate the specific 4-bit control signal for the ALU.
module alu_control(
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [4:0] alu_control
);

    // Combinational block to determine the ALU operation.
    always @(*) begin
        case (ALUOp)
            // Case 1: lw or sw (ALUOp = 00)
            // The ALU must perform an ADD to calculate the memory address.
            2'b00: begin
                alu_control = 5'b00000; // ADD
            end

            // Case 2: BRANCH
            2'b01: begin
                case (funct3)
                    3'b000, 3'b001: alu_control = 5'b00001; // 000 (BEQ) or 001 (BNE) --> (SUB)
                    3'b100, 3'b101: alu_control = 5'b10100; // 100 (BLT) or 101 (BGE) --> (We need to check if A < B (signed))
                    3'b110, 3'b111: alu_control = 5'b10101; // 110 (BLTU) or 111 (BGEU) --> (We need to check if A < B (unsigned))
                endcase
            end

            // Case 3: I/R-type instruction (ALUOp = 10,11)
            // We need to look at funct3 and funct7 to determine the specific operation.
            2'b10, 2'b11: begin
                case (funct3)
                    3'b000: begin // add (or sub)
                        // If it is R-Type (10) AND bit 30 is 1, it's SUB.
                        // For I-Type (11), we ALWAYS Add.
                        if (ALUOp == 2'b10 && funct7[5] == 1'b1) begin
                            alu_control = 5'b00001; // SUB (SUBTRACT)
                        end else begin
                            alu_control = 5'b00000; // ADD / ADDI (ADD) 
                        end
                    end
                    3'b001: alu_control = 5'b10001; // SLL / SLLI (Shift Left Logical)
                    3'b010: alu_control = 5'b10100; // SLT / SLTI (Set Less Than (Signed))
                    3'b011: alu_control = 5'b10101; // SLTU / SLTIU (Set Less Than (Unsigned))
                    3'b100: alu_control = 5'b00100; // XOR / XORI (Exclusive OR)
                    3'b101: begin 
                        if (funct7[5] == 1'b0) begin
                            alu_control = 5'b10110; // SRL / SRLI (Shift Right Logical)
                        end else begin
                            alu_control = 5'b10111; // SRA / SRAI (Shift Right Arithmetic)
                        end
                    end
                    3'b110: alu_control = 5'b00110; // OR / ORI (Bitwise OR)
                    3'b111: alu_control = 5'b00111; // AND / ANDI (Bitwise AND)
                    default: alu_control = 5'b00000; // Default to prevent latches
                endcase
            end

            // Default case to prevent latches for any other ALUOp values.
            default: begin
                alu_control = 5'b00000;
            end
        endcase
    end

endmodule
