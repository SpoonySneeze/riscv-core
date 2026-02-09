`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2026 02:44:22 PM
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit (
    // Inputs: Current Instruction (ID/EX stage)
    input wire [4:0] ex_rs1,
    input wire [4:0] ex_rs2,

    // Inputs: Forwarding Source 1 (EX/MEM stage - Distance 1)
    input wire [4:0] mem_rd,
    input wire       mem_RegWrite,
    
    // Inputs: Forwarding Source 2 (MEM/WB stage - Distance 2)
    input wire [4:0] wb_rd, 
    input wire       wb_RegWrite,  

    // Outputs: MUX Select Signals
    output reg [1:0] forward_a,  // Controls ALU Input A
    output reg [1:0] forward_b   // Controls ALU Input B
);

always @(*) begin

        // EX Hazard (Priority 1): Data is in EX/MEM stage
        if ((mem_RegWrite) && (mem_rd != 0) && (mem_rd == ex_rs1)) begin
            forward_a = 2'b01; 
        end
        // MEM Hazard (Priority 2): Data is in MEM/WB stage
        // Only check this if EX hazard is FALSE
        else if ((wb_RegWrite) && (wb_rd != 0) && (wb_rd == ex_rs1)) begin
            forward_a = 2'b10;
        end
        // Otherwise don't do anything just pass the value.
        else begin
            forward_a = 2'b00;
        end
end

always @(*) begin

        // EX Hazard (Priority 1): Data is in EX/MEM stage
        if ((mem_RegWrite) && (mem_rd != 0) && (mem_rd == ex_rs2)) begin
            forward_b = 2'b01; 
        end
        // MEM Hazard (Priority 2): Data is in MEM/WB stage
        // Only check this if EX hazard is FALSE
        else if ((wb_RegWrite) && (wb_rd != 0) && (wb_rd == ex_rs2)) begin
            forward_b = 2'b10;
        end
        // Otherwise don't do anything just pass the value.
        else begin
            forward_b = 2'b00;
        end
end

endmodule