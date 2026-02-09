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
    // Input
    input wire [6:0] opcode,

    // Outputs
    output reg reg_write,
    output reg mem_to_reg,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg alu_src,
    output reg [1:0] alu_op
    );

    // This combinational always block decodes the opcode.
    // The outputs change immediately when the opcode input changes.
    always @(*) begin
        // The case statement checks the opcode against known patterns.
        case(opcode)
            // lw (load word)
            7'b0000011: begin
                reg_write  <= 1'b1;
                mem_to_reg <= 1'b1;
                mem_read   <= 1'b1;
                mem_write  <= 1'b0;
                branch     <= 1'b0;
                alu_src    <= 1'b1;
                alu_op     <= 2'b00;
            end

            // addi (add immediate)
            7'b0010011: begin
                reg_write  <= 1'b1;
                mem_to_reg <= 1'b0;
                mem_read   <= 1'b0;
                mem_write  <= 1'b0;
                branch     <= 1'b0;
                alu_src    <= 1'b1;
                alu_op     <= 2'b00;
            end

            // sw (store word)
            7'b0100011: begin
                reg_write  <= 1'b0;
                mem_to_reg <= 1'b0; // 'X' is treated as 0 for safety
                mem_read   <= 1'b0;
                mem_write  <= 1'b1;
                branch     <= 1'b0;
                alu_src    <= 1'b1;
                alu_op     <= 2'b00;
            end

            // R-type (add, sub, etc.)
            7'b0110011: begin
                reg_write  <= 1'b1;
                mem_to_reg <= 1'b0;
                mem_read   <= 1'b0;
                mem_write  <= 1'b0;
                branch     <= 1'b0;
                alu_src    <= 1'b0;
                alu_op     <= 2'b10;
            end

            // beq (branch if equal)
            7'b1100011: begin
                reg_write  <= 1'b0;
                mem_to_reg <= 1'b0; // 'X' is treated as 0 for safety
                mem_read   <= 1'b0;
                mem_write  <= 1'b0;
                branch     <= 1'b1;
                alu_src    <= 1'b0;
                alu_op     <= 2'b01;
            end

            // Default case for unknown opcodes
            // Sets all signals to a safe, inactive state.
            default: begin
                reg_write  <= 1'b0;
                mem_to_reg <= 1'b0;
                mem_read   <= 1'b0;
                mem_write  <= 1'b0;
                branch     <= 1'b0;
                alu_src    <= 1'b0;
                alu_op     <= 2'b00;
            end
        endcase
    end

endmodule

