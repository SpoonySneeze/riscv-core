import os
import re
import shutil
import subprocess
import shlex
import logging
import random
import string
from string import Template
import sys

import riscof.utils as utils
import riscof.constants as constants
from riscof.pluginTemplate import pluginTemplate

logger = logging.getLogger()

class spoonysneeze_core(pluginTemplate):
    __model__ = "spoonysneeze_core"

    #TODO: please update the below to indicate family, version, etc of your DUT.
    __version__ = "1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        config = kwargs.get('config')

        if config is None:
            print("Please enter input file paths in configuration.")
            raise SystemExit(1)

        self.dut_exe = os.path.join(config['PATH'] if 'PATH' in config else "","spoonysneeze_core")
        self.num_jobs = str(config['jobs'] if 'jobs' in config else 1)
        self.pluginpath = os.path.abspath(config['pluginpath'])
        self.isa_spec = os.path.abspath(config['ispec'])
        self.platform_spec = os.path.abspath(config['pspec'])

        if 'target_run' in config and config['target_run']=='0':
            self.target_run = False
        else:
            self.target_run = True

    def initialise(self, suite, work_dir, archtest_env):
       self.work_dir = work_dir
       self.suite_dir = suite

       # UPDATED: Using riscv-none-elf-gcc for xPack toolchain
       self.compile_cmd = 'riscv-none-elf-gcc -march={0} \
         -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g\
         -T '+self.pluginpath+'/env/link.ld\
         -I '+self.pluginpath+'/env/\
         -I ' + archtest_env + ' {2} -o {3} {4}'

    def build(self, isa_yaml, platform_yaml):
      ispec = utils.load_yaml(isa_yaml)['hart0']
      self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')

      self.isa = 'rv' + self.xlen
      if "I" in ispec["ISA"]: self.isa += 'i'
      if "M" in ispec["ISA"]: self.isa += 'm'
      if "F" in ispec["ISA"]: self.isa += 'f'
      if "D" in ispec["ISA"]: self.isa += 'd'
      if "C" in ispec["ISA"]: self.isa += 'c'

      # Compiler flags for ABI
      self.compile_cmd = self.compile_cmd+' -mabi='+('lp64 ' if 64 in ispec['supported_xlen'] else 'ilp32 ')

    def runTests(self, testList):
      # Delete Makefile if it already exists.
      if os.path.exists(self.work_dir+ "/Makefile." + self.name[:-1]):
            os.remove(self.work_dir+ "/Makefile." + self.name[:-1])
      
      make = utils.makeUtil(makefilePath=os.path.join(self.work_dir, "Makefile." + self.name[:-1]))
      make.makeCommand = 'make -k -j' + self.num_jobs

      for testname in testList:
          # Extract test metadata
          testentry = testList[testname]
          test_dir = testentry['work_dir']
          elf = 'my.elf'
          sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")
          compile_macros = ' -D' + " -D".join(testentry['macros'])
          marchstr = testentry['isa'].lower()
          
          # 1. Compile Assembly to ELF
          cmd = self.compile_cmd.format(marchstr, self.xlen, testentry['test_path'], elf, compile_macros)

          if self.target_run:
            # 2. Convert ELF to Hex (code.mem)
            # UPDATED: Uses riscv-none-elf-objcopy
            #            This forces the code at 0x80000000 to move to 0x00000000 in the file
            elf2hex = f"riscv-none-elf-objcopy -O verilog --change-addresses -0x80000000 {elf} code.mem"            
            # 3. Compile Verilog (RTL + Testbench)
            # Points to ../hdl/*.v and ../tb/tb_compliance.v
            sim_compile = (
                f"iverilog -g2012 -o sim.out "
                f"-I {self.pluginpath}/../hdl "
                f"{self.pluginpath}/../hdl/*.v "
                f"{self.pluginpath}/../tb/tb_compliance.v"
            )
            
            # 4. Run Simulation
            sim_run = "vvp sim.out"

            # 5. Move Signature
            post_process = f"mv signature.output {sig_file}"

            # Combine all commands
            simcmd = f"{cmd} && {elf2hex} && {sim_compile} && {sim_run} && {post_process}"
          else:
              simcmd = 'echo "NO RUN"'

          make.add_target(simcmd, tname=testname)

      make.execute_all(self.work_dir)

      if not self.target_run:
          raise SystemExit(0)
