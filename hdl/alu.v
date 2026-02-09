`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 07:34:11 PM
// Design Name: 
// Module Name: alu
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


// This module is the core calculator of the processor.
// It takes two 32-bit operands (a, b) and performs a specific
// operation on them based on the 4-bit alu_control signal.
module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_control,
    output reg [31:0] result,
    output wire zero
);

    // Combinational block to calculate the result based on the control signal.
    always @(*) begin
        case (alu_control)
            4'b0000: result = a & b;  // AND
            4'b0001: result = a | b;  // OR
            4'b0010: result = a + b;  // ADD
            4'b0110: result = a - b;  // SUBTRACT
            4'b0111: result = (a < b) ? 32'd1 : 32'd0; // Set on Less Than
            default: result = 32'b0; // Default to 0 to avoid latches
        endcase
    end

    // The 'zero' flag is high (1) if the result is exactly zero.
    // This is critical for branch instructions like 'beq'.
    assign zero = (result == 32'b0);

endmodule
