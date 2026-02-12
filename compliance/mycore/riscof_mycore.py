import os
import logging
import riscof.utils as utils
from riscof.pluginTemplate import pluginTemplate

class mycore(pluginTemplate):
    __model__ = "mycore"
    __version__ = "1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.config = kwargs.get('config')

        # --- FIX: Use correct keys matching config.ini AND put in __init__ ---
        self.isa_spec = os.path.abspath(self.config['isa_spec'])
        self.platform_spec = os.path.abspath(self.config['platform_spec'])
        
        # Default to standard prefix
        self.riscv_prefix = self.config.get('riscv_prefix', 'riscv64-unknown-elf-')

    def initialise(self, suite, work_dir, archtest_env):
        self.work_dir = work_dir
        self.compile_cmd = "iverilog -o {0}/my_sim.out -I ../hdl ../hdl/*.v tb_riscof.v"

    def build(self, isa_yaml, platform_yaml):
        cmd = self.compile_cmd.format(self.work_dir)
        utils.shellCommand(cmd).run()

    def runTests(self, testList):
        for file in testList:
            test = testList[file]
            test_dir = test['work_dir']
            elf = test['elf']
            sig_begin = "0x" + test['begin_signature']
            sig_end = "0x" + test['end_signature']

            objcopy = self.riscv_prefix + "objcopy"
            utils.shellCommand(f"{objcopy} -O verilog --verilog-data-width=4 {elf} {test_dir}/instructions.mem").run()

            sim_cmd = f"cd {test_dir} && vvp {self.work_dir}/my_sim.out +begin_signature={sig_begin} +end_signature={sig_end}"
            utils.shellCommand(sim_cmd).run()

            if os.path.exists(f"{test_dir}/signature.output"):
                 utils.shellCommand(f"mv {test_dir}/signature.output {test_dir}/{self.name[:-1]}.signature").run()
