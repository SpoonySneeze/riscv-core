`timescale 1ns / 1ps

module riscv_tb();
    reg clk;
    reg reset;

    // Instantiate your Top Level Core
    risc_v_top dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test Sequence
    initial begin
        reset = 1;
        #20 reset = 0; // Release reset after 2 clock cycles
        
        // Let the simulation run for a set time or until a halt condition
        #2000; 
        
        // SIGNATURE DUMP: Required for Imperas/RISC-V compliance tests
        // Your data_memory.v has a 64KB memory array named 'memory'
        $writememh("rtl_signature.output", dut.DMEM.memory, 16'h0000, 16'h0FFF);
        
        $display("Simulation Finished. Signature dumped to rtl_signature.output");
        $finish;
    end
endmodule
