`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 09:13:20 PM
// Design Name: 
// Module Name: decode_stage
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



module decode_stage(
    input wire clk,
    input wire reset,
    input wire [31:0] instruction_to_decode,
    
    // Inputs from Write-Back Stage
    input wire wb_reg_write,
    input wire [4:0] wb_write_reg_addr,
    input wire [31:0] wb_write_data,
    
    // Outputs to ID/EX Register
    output wire [31:0] immediate,
    output wire reg_write,
    output wire mem_to_reg,
    output wire mem_read,
    output wire mem_write,
    output wire branch,
    output wire jump,
    output wire [1:0] op_a_sel, // <--- NEW: Output Port
    output wire alu_src,
    output wire [1:0] alu_op,
    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2,
    output wire [2:0] fun3,
    output wire [6:0] fun7,
    output wire [4:0] destination_register
    );
    
    wire [4:0] rs1_addr = instruction_to_decode[19:15];
    wire [4:0] rs2_addr = instruction_to_decode[24:20];

    // 1. Control Unit
    control_unit CU (
        .opcode(instruction_to_decode[6:0]),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .op_a_sel(op_a_sel), // <--- NEW: Connected
        .alu_src(alu_src),
        .alu_op(alu_op)
    );
    
    // 2. Register File
    register_file RF (
        .clk(clk),
        .reset(reset),
        .write_enable(wb_reg_write),
        .read_reg_1(rs1_addr),
        .read_reg_2(rs2_addr),
        .write_reg(wb_write_reg_addr), 
        .write_data(wb_write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    // 3. Immediate Generator
    immediate_generator IG (
        .instruction(instruction_to_decode),
        .immediate(immediate)
    );

    assign fun3 = instruction_to_decode[14:12];
    assign fun7 = instruction_to_decode[31:25];
    assign destination_register = instruction_to_decode[11:7];
endmodule