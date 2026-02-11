import os
import logging
import riscof.utils as utils
from riscof.pluginTemplate import pluginTemplate

class mycore(pluginTemplate):
    __model__ = "mycore"
    __version__ = "1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.riscv_prefix = kwargs.get('config').get('riscv_prefix', 'riscv64-unknown-elf-')

    def initialise(self, suite, work_dir, archtest_env):
        self.work_dir = work_dir
        self.compile_cmd = "iverilog -o {0}/my_sim.out -I ../../hdl ../../hdl/*.v ../tb_riscof.v"

    def build(self, isa_yaml, platform_yaml):
        # Compile the simulator once
        cmd = self.compile_cmd.format(self.work_dir)
        utils.shellCommand(cmd).run()

    def runTests(self, testList):
        for file in testList:
            test = testList[file]
            test_dir = test['work_dir']
            elf = test['elf']
            
            sig_begin = "0x" + test['begin_signature']
            sig_end = "0x" + test['end_signature']

            # 1. Convert ELF to Hex (instructions.mem)
            # We output directly to the test directory
            objcopy = self.riscv_prefix + "objcopy"
            cmd_hex = f"{objcopy} -O verilog --verilog-data-width=4 {elf} {test_dir}/instructions.mem"
            utils.shellCommand(cmd_hex).run()

            # 2. Run Simulation (vvp)
            # We run inside the test_dir so $readmemh finds instructions.mem
            # We point to the my_sim.out we built earlier
            sim_cmd = f"cd {test_dir} && vvp {self.work_dir}/my_sim.out +begin_signature={sig_begin} +end_signature={sig_end}"
            utils.shellCommand(sim_cmd).run()

            # 3. Rename output to matches what RISCOFF expects
            if os.path.exists(f"{test_dir}/signature.output"):
                 utils.shellCommand(f"mv {test_dir}/signature.output {test_dir}/{self.name[:-1]}.signature").run()

    def clean(self):
        pass
