`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 12:34:48 AM
// Design Name: 
// Module Name: risc_v_top
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


module risc_v_top(
    input wire clk,
    input wire reset
);

    // ===========================================================================
    // WIRE DEFINITIONS
    // ===========================================================================

    // --- IF Stage ---
    wire [31:0] current_pc;
    wire [31:0] next_pc;
    wire [31:0] pc_plus_4;
    wire [31:0] if_instruction;
    
    // --- ID Stage ---
    wire [31:0] id_pc_plus_4;
    wire [31:0] id_instruction;
    wire [31:0] id_immediate;
    wire [31:0] id_read_data_1;
    wire [31:0] id_read_data_2;
    wire [4:0]  id_rs1_addr; // Extracted directly from instruction [19:15]
    wire [4:0]  id_rs2_addr; // Extracted directly from instruction [24:20]
    wire [4:0]  id_rd;
    wire [2:0]  id_funct3;
    wire [6:0]  id_funct7;
    
    // Control Signals (ID)
    wire id_RegWrite, id_MemtoReg, id_MemRead, id_MemWrite;
    wire id_Branch, id_ALUSrc;
    wire [1:0] id_ALUOp;

    // --- EX Stage ---
    wire [31:0] ex_pc_plus_4;
    wire [31:0] ex_read_data_1;
    wire [31:0] ex_read_data_2;
    wire [31:0] ex_immediate;
    wire [4:0]  ex_rs1, ex_rs2, ex_rd;
    wire [2:0]  ex_funct3;
    wire [6:0]  ex_funct7;
    
    // Control Signals (EX)
    wire ex_RegWrite, ex_MemtoReg, ex_MemRead, ex_MemWrite, ex_Branch, ex_ALUSrc;
    wire [1:0] ex_ALUOp;

    // --- Hazard & Forwarding Wires ---
    wire stall_pipeline;       // From Hazard Unit (Stalls PC and IF/ID)
    wire branch_taken;         // From Execute Stage (Flush IF/ID and ID/EX)
    wire [1:0] forward_a;      // From Forwarding Unit
    wire [1:0] forward_b;      // From Forwarding Unit
    wire [31:0] branch_target_addr;
    wire id_ex_flush_signal;   // Combined flush signal

    // --- MEM Stage ---
    wire mem_RegWrite, mem_MemtoReg, mem_MemWrite, mem_MemRead;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_write_data; // Data to store (SW)
    wire [31:0] mem_read_data;  // Data loaded (LW)
    wire [4:0]  mem_rd;
    wire [31:0] mem_alu_result_in; // Input to EX/MEM reg
    wire [31:0] mem_write_data_in; // Input to EX/MEM reg
    wire [4:0]  mem_rd_in;         // Input to EX/MEM reg
    wire mem_RegWrite_in, mem_MemtoReg_in, mem_MemWrite_in, mem_MemRead_in;
    wire mem_zero_flag_in, mem_zero_flag_unused;
    wire [4:0] mem_rs1_unused, mem_rs2_unused; // Not used in MEM stage

    // --- WB Stage ---
    wire wb_RegWrite, wb_MemtoReg;
    wire [31:0] wb_read_data;
    wire [31:0] wb_alu_result;
    wire [4:0]  wb_rd;
    wire [31:0] final_write_data;     // The value actually written back to RegFile
    wire final_reg_write_enable;      // The enable signal (checked for x0)
    wire [4:0] final_write_reg_addr;  // The destination register

    // ===========================================================================
    // 1. INSTRUCTION FETCH (IF) STAGE
    // ===========================================================================

    // PC Logic: 
    // 1. If Stall is active, PC stays same.
    // 2. Else If Branch Taken, PC jumps to target.
    // 3. Else PC = PC + 4.
    assign pc_plus_4 = current_pc + 32'd4;
    
    assign next_pc = (stall_pipeline) ? current_pc : ((branch_taken) ? branch_target_addr : pc_plus_4);

    PC pc_module (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    instruction_memory imem (
        .read_address(current_pc),
        .instruction(if_instruction)
    );

    // ===========================================================================
    // IF/ID PIPELINE REGISTER
    // ===========================================================================
    if_id_register IF_ID_REG (
        .clk(clk),
        .reset(reset),
        .flush(branch_taken),   // FLUSH if branch taken
        .stall(stall_pipeline), // STALL if Load-Use detected
        .if_instruction(if_instruction),
        .if_pc_plus_4(pc_plus_4),
        .id_instruction(id_instruction),
        .id_pc_plus_4(id_pc_plus_4)
    );

    // ===========================================================================
    // 2. INSTRUCTION DECODE (ID) STAGE
    // ===========================================================================

    decode_stage ID_STAGE (
        .clk(clk),
        .reset(reset),
        .instruction_to_decode(id_instruction),
        
        // Write Back Inputs (Feedback from WB Stage)
        .wb_reg_write(final_reg_write_enable), 
        .wb_write_reg_addr(final_write_reg_addr),
        .wb_write_data(final_write_data),
        
        // Outputs
        .immediate(id_immediate),
        .reg_write(id_RegWrite),
        .mem_to_reg(id_MemtoReg),
        .mem_read(id_MemRead),
        .mem_write(id_MemWrite),
        .branch(id_Branch),
        .alu_src(id_ALUSrc),
        .alu_op(id_ALUOp),
        .read_data_1(id_read_data_1),
        .read_data_2(id_read_data_2),
        .fun3(id_funct3),
        .fun7(id_funct7),
        .destination_register(id_rd)
    );

    // Extract rs1 and rs2 addresses for Hazard Unit
    assign id_rs1_addr = id_instruction[19:15];
    assign id_rs2_addr = id_instruction[24:20];

    // --- HAZARD DETECTION UNIT ---
    hazard_detection_unit HAZARD_UNIT (
        .id_rs1(id_rs1_addr),
        .id_rs2(id_rs2_addr),
        .ex_rd(ex_rd),
        .ex_MemRead(ex_MemRead),
        .stall_pipeline(stall_pipeline) 
    );
    
    // We flush ID/EX if:
    // 1. Branch is taken (Kill bad instruction in ID)
    // 2. OR Stall is active (Insert bubble into EX while ID holds)
    assign id_ex_flush_signal = branch_taken || stall_pipeline;

    // ===========================================================================
    // ID/EX PIPELINE REGISTER
    // ===========================================================================
    id_ex_register ID_EX_REG (
        .clk(clk),
        .reset(reset),
        .flush(id_ex_flush_signal), 
        
        // Control Inputs
        .id_RegWrite(id_RegWrite), 
        .id_MemtoReg(id_MemtoReg), 
        .id_MemRead(id_MemRead), 
        .id_MemWrite(id_MemWrite),
        .id_Branch(id_Branch), 
        .id_ALUSrc(id_ALUSrc), 
        .id_ALUOp(id_ALUOp),
        
        // Data Inputs
        .id_read_data_1(id_read_data_1), 
        .id_read_data_2(id_read_data_2),
        .id_immediate(id_immediate), 
        .id_pc_plus_4(id_pc_plus_4),
        .id_rs1(id_rs1_addr), 
        .id_rs2(id_rs2_addr), 
        .id_rd(id_rd), 
        .id_funct3(id_funct3), 
        .id_funct7(id_funct7),
        
        // Outputs
        .ex_RegWrite(ex_RegWrite), 
        .ex_MemtoReg(ex_MemtoReg),
        .ex_MemRead(ex_MemRead), 
        .ex_MemWrite(ex_MemWrite),
        .ex_Branch(ex_Branch), 
        .ex_ALUSrc(ex_ALUSrc), 
        .ex_ALUOp(ex_ALUOp),
        .ex_read_data_1(ex_read_data_1), 
        .ex_read_data_2(ex_read_data_2),
        .ex_immediate(ex_immediate), 
        .ex_pc_plus_4(ex_pc_plus_4),
        .ex_rs1(ex_rs1), 
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd), 
        .ex_funct3(ex_funct3), 
        .ex_funct7(ex_funct7)
    );

    // ===========================================================================
    // 3. EXECUTE (EX) STAGE
    // ===========================================================================

    // --- FORWARDING UNIT ---
    forwarding_unit FWD_UNIT (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .mem_rd(mem_rd),        // Hazard 1 (EX/MEM)
        .mem_RegWrite(mem_RegWrite),
        .wb_rd(wb_rd),          // Hazard 2 (MEM/WB)
        .wb_RegWrite(wb_RegWrite),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    execute_stage EX_STAGE (
        // Inputs
        .ex_RegWrite(ex_RegWrite), 
        .ex_MemtoReg(ex_MemtoReg),
        .ex_Branch(ex_Branch), 
        .ex_MemRead(ex_MemRead),
        .ex_MemWrite(ex_MemWrite), 
        .ex_ALUSrc(ex_ALUSrc),
        .ex_ALUOp(ex_ALUOp),
        .ex_read_data_1(ex_read_data_1), 
        .ex_read_data_2(ex_read_data_2),
        .ex_immediate(ex_immediate), 
        .ex_pc_plus_4(ex_pc_plus_4),
        .ex_rd(ex_rd), 
        .ex_funct3(ex_funct3), 
        .ex_funct7(ex_funct7),
        
        // Forwarding
        .forward_a(forward_a),
        .forward_b(forward_b),
        .mem_alu_result(mem_alu_result), // Forward from MEM
        .wb_alu_result(final_write_data), // Forward from WB (Must use final WB value!)
        
        // Outputs
        .mem_RegWrite_out(mem_RegWrite_in), 
        .mem_MemtoReg_out(mem_MemtoReg_in),
        .mem_MemWrite_out(mem_MemWrite_in), 
        .mem_MemRead_out(mem_MemRead_in),
        .mem_alu_result_out(mem_alu_result_in),
        .mem_write_data_out(mem_write_data_in),
        .mem_zero_flag_out(mem_zero_flag_in),
        .mem_rd_out(mem_rd_in),
        .branch_target_addr_out(branch_target_addr),
        .branch_taken_out(branch_taken)
    );

    // ===========================================================================
    // EX/MEM PIPELINE REGISTER
    // ===========================================================================
    ex_mem_register EX_MEM_REG (
        .clk(clk),
        .reset(reset),
        
        // Inputs
        .ex_RegWrite(mem_RegWrite_in), 
        .ex_MemtoReg(mem_MemtoReg_in),
        .ex_MemWrite(mem_MemWrite_in), 
        .ex_MemRead(mem_MemRead_in),
        .ex_rs1(5'b0),
        .ex_rs2(5'b0), // Not used in later stages
        .ex_rd(mem_rd_in),
        .ex_alu_result(mem_alu_result_in),
        .ex_write_data(mem_write_data_in),
        .ex_zero_flag(mem_zero_flag_in),
        
        // Outputs
        .mem_RegWrite(mem_RegWrite), 
        .mem_MemtoReg(mem_MemtoReg),
        .mem_MemWrite(mem_MemWrite), 
        .mem_MemRead(mem_MemRead),
        .mem_rs1(mem_rs1_unused), 
        .mem_rs2(mem_rs2_unused),
        .mem_rd(mem_rd),
        .mem_alu_result(mem_alu_result),
        .mem_write_data(mem_write_data),
        .mem_zero_flag(mem_zero_flag_unused)
    );

    // ===========================================================================
    // 4. MEMORY (MEM) STAGE
    // ===========================================================================

    data_memory DMEM (
        .clk(clk),
        .reset(reset),
        .MemWrite(mem_MemWrite),
        .MemRead(mem_MemRead),
        .address(mem_alu_result),
        .write_data(mem_write_data),
        .read_data(mem_read_data)
    );

    // ===========================================================================
    // MEM/WB PIPELINE REGISTER
    // ===========================================================================
    mem_wb_register MEM_WB_REG (
        .clk(clk),
        .reset(reset),
        
        // Inputs
        .mem_RegWrite(mem_RegWrite),
        .mem_MemtoReg(mem_MemtoReg),
        .mem_read_data(mem_read_data),
        .mem_alu_result(mem_alu_result),
        .mem_rd(mem_rd),
        
        // Outputs
        .wb_RegWrite(wb_RegWrite),
        .wb_MemtoReg(wb_MemtoReg),
        .wb_read_data(wb_read_data),
        .wb_alu_result(wb_alu_result),
        .wb_rd(wb_rd)
    );

    // ===========================================================================
    // 5. WRITE BACK (WB) STAGE
    // ===========================================================================

    write_back_stage WB_STAGE (
        .wb_RegWrite(wb_RegWrite),
        .wb_MemtoReg(wb_MemtoReg),
        .wb_alu_result(wb_alu_result),
        .wb_read_data(wb_read_data),
        .wb_rd(wb_rd),
        
        // Outputs
        .write_value(final_write_data),
        .out_reg_write(final_reg_write_enable),
        .out_rd(final_write_reg_addr)
    );

endmodule