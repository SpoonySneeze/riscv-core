`timescale 1ns/1ps

module tb_riscof;
    reg clk;
    reg reset;
    
    // Instantiate your Top Level
    risc_v_top dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Signature Dumping Variables
    integer i, file_handle;
    reg [31:0] begin_signature;
    reg [31:0] end_signature;
    reg [31:0] signature_data;

    initial begin
        // 1. Get Signature Addresses from arguments
        if (!$value$plusargs("begin_signature=%h", begin_signature)) begin
            $display("Error: begin_signature not provided");
            $finish;
        end
        if (!$value$plusargs("end_signature=%h", end_signature)) begin
            $display("Error: end_signature not provided");
            $finish;
        end

        // 2. Reset Sequence
        reset = 1;
        #20 reset = 0;

        // 3. Run Simulation (Timeout protection)
        #500000;

        // 4. Dump Signature to File
        file_handle = $fopen("signature.output", "w");
        
        // Loop through your Data Memory (DMEM)
        // Adjust 'dut.DMEM.memory' if your instance names differ!
        for (i = begin_signature; i < end_signature; i = i + 4) begin
            // Accessing internal memory array:
            // address >> 2 converts byte address to word index
            signature_data = dut.DMEM.memory[i[15:2]]; 
            $fdisplay(file_handle, "%h", signature_data);
        end
        
        $fclose(file_handle);
        $display("Signature dumped. Simulation finished.");
        $finish;
    end
endmodule
