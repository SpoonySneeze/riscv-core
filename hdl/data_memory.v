`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 02:54:45 PM
// Design Name: 
// Module Name: data_memory
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


// This module simulates the main data memory (RAM).
// It handles load (lw) and store (sw) instructions.
// Reading is combinational (asynchronous), while writing is synchronous.
module data_memory(
    input wire clk,
    input wire reset,
    input wire MemWrite,
    input wire MemRead, // Included for design completeness, but not used to gate read
    input wire [31:0] address,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);

    // 1. Memory Storage: 1024 words, each 32 bits wide.
    reg [31:0] memory [0:1023];

    // Integer for the reset loop
    integer i;

    // 2. Addressing: Convert the byte address from the ALU to a word index.
    wire [9:0] word_address = address[11:2];

    // 3. Read Logic (Combinational):
    // The output always reflects the data at the current address.
    assign read_data = memory[word_address];

    // 4. Write and Reset Logic (Synchronous):
    // These actions only happen on the rising edge of the clock.
    always @(posedge clk) begin
        if (reset) begin
            // 5. Reset Logic: Clear all memory locations to zero.
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 32'b0;
            end
        end
        // A write occurs only if the MemWrite signal is high.
        else if (MemWrite) begin
            memory[word_address] <= write_data;
        end
    end

endmodule
