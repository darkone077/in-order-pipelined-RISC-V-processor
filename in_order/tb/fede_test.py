import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from random import randint


@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk, 10, 'ns')
    cocotb.start_soon(clock.start(start_high=False))
    eval=[0]*3
    eclr=0
    een_n=0
    await RisingEdge(dut.clk)
    
    for i in range(10000):
        val=[randint(0,4294967295),randint(0,4294967295),randint(0,4294967295)]
        cl=randint(0,1)
        enn=randint(0,1)
        
        dut.clr.value=cl
        dut.en_n.value=enn
        dut.pcf.value=val[0]
        dut.pc4f.value=val[1]
        dut.instrf.value=val[2]
        
        await RisingEdge(dut.clk)
        
        assert int(dut.pcd.value)==eval[0]
        assert int(dut.pc4d.value)==eval[1]
        assert int(dut.instrd.value)==eval[2]
        
        if(cl):
            eval=[0]*3
        elif(not enn):
            eval=val.copy()