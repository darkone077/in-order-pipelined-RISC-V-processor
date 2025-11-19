from random import randint
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
WORDS=64

@cocotb.coroutine
async def reset(dut):
    await RisingEdge(dut.clk)
    dut.rst.value=1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value=0
    
    for i in range(WORDS):
        dut.mem_ad.value=i<<2
        await RisingEdge(dut.clk)
        assert int(dut.redDat.value)==0
    
    
@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clock.start(start_high=False))
    
    val=[0]*WORDS
    for i in range(WORDS):
        val[i]=randint(0,4294967295)
        
    dut.rst.value=0
    await RisingEdge(dut.clk)
    for i in range(WORDS):
        dut.mem_ad.value=i<<2
        dut.memWrt.value=1
        dut.wrtDat.value=val[i]
        await RisingEdge(dut.clk)
        
    dut.memWrt.value=0
    eval=val[0]
    await RisingEdge(dut.clk)
    for i in range(WORDS-1):
        dut.mem_ad.value=i<<2
        await RisingEdge(dut.clk)
        
        assert int(dut.redDat.value)==eval,f'error in {i} iter'
        eval=val[i+1]
        
    reset(dut)