`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 09:41:10 AM
// Design Name: 
// Module Name: id_ex_register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - Added op_a_sel and Jump signals
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module id_ex_register(
    input wire clk,
    input wire reset,
    input wire flush,

    // --- Inputs from ID Stage ---

    // Control Signals (to be passed through to MEM/WB)
    input wire id_RegWrite,
    input wire id_MemtoReg,
    input wire id_MemRead,
    input wire id_MemWrite,
    
    // Control Signals (for the EX Stage)
    input wire id_Branch,
    input wire id_Jump,      
    input wire [1:0] id_op_a_sel, // <--- NEW: Operand A Selection
    input wire id_ALUSrc,
    input wire [1:0] id_ALUOp,

    // Data Values
    input wire [31:0] id_read_data_1,
    input wire [31:0] id_read_data_2,
    input wire [31:0] id_immediate,
    
    //Addresses
    input wire [4:0] id_rs1,
    input wire [4:0] id_rs2,
    input wire [31:0] id_pc_plus_4,

    // Housekeeping/Forwarding Data
    input wire [4:0] id_rd,
    input wire [2:0] id_funct3,
    input wire [6:0] id_funct7,
    
    // --- Outputs to EX Stage ---

    // Control Signals
    output reg ex_RegWrite,
    output reg ex_MemtoReg,
    output reg ex_Branch,
    output reg ex_Jump,      
    output reg [1:0] ex_op_a_sel, // <--- NEW
    output reg ex_MemRead,
    output reg ex_MemWrite,
    output reg ex_ALUSrc,
    output reg [1:0] ex_ALUOp,

    // Data Values
    output reg [31:0] ex_read_data_1,
    output reg [31:0] ex_read_data_2,
    output reg [31:0] ex_immediate,
    
    //Addresses
    output reg [4:0] ex_rs1,
    output reg [4:0] ex_rs2,
    output reg [31:0] ex_pc_plus_4,
    
    // Housekeeping/Forwarding Data
    output reg [4:0] ex_rd,
    output reg [2:0] ex_funct3,
    output reg [6:0] ex_funct7
);

    always @(posedge clk) begin
        if (reset || flush) begin
            // Reset state
            ex_RegWrite <= 1'b0;
            ex_MemtoReg <= 1'b0;
            ex_Branch   <= 1'b0;
            ex_Jump     <= 1'b0;
            ex_op_a_sel <= 2'b00; // Default to RS1
            ex_MemRead  <= 1'b0;
            ex_MemWrite <= 1'b0;
            ex_ALUSrc   <= 1'b0;
            ex_ALUOp    <= 2'b0;
            
            ex_read_data_1 <= 32'b0;
            ex_read_data_2 <= 32'b0;
            ex_immediate   <= 32'b0;
            ex_rs1 <= 5'b0;
            ex_rs2 <= 5'b0;
            ex_pc_plus_4   <= 32'b0;
            ex_rd       <= 5'b0;
            ex_funct3   <= 3'b0;
            ex_funct7   <= 7'b0;
        end
        else begin
            // Pass through
            ex_RegWrite <= id_RegWrite;
            ex_MemtoReg <= id_MemtoReg;
            ex_Branch   <= id_Branch;
            ex_Jump     <= id_Jump;
            ex_op_a_sel <= id_op_a_sel; // Pass NEW signal
            ex_MemRead  <= id_MemRead;
            ex_MemWrite <= id_MemWrite;
            ex_ALUSrc   <= id_ALUSrc;
            ex_ALUOp    <= id_ALUOp;

            ex_read_data_1 <= id_read_data_1;
            ex_read_data_2 <= id_read_data_2;
            ex_immediate   <= id_immediate;
            ex_rs1 <= id_rs1;
            ex_rs2 <= id_rs2;
            ex_pc_plus_4   <= id_pc_plus_4;
            ex_rd       <= id_rd;
            ex_funct3   <= id_funct3;
            ex_funct7   <= id_funct7;
        end
    end

endmodule