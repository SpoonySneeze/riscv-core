`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 05:00:34 PM
// Design Name: 
// Module Name: mem_wb_register
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


// This module is the final pipeline register, sitting between the Memory (MEM)
// and Write Back (WB) stages. It holds the final result of an instruction.
module mem_wb_register(
    input wire clk,
    input wire reset,

    // Inputs from the MEM stage
    input wire mem_RegWrite,
    input wire mem_MemtoReg,
    input wire [31:0] mem_read_data,
    input wire [31:0] mem_alu_result,
    input wire [4:0] mem_rd,

    // Outputs to the WB stage
    output reg wb_RegWrite,
    output reg wb_MemtoReg,
    output reg [31:0] wb_read_data,
    output reg [31:0] wb_alu_result,
    output reg [4:0] wb_rd
);

    // On every rising clock edge, latch the inputs or reset.
    always @(posedge clk) begin
        if (reset) begin
            // On reset, clear all outputs to a known, safe state.
            wb_RegWrite <= 1'b0;
            wb_MemtoReg <= 1'b0;
            wb_read_data <= 32'b0;
            wb_alu_result <= 32'b0;
            wb_rd <= 5'b0;
        end
        else begin
            // In normal operation, simply pass the inputs through to the registers.
            wb_RegWrite <= mem_RegWrite;
            wb_MemtoReg <= mem_MemtoReg;
            wb_read_data <= mem_read_data;
            wb_alu_result <= mem_alu_result;
            wb_rd <= mem_rd;
        end
    end

endmodule