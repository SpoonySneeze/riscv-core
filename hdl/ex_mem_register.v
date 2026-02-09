`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 02:59:31 PM
// Design Name: 
// Module Name: ex_mem_register
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


// This module is a pipeline register between the Execute (EX) and Memory (MEM) stages.
// Its purpose is to hold all data and control signals for one clock cycle.
module ex_mem_register(
    input wire clk,
    input wire reset,

    // Inputs from the EX stage
    input wire ex_RegWrite,
    input wire ex_MemtoReg,
    input wire ex_MemWrite,
    input wire ex_MemRead,
    
    input wire [4:0] ex_rs1,
    input wire [4:0] ex_rs2,
    input wire [4:0] ex_rd,
    
    // Execute stage produced values
    input wire [31:0] ex_alu_result,
    input wire [31:0] ex_write_data,
    input wire ex_zero_flag,
    

    // Outputs to the MEM stage
    output reg mem_RegWrite,
    output reg mem_MemtoReg,
    output reg mem_MemWrite,
    output reg mem_MemRead,
    
    output reg [4:0] mem_rs1,
    output reg [4:0] mem_rs2,
    output reg [4:0] mem_rd,
    
    // Execute stage outputs
    output reg [31:0] mem_alu_result,
    output reg [31:0] mem_write_data,
    output reg mem_zero_flag
    
);

    // On every rising clock edge, latch the inputs or reset.
    always @(posedge clk) begin
        if (reset) begin
            // On reset, clear all outputs to a known, safe state.
            mem_RegWrite <= 1'b0;
            mem_MemtoReg <= 1'b0;
            mem_MemWrite <= 1'b0;
            mem_MemRead  <= 1'b0;
            mem_rs1 <= 5'b0;
            mem_rs2 <= 5'b0;
            mem_rd <= 5'b0;
            mem_alu_result <= 32'b0;
            mem_write_data <= 32'b0;
            mem_zero_flag  <= 1'b0;
            mem_rd         <= 5'b0;
        end
        else begin
            // In normal operation, simply pass the inputs through to the registers.
            mem_RegWrite <= ex_RegWrite;
            mem_MemtoReg <= ex_MemtoReg;
            mem_MemWrite <= ex_MemWrite;
            mem_MemRead  <= ex_MemRead;
            
            mem_rs1 <= ex_rs1;
            mem_rs2 <= ex_rs2;
            mem_rd <= ex_rd;
            
            mem_alu_result <= ex_alu_result;
            mem_write_data <= ex_write_data;
            mem_zero_flag  <= ex_zero_flag;
            mem_rd         <= ex_rd;
        end
    end

endmodule