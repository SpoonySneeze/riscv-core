proc new_file {name {type "-hdl"}} {
    # --- 1. DYNAMIC CONFIGURATION ---
    # Get the folder where THIS script is saved (e.g., .../riscv-core/scripts)
    set script_path [file dirname [file normalize [info script]]]
    
    # Set paths relative to the script folder (Go up one level, then down to hdl)
    set hdl_dir "$script_path/../hdl"
    set tb_dir  "$script_path/../tb"
    
    # --- 2. Determine Type and Path ---
    if {$type == "-sim" || $type == "-tb"} {
        set path "$tb_dir/$name.v"
        set is_sim 1
        puts "Creating Simulation Source: $name"
    } else {
        set path "$hdl_dir/$name.v"
        set is_sim 0
        puts "Creating Design Source: $name"
    }

    # --- 3. Check if file exists ---
    if {[file exists $path]} {
        puts "Error: File $path already exists!"
        return
    }

    # --- 4. Create the file ---
    if {[catch {open $path "w"} f]} {
        puts "Error: Could not write to $path. Check folder permissions."
        return
    }
    
    if {$is_sim} {
        # --- Testbench Template ---
        puts $f "`timescale 1ns / 1ps"
        puts $f ""
        puts $f "module $name;"
        puts $f "    // Testbench Signals"
        puts $f "    reg clk, rst_n;"
        puts $f ""
        puts $f "    // Device Under Test (DUT) Instantiation"
        puts $f "    // dut_name u_dut (.*);"
        puts $f ""
        puts $f "    // Clock Generation"
        puts $f "    initial begin"
        puts $f "        clk = 0;"
        puts $f "        forever #5 clk = ~clk;"
        puts $f "    end"
        puts $f ""
        puts $f "    // Test Stimulus"
        puts $f "    initial begin"
        puts $f "        rst_n = 0;"
        puts $f "        #20 rst_n = 1;"
        puts $f "        // Add test cases here"
        puts $f "        #100;"
        puts $f "        \$finish;"
        puts $f "    end"
        puts $f "endmodule"
    } else {
        # --- Design Source Template ---
        puts $f "`timescale 1ns / 1ps"
        puts $f ""
        puts $f "module $name ("
        puts $f "    input wire clk,"
        puts $f "    input wire rst_n"
        puts $f ");"
        puts $f "    // Logic goes here"
        puts $f "endmodule"
    }
    close $f

    # --- 5. Add to Vivado Project ---
    if {$is_sim} {
        add_files -fileset sim_1 $path
    } else {
        add_files $path
    }
    
    puts "Success: Created $path"
}
