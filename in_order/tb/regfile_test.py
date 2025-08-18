from random import randint
import cocotb
from cocotb.triggers import FallingEdge,Timer
from cocotb.clock import Clock
REGISTERS=32
@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clock.start(start_high=True))
    
    val=[0]*REGISTERS
    for i in range(1,REGISTERS):
        val[i]=randint(0,4294967295)
    
    #writing random mem to reg    
    dut.rst_n.value=1
    dut.we3.value=1
    await FallingEdge(dut.clk)
    for i in range(1,REGISTERS):
        dut.ad3.value=i
        dut.wd3.value=val[i]
        await FallingEdge(dut.clk)
    
    #testing values of random addresses    
    dut.we3.value=0
    await FallingEdge(dut.clk)
    for i in range(10000):
        ad_1=randint(1,31)
        ad_2=randint(1,31)
        dut.ad1.value=ad_1
        dut.ad2.value=ad_2
        await Timer(1,'ns')
        assert int(dut.rd1.value)==val[ad_1],f'error in {i} iter'
        assert int(dut.rd2.value)==val[ad_2],f'error in {i} iter'
        
        