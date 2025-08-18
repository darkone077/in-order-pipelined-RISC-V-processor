import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer,FallingEdge
from cocotb.binary import BinaryValue
import random

def binary(num, bit):
    if num==0:
        return '0'*bit
    
    stri=""
    while(bit):
        t=num%2
        stri=str(t)+stri
        num=num//2
        bit-=1

        
    return stri



@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,units="ns")
    cocotb.start_soon(clock.start(start_high=False))
    
    await RisingEdge(dut.clk)
    eval=0
    dut.en_n.value=0
    for i in range(10):
        val=random.randint(0,1)
        jval=random.randint(0,1000)
        pc4val=eval+4
        dut.pc4.value=pc4val
        dut.pcj.value=jval
        dut.pc_src.value=val
        
        await RisingEdge(dut.clk)
        
        assert dut.pc_nxt.value==binary(int(eval),32), f"innocrrect at {i} iter"
        eval=pc4val if val==0 else jval