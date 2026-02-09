`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2025 12:08:34 AM
// Design Name: 
// Module Name: write_back_stage
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


module write_back_stage(
    input wire wb_RegWrite,
    input wire wb_MemtoReg,
    input wire [31:0] wb_alu_result,
    input wire [31:0] wb_read_data,
    input wire [4:0] wb_rd,
    output wire [31:0] write_value,
    output wire out_reg_write,
    output wire [4:0] out_rd
    );
    
    // When mem_to_reg is 1 (for lw), select wb_read_data.
    // When mem_to_reg is 0 (for R-type/addi), select wb_alu_result.
    assign write_value = (wb_MemtoReg) ? wb_read_data : wb_alu_result;
    
    assign out_reg_write = (wb_rd==5'b0)?1'b0:wb_RegWrite;
    assign out_rd = wb_rd;
endmodule
