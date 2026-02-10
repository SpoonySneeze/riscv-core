`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 07:30:43 PM
// Design Name: 
// Module Name: immediate_generator
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


// This module decodes the immediate value from an instruction word.
// It extracts the correct bits based on the instruction format (I, S, B)
// and sign-extends the result to 32 bits.

module immediate_generator(
    input wire [31:0] instruction,
    output reg [31:0] immediate
);

    always @(*) begin
        case (instruction[6:0])
            // I-Type: LW, ADDI, JALR
            7'b0000011, // lw
            7'b0010011, // addi
            7'b1100111: begin // jalr (I-Type)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-Type: SW
            7'b0100011: begin 
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-Type: BEQ, BNE, BLT...
            7'b1100011: begin 
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            
            // J-Type: JAL
            7'b1101111: begin
                // J-immediate is scrambled: imm[20], imm[10:1], imm[11], imm[19:12]
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            
            // U-Type: LUI, AUIPC
            7'b0110111, // LUI
            7'b0010111: begin // AUIPC
                immediate = {instruction[31:12], 12'b0};
            end

            default: begin
                immediate = 32'b0;
            end
        endcase
    end
endmodule