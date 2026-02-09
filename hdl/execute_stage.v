`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 09:27:19 PM
// Design Name: 
// Module Name: execute_stage
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


`timescale 1ns / 1ps

module execute_stage(
    // Inputs from ID/EX Register
    input wire ex_RegWrite,
    input wire ex_MemtoReg,
    input wire ex_Branch,
    input wire ex_MemRead,
    input wire ex_MemWrite,
    input wire ex_ALUSrc,
    
    input wire [1:0] ex_ALUOp,
    input wire [31:0] ex_read_data_1,
    input wire [31:0] ex_read_data_2,
    input wire [31:0] ex_immediate,
    input wire [31:0] ex_pc_plus_4,
    input wire [4:0] ex_rd,
    input wire [2:0] ex_funct3,
    input wire [6:0] ex_funct7,
    
    // Forwarding controls
    input wire [1:0] forward_a,
    input wire [1:0] forward_b,
    input wire [31:0] mem_alu_result, // From EX/MEM (Priority 1)
    input wire [31:0] wb_alu_result,  // From MEM/WB (Priority 2)
    
    // Outputs to EX/MEM Register
    output wire mem_RegWrite_out,
    output wire mem_MemtoReg_out,
    output wire mem_MemWrite_out,
    output wire mem_MemRead_out,
    output wire [31:0] mem_alu_result_out,
    output wire [31:0] mem_write_data_out, 
    output wire mem_zero_flag_out,
    output wire [4:0] mem_rd_out,

    // Outputs for PC Mux
    output wire [31:0] branch_target_addr_out,
    output wire branch_taken_out
);

    // Internal wires
    wire [3:0] alu_control_signal;
    wire zero_flag;
    wire [31:0] alu_result;

    // These hold the values AFTER forwarding, but BEFORE ALU selection
    reg [31:0] forwarded_operand_a; 
    reg [31:0] forwarded_operand_b; 
    
    // Final ALU Input B (After ALUSrc MUX)
    wire [31:0] final_alu_input_b;


    // ------------------------------------------------------------------------
    // 1. FORWARDING MUX A (Logic for Source 1)
    // ------------------------------------------------------------------------
    always @(*) begin
        case (forward_a)
            2'b00: forwarded_operand_a = ex_read_data_1;   // No forwarding
            2'b01: forwarded_operand_a = mem_alu_result;   // Priority 1: EX Hazard
            2'b10: forwarded_operand_a = wb_alu_result;    // Priority 2: MEM Hazard
            default: forwarded_operand_a = ex_read_data_1;
        endcase
    end

    // ------------------------------------------------------------------------
    // 2. FORWARDING MUX B (Logic for Source 2)
    // ------------------------------------------------------------------------
    // Note: This forwarded value is used for TWO things:
    //       1. As an input to the ALU (if ALUSrc == 0)
    //       2. As the data to be written to memory (for Store Word instructions)
    always @(*) begin
        case (forward_b)
            2'b00: forwarded_operand_b = ex_read_data_2;   // No forwarding
            2'b01: forwarded_operand_b = mem_alu_result;   // Priority 1
            2'b10: forwarded_operand_b = wb_alu_result;    // Priority 2
            default: forwarded_operand_b = ex_read_data_2;
        endcase
    end
    // ------------------------------------------------------------------------
    // 3. ALU SOURCE MUX (Immediate vs Register)
    // ------------------------------------------------------------------------
    assign final_alu_input_b = (ex_ALUSrc) ? ex_immediate : forwarded_operand_b;


    // 4. ALU Control Unit
    alu_control ALUC (
        .ALUOp(ex_ALUOp),
        .funct3(ex_funct3),
        .funct7_bit5(ex_funct7[5]),
        .alu_control(alu_control_signal)
    );
    
    // ------------------------------------------------------------------------
    // 5. Main ALU Instantiation
    // ------------------------------------------------------------------------
    alu ALU (
        .a(forwarded_operand_a),       // <--- FORWARDING MUX HERE (DATA HAZARDS HANDELED INPUT A)
        .b(final_alu_input_b),         // <--- ALU SRC MUX HERE (DATA HAZARD HANDELED INPUT B AFTER IMMEDIATE VALUE CHECK)
        .alu_control(alu_control_signal),
        .result(alu_result),
        .zero(zero_flag)
    );
    
    // 6. Branch Logic
    // Note: Standard RISC-V branches are usually PC + Immediate.
    assign branch_target_addr_out = ex_pc_plus_4 + ex_immediate; 
    assign branch_taken_out = ex_Branch & zero_flag;


    // ------------------------------------------------------------------------
    // 7. Outputs to EX/MEM
    // ------------------------------------------------------------------------
    assign mem_RegWrite_out = ex_RegWrite;
    assign mem_MemtoReg_out = ex_MemtoReg;
    assign mem_MemWrite_out = ex_MemWrite;
    assign mem_MemRead_out = ex_MemRead;
    assign mem_alu_result_out = alu_result;
    
    // CRITICAL FIX: The data we store to memory (SW) must also be forwarded!
    assign mem_write_data_out = forwarded_operand_b; 
    
    assign mem_zero_flag_out = zero_flag;
    assign mem_rd_out = ex_rd;

endmodule

