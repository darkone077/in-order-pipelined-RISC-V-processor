import cocotb
from cocotb.clock import Clock
from cocotbext.axi import AxiLiteMaster,AxiLiteBus

@cocotb.test()
async def test(dut):

    
    cocotb.start_soon(Clock(dut.clk,10,'ns').start(start_high=False))
    
    axi_m=AxiLiteMaster(AxiLiteBus.from_prefix(dut,'axi'),dut.clk,dut.rst_n,reset_active_level=False)
    
    dut.rst_n.value=1
    #byte wrt and read
    await axi_m.write(0x20000,[0x11])
    await axi_m.write(0x20001,[0x22])
    await axi_m.write(0x20003,[0x33])
    data=await axi_m.read(0x20000,4)
    assert data.data==b'\x11\x22\x00\x33'
    
    #halfword wrt and read
    await axi_m.write(0x20000,[0x11,0x22])
    await axi_m.write(0x20002,[0x33,0x44])
    data=await axi_m.read(0x20000,4)
    assert data.data==b'\x11\x22\x33\x44'
    
    #word wrt and read
    await axi_m.write(0x20000,[0x11,0x23,0x45,0x65])
    data=await axi_m.read(0x20000,4)
    assert data.data==b'\x11\x23\x45\x65'