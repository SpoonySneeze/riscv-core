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
// Revision 0.02 - Added Precision Addressing (op_a_sel)
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module execute_stage(
    // Inputs from ID/EX Register
    input wire ex_RegWrite,
    input wire ex_MemtoReg,
    input wire ex_Branch,
    input wire ex_Jump,      
    input wire [1:0] ex_op_a_sel, // <--- NEW: Select ALU A (00=RS1, 01=PC, 10=Zero)
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
    output reg branch_taken_out
);
    // Internal wires
    wire [4:0] alu_control_signal;
    wire zero_flag;
    wire [31:0] alu_result;

    // These hold the values AFTER forwarding
    reg [31:0] forwarded_operand_a; 
    reg [31:0] forwarded_operand_b;
    
    // Final ALU Inputs
    reg [31:0] final_alu_input_a; // <--- NEW MUX Output
    wire [31:0] final_alu_input_b;

    // ------------------------------------------------------------------------
    // 1. FORWARDING MUX A (Logic for Source 1)
    // ------------------------------------------------------------------------
    always @(*) begin
        case (forward_a)
            2'b00: forwarded_operand_a = ex_read_data_1; // No forwarding
            2'b01: forwarded_operand_a = mem_alu_result; // Priority 1: EX Hazard
            2'b10: forwarded_operand_a = wb_alu_result;  // Priority 2: MEM Hazard
            default: forwarded_operand_a = ex_read_data_1;
        endcase
    end

    // ------------------------------------------------------------------------
    // 2. FORWARDING MUX B (Logic for Source 2)
    // ------------------------------------------------------------------------
    always @(*) begin
        case (forward_b)
            2'b00: forwarded_operand_b = ex_read_data_2; // No forwarding
            2'b01: forwarded_operand_b = mem_alu_result; // Priority 1
            2'b10: forwarded_operand_b = wb_alu_result;  // Priority 2
            default: forwarded_operand_b = ex_read_data_2;
        endcase
    end

    // ------------------------------------------------------------------------
    // 3. ALU INPUT MUXES (The "Precision Addressing" Logic)
    // ------------------------------------------------------------------------
    
    // MUX A: Selects between RS1 (Forwarded), PC, or Zero
    always @(*) begin
        case (ex_op_a_sel)
            2'b00: final_alu_input_a = forwarded_operand_a;      // Standard (RS1)
            2'b01: final_alu_input_a = ex_pc_plus_4 - 32'd4;     // Current PC (for AUIPC / JAL)
            2'b10: final_alu_input_a = 32'b0;                    // Zero (for LUI)
            default: final_alu_input_a = forwarded_operand_a;
        endcase
    end

    // MUX B: Selects between RS2 (Forwarded) or Immediate
    assign final_alu_input_b = (ex_ALUSrc) ? ex_immediate : forwarded_operand_b;

    // 4. ALU Control Unit
    alu_control ALUC (
        .ALUOp(ex_ALUOp),
        .funct3(ex_funct3),
        .funct7(ex_funct7),
        .alu_control(alu_control_signal)
    );
    
    // ------------------------------------------------------------------------
    // 5. Main ALU Instantiation
    // ------------------------------------------------------------------------
    alu ALU (
        .a(final_alu_input_a), // <--- Uses the new MUX A
        .b(final_alu_input_b),
        .alu_control(alu_control_signal),
        .result(alu_result),
        .zero(zero_flag)
    );
    
    // ------------------------------------------------------------------------
    // 6. Branch/Jump Target Logic
    // ------------------------------------------------------------------------
    // Logic:
    // 1. If it's a JUMP (JAL/JALR), the ALU calculates the target (PC+Imm or RS1+Imm).
    // 2. If it's a BRANCH, the specific adder below calculates the target (PC+Imm).
    
    wire [31:0] branch_adder_result = ex_pc_plus_4 + ex_immediate - 32'd4;
    
    assign branch_target_addr_out = (ex_Jump) ? alu_result : branch_adder_result;
    
    always @(*)begin
        // Branch Condition Check
        if (ex_Branch) begin
            case(ex_funct3)
                3'b000: branch_taken_out = (zero_flag == 1'b1); // BEQ
                3'b001: branch_taken_out = (zero_flag == 1'b0); // BNE
                3'b100: branch_taken_out = (alu_result[0] == 1); // BLT
                3'b101: branch_taken_out = (alu_result[0] == 0); // BGE
                3'b110: branch_taken_out = (alu_result[0] == 1); // BLTU
                3'b111: branch_taken_out = (alu_result[0] == 0); // BGEU
                default: branch_taken_out = 1'b0;
            endcase
        end else begin
            branch_taken_out = 1'b0;
        end
        
        // Jump Override
        if (ex_Jump) begin
            branch_taken_out = 1'b1;
        end
    end

    // ------------------------------------------------------------------------
    // 7. Outputs to EX/MEM
    // ------------------------------------------------------------------------
    assign mem_RegWrite_out = ex_RegWrite;
    assign mem_MemtoReg_out = ex_MemtoReg;
    assign mem_MemWrite_out = ex_MemWrite;
    assign mem_MemRead_out = ex_MemRead;
    
    // JUMP FIX: If JAL/JALR, write Return Address (PC+4). Else write ALU Result.
    assign mem_alu_result_out = (ex_Jump) ? ex_pc_plus_4 : alu_result;
    
    assign mem_write_data_out = forwarded_operand_b; 
    assign mem_zero_flag_out = zero_flag;
    assign mem_rd_out = ex_rd;

endmodule