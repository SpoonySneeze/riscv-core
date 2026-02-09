`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 12:24:15 AM
// Design Name: 
// Module Name: hazard_detection_unit
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

module hazard_detection_unit(
    // Inputs from ID Stage (Current Instruction being decoded)
    input wire [4:0] id_rs1,
    input wire [4:0] id_rs2,

    // Inputs from EX Stage (The instruction ahead of us)
    input wire [4:0] ex_rd,
    input wire       ex_MemRead, // 1 if instruction in EX is a Load (LW)

    // Outputs
    output reg stall_pipeline   // 1 = Stall everything!
);

    always @(*) begin
        // Default: Don't stall
        stall_pipeline = 1'b0;

        // Check for Load-Use Hazard
        // 1. Is the previous instruction a Load? (ex_MemRead)
        // 2. Is it writing to a register we need? (ex_rd == id_rs1 OR ex_rd == id_rs2)
        if (ex_MemRead && (ex_rd != 0) && ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
            stall_pipeline = 1'b1;
        end
    end

endmodule
