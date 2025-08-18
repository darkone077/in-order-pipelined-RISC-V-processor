from pathlib import Path
from cocotb.runner import get_runner
import os

def tb_runner(mod):
    sim=os.getenv("SIM","verilator")
    path=Path(__file__).resolve().parent.parent
    srcs=[path/f'src/{mod}.sv']
    runner=get_runner(sim)
    runner.build(hdl_toplevel=f"{mod}",sources=srcs)
    
    runner.test(hdl_toplevel=f'{mod}',test_module=f'{mod}_test')
    
if __name__=="__main__":
    tb_runner('alu')
    tb_runner('ctrl')
    tb_runner('datmem')
    tb_runner('deex')
    tb_runner('exme')
    tb_runner('extend')
    tb_runner('fede')
    tb_runner('hazardunit')
    tb_runner('instmem')
    tb_runner('mewb')
    tb_runner('regfile')
    tb_runner('pc')