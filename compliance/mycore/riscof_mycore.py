import os
import logging
import riscof.utils as utils
from riscof.pluginTemplate import pluginTemplate

class mycore(pluginTemplate):
    __model__ = "mycore"
    __version__ = "1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # 1. Capture the config so we can read paths later
        self.config = kwargs.get('config')
        # Default to standard prefix if not found
        self.riscv_prefix = self.config.get('riscv_prefix', 'riscv64-unknown-elf-')

    def initialise(self, suite, work_dir, archtest_env):
        self.work_dir = work_dir
        
        # --- FIX: Set these attributes so RISCOFF validation passes ---
        # This is the part your current file is MISSING!
        self.isa_spec = os.path.abspath(self.config['ispec'])
        self.platform_spec = os.path.abspath(self.config['pspec'])

        # Compile Command:
        # Assumes we run from the 'compliance/' folder.
        self.compile_cmd = "iverilog -o {0}/my_sim.out -I ../hdl ../hdl/*.v tb_riscof.v"

    def build(self, isa_yaml, platform_yaml):
        # 2. Compile the simulator (Only once)
        cmd = self.compile_cmd.format(self.work_dir)
        print(f"Compiling design with: {cmd}")
        utils.shellCommand(cmd).run()

    def runTests(self, testList):
        for file in testList:
            test = testList[file]
            test_dir = test['work_dir']
            elf = test['elf']
            
            sig_begin = "0x" + test['begin_signature']
            sig_end = "0x" + test['end_signature']

            # 3. Convert ELF to Hex (instructions.mem)
            objcopy = self.riscv_prefix + "objcopy"
            cmd_hex = f"{objcopy} -O verilog --verilog-data-width=4 {elf} {test_dir}/instructions.mem"
            utils.shellCommand(cmd_hex).run()

            # 4. Run Simulation
            # Copy instructions.mem to current dir so Verilog finds it, then run
            sim_cmd = f"cd {test_dir} && vvp {self.work_dir}/my_sim.out +begin_signature={sig_begin} +end_signature={sig_end}"
            utils.shellCommand(sim_cmd).run()

            # 5. Rename output
            if os.path.exists(f"{test_dir}/signature.output"):
                 utils.shellCommand(f"mv {test_dir}/signature.output {test_dir}/{self.name[:-1]}.signature").run()
