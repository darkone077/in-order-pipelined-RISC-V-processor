import cocotb
from cocotb.triggers import RisingEdge,Timer
from cocotb.clock import Clock
from cocotbext.axi import AxiLiteBus,AxiLiteRam
from random import randint

@cocotb.test()
async def test(dut):
    clk=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clk.start(start_high=False))
    
    SIZE=4096
    ram=AxiLiteRam(AxiLiteBus.from_prefix(dut,'axi'),dut.clk,dut.rst_n,reset_active_level=False,size=SIZE)

    dut.rst_n.value=1
    
    #mem wrt test
    eval=randint(0,20000000)
    dut.memWrt.value=1
    dut.memAd.value=1<<2
    dut.wrtDat.value=eval
    await RisingEdge(dut.clk)
    await Timer(1,'ps')
    dut.memWrt.value=0
    assert dut.axi_awvalid.value==0b1
    assert dut.axi_wvalid.value==0b1
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1,'ps')
    
    assert dut.axi_bvalid.value==0b1
    
    await RisingEdge(dut.clk)
    
    #mem read test
    dut.readEN.value=1
    await RisingEdge(dut.clk)
    await Timer(1,'ps')
    
    assert dut.axi_rready.value==0b1
    assert dut.axi_arready.value==0b1
    assert dut.axi_arvalid.value==0b1
    

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1,'ps')
    assert int(dut.axi_rdata.value)==eval