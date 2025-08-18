import cocotb
from cocotb.triggers import RisingEdge,Timer
from cocotb.clock import Clock

@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clock.start(start_high=False))
    
    #lw 