`timescale 1ns / 1ps

module tb_compliance;
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
initial begin
    #1000000; // Wait for 1,000,000 ns (1 ms)
    $display("ERROR: Simulation timed out!");
    $finish;
end
    // Signature Dumping Logic
    integer f;
    initial begin
        // 1. Initialize and Reset
        reset = 1;
        #20 reset = 0;

        // 2. Monitor for Halt Loop
        // We detect the halt when the PC stays the same for many cycles
        // or matches the specific address of your halt_loop.
        wait (dut.pc_module.addr == 32'h0000_0000); // Adjust address as needed
        
        // 3. Dump the Signature
        // RISCOF expects a file with the memory contents
        f = $fopen("signature.output", "w");
        
        // We start from your 'begin_signature' address
        // Assuming word index 192 (0x300) as discussed
        for (int i = 192; i < 256; i = i + 1) begin
            $fdisplay(f, "%h", dut.DMEM.memory[i]);
        end
        
        $fclose(f);
        $display("Compliance Test Finished. Signature saved.");
        $finish;
    end
endmodule
