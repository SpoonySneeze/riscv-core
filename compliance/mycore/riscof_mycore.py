import os
import logging
import riscof.utils as utils
from riscof.pluginTemplate import pluginTemplate

class mycore(pluginTemplate):
    __model__ = "mycore"
    __version__ = "1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # SAVE THE CONFIG: This was missing and caused the AttributeError!
        self.config = kwargs.get('config')
        self.riscv_prefix = self.config.get('riscv_prefix', 'riscv64-unknown-elf-')

    def initialise(self, suite, work_dir, archtest_env):
        self.work_dir = work_dir
        
        # REQUIRED: Set these attributes so RISCOFF can validate them
        # We read them from the config dictionary we saved earlier
        self.isa_spec = os.path.abspath(self.config['ispec'])
        self.platform_spec = os.path.abspath(self.config['pspec'])

        # Compile Command:
        # We assume riscof runs from the 'compliance/' folder.
        # ../hdl       -> points to your source code
        # tb_riscof.v  -> points to your testbench in the current folder
        self.compile_cmd = "iverilog -o {0}/my_sim.out -I ../hdl ../hdl/*.v tb_riscof.v"

    def build(self, isa_yaml, platform_yaml):
        # Compile the simulator ONCE here
        # {0} will be replaced by self.work_dir (riscof_work)
        cmd = self.compile_cmd.format(self.work_dir)
        print(f"Compiling with: {cmd}")
        utils.shellCommand(cmd).run()

    def runTests(self, testList):
        for file in testList:
            test = testList[file]
            test_dir = test['work_dir']
            elf = test['elf']
            
            sig_begin = "0x" + test['begin_signature']
            sig_end = "0x" + test['end_signature']

            # 1. Convert ELF to Hex (instructions.mem)
            # We use objcopy to create a hex file that $readmemh can read
            objcopy = self.riscv_prefix + "objcopy"
            cmd_hex = f"{objcopy} -O verilog --verilog-data-width=4 {elf} {test_dir}/instructions.mem"
            utils.shellCommand(cmd_hex).run()

            # 2. Run Simulation (vvp)
            # We copy instructions.mem to the current directory so the sim finds it.
            # Then we run the pre-compiled binary (my_sim.out).
            sim_cmd = f"cd {test_dir} && vvp {self.work_dir}/my_sim.out +begin_signature={sig_begin} +end_signature={sig_end}"
            utils.shellCommand(sim_cmd).run()

            # 3. Rename output to match what RISCOFF expects
            # Our testbench writes 'signature.output', RISCOFF wants 'DUT.signature'
            if os.path.exists(f"{test_dir}/signature.output"):
                 utils.shellCommand(f"mv {test_dir}/signature.output {test_dir}/{self.name[:-1]}.signature").run()
