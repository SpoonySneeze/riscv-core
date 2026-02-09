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
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
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
    
    //The register file must have 32 entries (0 to 31).
    reg [31:0] registers [0:31];
    
    integer i;

    // Synchronous write port logic
    always @(posedge clk) begin
        // CORRECTION 2: Use a 'for' loop to reset all 32 registers.
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else begin
            // It checks for write enable and ensures we don't write to x0.
            if (write_enable && write_reg != 5'b0) begin
                registers[write_reg] <= write_data;
            end
        end
    end
    
    // Asynchronous read ports
    // logic to enforce that reading register 0 always returns 0.
    // This is the "hardwired to zero" feature of x0.
    assign read_data_1 = (read_reg_1 == 5'b0) ? 32'b0 : registers[read_reg_1];
    assign read_data_2 = (read_reg_2 == 5'b0) ? 32'b0 : registers[read_reg_2];
    
endmodule
