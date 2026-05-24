import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiBus,AxiMaster
from random import randint

def gendata(size):
    data=[0]*size
    with open("../tb/memory.mem", 'w') as file:
        for i in range(size):
            data[i]=randint(0x0, 0xffffffff)
            hex_val = hex(data[i])[2:]
            file.write(hex_val + '\n')
    return data

@cocotb.test()
async def test(dut):
    cocotb.start_soon(Clock(dut.clk,10,'ns').start(start_high=False))
    axi_m=AxiMaster(AxiBus.from_prefix(dut,'axi'),dut.clk,dut.rst_n,reset_active_level=False)
    dram=gendata(1000)
    dut.rst_n.value=0
    await RisingEdge(dut.clk)
    dut.rst_n.value=1
    
    #single write
    await axi_m.write(0x100,b'\x32\x87\x82\x29')
    assert int(dut.RAM.mem[0x100>>2].value)==int.from_bytes(b'\x32\x87\x82\x29','little')
    
    #single read
    data=await axi_m.read(0x0,4)
    assert int.from_bytes(data.data,'little')==dram[0]
    
    #multi-write
    data=[randint(0x0,0xff) for _ in range(64)]
    bdata=bytearray(data)
    await axi_m.write(0x100,bdata,awid=0x0)
    for i in range(16):
        assert int(dut.RAM.mem[(0x100>>2)+i].value)==int.from_bytes(bdata[i*4:i*4+4],'little')
     
    #multi-data   
    data=await axi_m.read(0,64,arid=0x0)
    for i in range(16):
        assert int.from_bytes(data.data[4*i:4*i+4],'little')==dram[i]