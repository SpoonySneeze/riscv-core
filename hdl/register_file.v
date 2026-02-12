`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 06:05:28 PM
// Design Name: 
// Module Name: register_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 32x32 Register File with Internal Forwarding
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - Added Internal Forwarding to fix WB-ID Hazard
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module register_file(
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [4:0] read_reg_1,
    input wire [4:0] read_reg_2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data,
    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2
    );
    
    // 32 Registers of 32-bit width
    reg [31:0] registers [0:31];
    integer i;

    // Synchronous Write Logic
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else begin
            if (write_enable && write_reg != 5'b0) begin
                registers[write_reg] <= write_data;
            end
        end
    end
    
    // Asynchronous Read Logic with INTERNAL FORWARDING
    // If the register being read is the same one being written THIS cycle,
    // bypass the register array and output the write_data directly.
    
    assign read_data_1 = (read_reg_1 == 5'b0) ? 32'b0 :
                         ((read_reg_1 == write_reg && write_enable) ? write_data : registers[read_reg_1]);

    assign read_data_2 = (read_reg_2 == 5'b0) ? 32'b0 :
                         ((read_reg_2 == write_reg && write_enable) ? write_data : registers[read_reg_2]);

endmodule