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
    input wire MemRead,
    input wire [2:0] funct3,        
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data     
);

    reg [31:0] memory [0:1023];
    integer i;

    wire [9:0] word_addr = address[11:2];
    wire [1:0] byte_offset = address[1:0]; // Check which byte (0,1,2,3) we are accessing

    // --- READ LOGIC (Combinational) ---
    always @(*) begin
        read_data = 32'b0;
        if (MemRead) begin
            case (funct3)
                // LB (Load Byte) - Sign Extended
                3'b000: begin
                    case(byte_offset)
                        2'b00: read_data = {{24{memory[word_addr][7]}},   memory[word_addr][7:0]};
                        2'b01: read_data = {{24{memory[word_addr][15]}},  memory[word_addr][15:8]};
                        2'b10: read_data = {{24{memory[word_addr][23]}},  memory[word_addr][23:16]};
                        2'b11: read_data = {{24{memory[word_addr][31]}},  memory[word_addr][31:24]};
                    endcase
                end
                
                // LH (Load Halfword) - Sign Extended
                3'b001: begin
                    case(byte_offset[1]) // Only check bit 1 (0 or 2)
                        1'b0: read_data = {{16{memory[word_addr][15]}}, memory[word_addr][15:0]};
                        1'b1: read_data = {{16{memory[word_addr][31]}}, memory[word_addr][31:16]};
                    endcase
                end
                
                // LW (Load Word)
                3'b010: read_data = memory[word_addr];
                
                // LBU (Load Byte Unsigned) - Zero Extended
                3'b100: begin
                    case(byte_offset)
                        2'b00: read_data = {24'b0, memory[word_addr][7:0]};
                        2'b01: read_data = {24'b0, memory[word_addr][15:8]};
                        2'b10: read_data = {24'b0, memory[word_addr][23:16]};
                        2'b11: read_data = {24'b0, memory[word_addr][31:24]};
                    endcase
                end

                // LHU (Load Halfword Unsigned) - Zero Extended
                3'b101: begin
                    case(byte_offset[1])
                        1'b0: read_data = {16'b0, memory[word_addr][15:0]};
                        1'b1: read_data = {16'b0, memory[word_addr][31:16]};
                    endcase
                end
                
                default: read_data = memory[word_addr];
            endcase
        end
    end

    // --- WRITE LOGIC (Synchronous) ---
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1) memory[i] <= 32'b0;
        end
        else if (MemWrite) begin
            case (funct3)
                // SB (Store Byte)
                3'b000: begin
                    case(byte_offset)
                        2'b00: memory[word_addr][7:0]   <= write_data[7:0];
                        2'b01: memory[word_addr][15:8]  <= write_data[7:0];
                        2'b10: memory[word_addr][23:16] <= write_data[7:0];
                        2'b11: memory[word_addr][31:24] <= write_data[7:0];
                    endcase
                end
                
                // SH (Store Halfword)
                3'b001: begin
                    case(byte_offset[1])
                        1'b0: memory[word_addr][15:0]  <= write_data[15:0];
                        1'b1: memory[word_addr][31:16] <= write_data[15:0];
                    endcase
                end
                
                // SW (Store Word)
                3'b010: memory[word_addr] <= write_data;
            endcase
        end
    end

endmodule
