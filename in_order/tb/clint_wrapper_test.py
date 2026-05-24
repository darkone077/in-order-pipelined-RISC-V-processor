import cocotb
from cocotb.clock import Clock
from cocotbext.axi import AxiLiteMaster,AxiLiteBus

@cocotb.test()
async def test(dut):
    BASE=0x2000000
    MSIP=0x0
    MTIMECMPHIGH=0x4004
    MTIMECMPLOW=0x4000
    MTIMEHIGH=0xbffc
    MTIMELOW=0xbff8
    
    cocotb.start_soon(Clock(dut.clk,10,'ns').start(start_high=False))
    
    axi_m=AxiLiteMaster(AxiLiteBus.from_prefix(dut,'axi'),dut.clk,dut.rst_n,reset_active_level=False)
    
    dut.rst_n.value=1
    
    #soft int, msip write&read test
    await axi_m.write(BASE+MSIP,[0,0,0,1])
    assert dut.softIrq.value==1
    
    await axi_m.write(BASE+MSIP,[1,0,0,0])
    assert dut.softIrq.value==0
    data=await axi_m.read(BASE+MSIP,4)
    assert data.data==b'\x01\x00\x00\x00'
    
    
    #timer int, mtimecmp write&read test
    await axi_m.write(BASE+MTIMECMPLOW,[0x00,0x00,0x00,0x10])
    await axi_m.write(BASE+MTIMECMPHIGH,[0x00,0x00,0x00,0x00])
    assert dut.timerIrq==1
    
    await axi_m.write(BASE+MTIMECMPLOW,[0x10,0x00,0x00,0x00])
    await axi_m.write(BASE+MTIMECMPHIGH,[0x20,0x00,0x00,0x30])
    assert dut.timerIrq==0
    
    data=await axi_m.read(BASE+MTIMECMPLOW,4)
    assert data.data==b'\x10\x00\x00\x00'
    data=await axi_m.read(BASE+MTIMECMPHIGH,4)
    assert data.data==b'\x20\x00\x00\x30'
    
    #mtime read
    data=await axi_m.read(BASE+MTIMELOW,4)
    assert data.data==int.to_bytes(cocotb.simulator.get_sim_time()[1]//10000,4)
    data=await axi_m.read(BASE+MTIMEHIGH,4)
    assert data.data==int.to_bytes((cocotb.simulator.get_sim_time()[1]//10000)>>32,4)