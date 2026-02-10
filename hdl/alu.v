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
    input wire [4:0] alu_control,
    output reg [31:0] result,
    output wire zero
);

    // Combinational block to calculate the result based on the control signal.
    always @(*) begin
        case (alu_control)
            5'b00000: result = a + b;  // ADD
            5'b00001: result = a - b;  // SUBSTRACT
            5'b10001: result = a << b[4:0];  // SHIFT LEFT
            5'b10100: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;  // Set Less Than (Signed)
            5'b10101: result = (a < b) ? 32'd1 : 32'd0; // Set on Less Than (Unsigned)
            5'b00100: result = a ^ b; // XOR
            5'b10110: result = a >> b[4:0]; // Shift Right Logical
            5'b10111: result = $signed(a) >>> b[4:0]; // Shift Right Arthematic
            5'b00110: result = a | b; //OR
            5'b00111: result = a & b; //AND
            default: result = 32'b0; // Default to 0 to avoid latches
        endcase
    end

    // The 'zero' flag is high (1) if the result is exactly zero.
    // This is critical for branch instructions like 'beq'.
    assign zero = (result == 32'b0);

endmodule
