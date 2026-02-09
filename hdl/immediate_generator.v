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

    // This is a combinational block that reacts instantly to changes
    // in the instruction input.
    always @(*) begin
        // The case statement uses the opcode to determine the format.
        case (instruction[6:0])
            // I-type instructions: lw (load word) and addi (add immediate)
            7'b0000011, // lw
            7'b0010011: begin // addi
                // Concatenate the sign bit (repeated 20 times) with the 12 immediate bits.
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type instruction: sw (store word)
            7'b0100011: begin // sw
                // Reassemble the split immediate and then sign-extend.
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-type instruction: beq (branch if equal)
            7'b1100011: begin // beq
                // Reassemble the scattered immediate bits and then sign-extend from 13 to 32 bits.
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            // Default case for all other instructions (like R-type)
            // Outputting zero is a safe default.
            default: begin
                immediate = 32'b0;
            end
        endcase
    end

endmodule
