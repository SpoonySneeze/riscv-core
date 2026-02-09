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
    // Declare a 1K-word memory. This creates 1024 slots,
    reg [31:0] memory [0:1023];
    // Initialize the memory from a hex file at the start of simulation.
    initial begin
        $readmemh("instructions.mem",memory);
    end
    // We use bits [11:2] of the byte address to get the 10-bit word address (index).
    // The last 2 bits i.e the 0th and the 1st bit is for addressign the [1,2,3,4] bytes in the 32 bit instruction but it doesnt make sense as we featch the whole instructions at ones 
    //So, no need to take last 2 bits
    assign instruction = memory[read_address[11:2]];
endmodule
