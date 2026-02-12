`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 03:39:23 PM
// Design Name: 
// Module Name: PC
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


module PC(
    input wire clk,
    input wire reset,
    input wire [31:0] next_pc,
    output wire [31:0] current_pc
    );
    reg [31:0] addr;
    always@(posedge clk)begin
        if(reset) addr <= 32'h80000000;
        else addr <= next_pc;
    end
    assign current_pc = addr;
endmodule
