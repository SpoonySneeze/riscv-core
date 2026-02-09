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
    input wire funct7_bit5,
    output reg [3:0] alu_control
);

    // Combinational block to determine the ALU operation.
    always @(*) begin
        case (ALUOp)
            // Case 1: lw or sw (ALUOp = 00)
            // The ALU must perform an ADD to calculate the memory address.
            2'b00: begin
                alu_control = 4'b0010; // ADD
            end

            // Case 2: beq (ALUOp = 01)
            // The ALU must perform a SUBTRACT to check for equality.
            2'b01: begin
                alu_control = 4'b0110; // SUBTRACT
            end

            // Case 3: R-type instruction (ALUOp = 10)
            // We need to look at funct3 and funct7 to determine the specific operation.
            2'b10: begin
                case (funct3)
                    3'b000: begin // add or sub
                        if (funct7_bit5 == 1'b0) begin
                            alu_control = 4'b0010; // ADD
                        end else begin
                            alu_control = 4'b0110; // SUBTRACT
                        end
                    end
                    3'b111: alu_control = 4'b0000; // AND
                    3'b110: alu_control = 4'b0001; // OR
                    3'b010: alu_control = 4'b0111; // SLT (Set on Less Than)
                    default: alu_control = 4'b0000; // Default to prevent latches
                endcase
            end

            // Default case to prevent latches for any other ALUOp values.
            default: begin
                alu_control = 4'b0000;
            end
        endcase
    end

endmodule
