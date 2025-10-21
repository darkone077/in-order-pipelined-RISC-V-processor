from random import randint
import cocotb
from cocotb.triggers import FallingEdge,Timer,RisingEdge
from cocotb.clock import Clock
REGISTERS=32
VLEN=64
@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clock.start(start_high=True))
    
    val=[[0]*VLEN]*REGISTERS
    for i in range(1,REGISTERS):
        for j in range(1,VLEN):
            val[i][j]=randint(0,4294967295)
    
    #writing random mem to reg    
    dut.rst.value=0
    dut.wrten.value=1
    await RisingEdge(dut.clk)
    for i in range(1,REGISTERS):
        dut.addr3.value=i
        for j in range(1,VLEN):
            dut.v3dat[j].value=val[i][j]
        await RisingEdge(dut.clk)
    
    #testing values of random addresses    
    dut.wrten.value=0
    await RisingEdge(dut.clk)
    for i in range(10000):
        ad_1=randint(1,31)
        ad_2=randint(1,31)
        dut.addr1.value=ad_1
        dut.addr2.value=ad_2
        await Timer(1,'ns')
        for j in range(1,VLEN):
            assert int(dut.v1[j].value)==val[ad_1][j],f'error in {i} iter'
            assert int(dut.v2[j].value)==val[ad_2][j],f'error in {i} iter'