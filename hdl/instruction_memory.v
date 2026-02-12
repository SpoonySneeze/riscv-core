`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 04:46:18 PM
// Design Name: 
// Module Name: instruction_memory
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


module instruction_memory(
    input wire [31:0] read_address,
    output wire [31:0] instruction
    );
    // CHANGE 1: Size 16384
    reg [31:0] memory [0:16383];

    initial begin
        // CHANGE 2: Filename "code.mem"
        $readmemh("code.mem", memory);
    end

    // CHANGE 3: Index [15:2]
    assign instruction = memory[read_address[15:2]];
endmodule
