`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 05:03:29 PM
// Design Name: 
// Module Name: if_id_register
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

module if_id_register(
    input wire clk,
    input wire reset,
    input wire flush, // For handling the control hazards due to the beq instruction
    input wire stall,
    input wire [31:0] if_instruction,
    input wire [31:0] if_pc_plus_4,     // FIXED: Renamed from if_pc to match Top Level
    output wire [31:0] id_instruction,
    output wire [31:0] id_pc_plus_4     // FIXED: Renamed from id_pc to match Top Level
    );

    // Internal registers to hold the pipeline state for one cycle.
    reg [31:0] instruction_reg;
    reg [31:0] pc_reg;

    // On the rising edge of the clock...
    always @(posedge clk) begin
        // First, check for a reset signal.
        if (reset) begin
            instruction_reg <= 32'b0;
            pc_reg <= 32'b0;
        end  
        
        else if(flush == 1'b1)begin
            instruction_reg <= 32'b0;
            pc_reg <= 32'b0;
        end
        
        else if (stall) begin
            // If Stalled: Do NOTHING. Keep old values.
            instruction_reg <= instruction_reg;
            pc_reg   <= pc_reg;
        end
        
        else begin
            // Otherwise, latch the inputs from the IF stage.
            instruction_reg <= if_instruction;
            pc_reg <= if_pc_plus_4;
        end
    end

    // Continuously assign the output wires from our internal registers.
    assign id_instruction = instruction_reg;
    assign id_pc_plus_4   = pc_reg;
    
endmodule