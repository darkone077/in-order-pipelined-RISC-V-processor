import cocotb
from cocotb.triggers import Timer
import os

@cocotb.test()
async def test(dut):
    f=open((os.path.abspath("../tb/instmemtest.mem")),'r')#change instmem to instmemtest in instmem.sv module
    val=['']*3
    for i in range(3):
        val[i]=f.readline()
    await Timer(1,'ns')    
    
    for i in range(3):
        dut.mem_ad.value=i<<2
        await Timer(1,'ns')
        assert int(dut.redDat.value)==int(val[i],base=16),f"failed in {i} iter"
        
        