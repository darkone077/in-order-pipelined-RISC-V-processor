import cocotb
from cocotb.triggers import RisingEdge,ClockCycles,Timer
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbext.axi import AxiBus,AxiRam,AxiLiteBus,AxiLiteMaster
from random import randint

data_lru_unpacked=[0b11100100]*64
inst_lru_unpacked=[0b11100100]*16

async def reset(dut):
    dut.rst_n.value=0
    await RisingEdge(dut.clk)
    dut.rst_n.value=1
    global data_lru_unpacked,inst_lru_unpacked
    data_lru_unpacked=[0b11100100]*64
    inst_lru_unpacked=[0b11100100]*16
    
def data_gen(size,ram,loc):
    data=[randint(0x0,0xffffffff) for _ in range(size)]
    ram.write_words(loc,data,'little',4)
    return data

async def inst_test(dut,pc,data):
    global inst_lru_unpacked
    dut.pc.value=pc
    flag=0
    await ClockCycles(dut.clk,2)
    while(dut.CACHE.cache_state.value!=0b00):
        await RisingEdge(dut.clk)
        flag=1
    assert int(dut.inst.value)==data[(pc&0x3f)>>2]
    if(flag):
        assert int(dut.CACHE.inst_lru_track[(pc&0x3c0)>>6].value)==((int((inst_lru_unpacked[(pc&0x3c0)>>6]&0x03)<((inst_lru_unpacked[(pc&0x3c0)>>6]&0xc0)>>6))<<4)+((inst_lru_unpacked[(pc&0x3c0)>>6]&0x3c)>>2))
        inst_lru_unpacked[(pc&0x3c0)>>6]=((inst_lru_unpacked[(pc&0x3c0)>>6]>>2)+(inst_lru_unpacked[(pc&0x3c0)>>6]<<6))&0xff
    else:
        for i in range(4):
            if(dut.CACHE.inst_tag[(pc&0x3c0)>>6][i].value==(pc&0xfffffc00)>>10):
                print(i)
                if((inst_lru_unpacked[(pc&0x3c0)>>6]&0x03)==i):
                    assert int(dut.CACHE.inst_lru_track[(pc&0x3c0)>>6].value)==((int((inst_lru_unpacked[(pc&0x3c0)>>6]&0x03)<((inst_lru_unpacked[(pc&0x3c0)>>6]&0xc0)>>6))<<4)+((inst_lru_unpacked[(pc&0x3c0)>>6]&0x3c)>>2))
                    inst_lru_unpacked[(pc&0x3c0)>>6]=((inst_lru_unpacked[(pc&0x3c0)>>6]>>2)+(inst_lru_unpacked[(pc&0x3c0)>>6]<<6))&0xff
                elif(((inst_lru_unpacked[(pc&0x3c0)>>6]&0x0c)>>2)==i):
                    assert int(dut.CACHE.inst_lru_track[(pc&0x3c0)>>6].value)==((int(((inst_lru_unpacked[(pc&0x3c0)>>6]&0x0c)>>2)<((inst_lru_unpacked[(pc&0x3c0)>>6]&0xc0)>>6))<<4)+((inst_lru_unpacked[(pc&0x3c0)>>6]&0x30)>>2)+(inst_lru_unpacked[(pc&0x3c0)>>6]&0x03))
                    inst_lru_unpacked[(pc&0x3c0)>>6]=(((inst_lru_unpacked[(pc&0x3c0)>>6]&0xf0)>>2)+((inst_lru_unpacked[(pc&0x3c0)>>6]&0x0c)<<4)+(inst_lru_unpacked[(pc&0x3c0)>>6]&0x03))&0xff
                elif(((inst_lru_unpacked[(pc&0x3c0)>>6]&0x30)>>4)==i):
                    assert int(dut.CACHE.inst_lru_track[(pc&0x3c0)>>6].value)==((int(((inst_lru_unpacked[(pc&0x3c0)>>6]&0x30)>>4)<((inst_lru_unpacked[(pc&0x3c0)>>6]&0xc0)>>6))<<4)+(inst_lru_unpacked[(pc&0x3c0)>>6]&0x0f))
                    inst_lru_unpacked[(pc&0x3c0)>>6]=(((inst_lru_unpacked[(pc&0x3c0)>>6]&0xc0)>>2)+((inst_lru_unpacked[(pc&0x3c0)>>6]&0x30)<<2)+(inst_lru_unpacked[(pc&0x3c0)>>6]&0x0f))&0xff
                break
    
async def write_read_data_test(dut,loc,val,axil_m):
    global data_lru_unpacked
    stime=get_sim_time('ns')
    await axil_m.write(loc,val)
    etime=get_sim_time('ns')
    data=await axil_m.read(loc,4)
    assert int.from_bytes(data.data)==int.from_bytes(val)
    if (etime-stime)>150:
        assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int((data_lru_unpacked[(loc&0xfc0)>>6]&0x03)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x3c)>>2))
        data_lru_unpacked[(loc&0xfc0)>>6]=((data_lru_unpacked[(loc&0xfc0)>>6]>>2)+(data_lru_unpacked[(loc&0xfc0)>>6]<<6))&0xff
    else:
        for i in range(4):
            if(dut.CACHE.data_tag[(loc&0xfc0)>>6][i].value==(loc&0xfffff000)>>12):
                print(i)
                if((data_lru_unpacked[(loc&0xfc0)>>6]&0x03)==i):
                    assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int((data_lru_unpacked[(loc&0xfc0)>>6]&0x03)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x3c)>>2))
                    data_lru_unpacked[(loc&0xfc0)>>6]=((data_lru_unpacked[(loc&0xfc0)>>6]>>2)+(data_lru_unpacked[(loc&0xfc0)>>6]<<6))&0xff
                elif(((data_lru_unpacked[(loc&0xfc0)>>6]&0x0c)>>2)==i):
                    assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int(((data_lru_unpacked[(loc&0xfc0)>>6]&0x0c)>>2)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)>>2)+(data_lru_unpacked[(loc&0xfc0)>>6]&0x03))
                    data_lru_unpacked[(loc&0xfc0)>>6]=(((data_lru_unpacked[(loc&0xfc0)>>6]&0xf0)>>2)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x0c)<<4)+(data_lru_unpacked[(loc&0xfc0)>>6]&0x03))
                elif(((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)>>4)==i):
                    assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int(((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)>>4)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+(data_lru_unpacked[(loc&0xfc0)>>6]&0x0f))
                    data_lru_unpacked[(loc&0xfc0)>>6]=(((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>2)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)<<2)+(data_lru_unpacked[(loc&0xfc0)>>6]&0x0f))
                break
        
async def read_data_test(dut,loc,val,axil_m):
    global data_lru_unpacked
    stime=get_sim_time('ns')
    data=await axil_m.read(loc,4)
    etime=get_sim_time('ns')
    
    assert int.from_bytes(data.data,'little')==int(val[(loc&0x3f)>>2])
    
    if (etime-stime)>150:
        assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int((data_lru_unpacked[(loc&0xfc0)>>6]&0x03)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x3c)>>2))
        data_lru_unpacked[(loc&0xfc0)>>6]=((data_lru_unpacked[(loc&0xfc0)>>6]>>2)+(data_lru_unpacked[(loc&0xfc0)>>6]<<6))&0xff
    else:
        await RisingEdge(dut.clk)
        for i in range(4):
            if(dut.CACHE.data_tag[(loc&0xfc0)>>6][i].value==(loc&0xfffff000)>>12):
                print(i)
                if((data_lru_unpacked[(loc&0xfc0)>>6]&0x03)==i):
                    assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int((data_lru_unpacked[(loc&0xfc0)>>6]&0x03)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x3c)>>2))
                    data_lru_unpacked[(loc&0xfc0)>>6]=((data_lru_unpacked[(loc&0xfc0)>>6]>>2)+(data_lru_unpacked[(loc&0xfc0)>>6]<<6))&0xff
                elif(((data_lru_unpacked[(loc&0xfc0)>>6]&0x0c)>>2)==i):
                    assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int(((data_lru_unpacked[(loc&0xfc0)>>6]&0x0c)>>2)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)>>2)+(data_lru_unpacked[(loc&0xfc0)>>6]&0x03))
                    data_lru_unpacked[(loc&0xfc0)>>6]=(((data_lru_unpacked[(loc&0xfc0)>>6]&0xf0)>>2)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x0c)<<4)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x03)))
                elif(((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)>>4)==i):
                    assert int(dut.CACHE.data_lru_track[(loc&0xfc0)>>6].value)==((int(((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)>>4)<((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>6))<<4)+(data_lru_unpacked[(loc&0xfc0)>>6]&0x0f))
                    data_lru_unpacked[(loc&0xfc0)>>6]=(((data_lru_unpacked[(loc&0xfc0)>>6]&0xc0)>>2)+((data_lru_unpacked[(loc&0xfc0)>>6]&0x30)<<2)+(data_lru_unpacked[(loc&0xfc0)>>6]&0x0f))
                break
            
@cocotb.test()
async def test(dut):
    cocotb.start_soon(Clock(dut.clk,10,'ns').start(start_high=False))
    
    await reset(dut)
    SIZE=2**25
    axi_ram=AxiRam(AxiBus.from_prefix(dut,'axi'),dut.clk,dut.rst_n,reset_active_level=False,size=SIZE)
    axil_m=AxiLiteMaster(AxiLiteBus.from_prefix(dut,'axil'),dut.clk,dut.rst_n,reset_active_level=False)
    
    #inst read test
    data=data_gen(16,axi_ram,0x000000)    
    await inst_test(dut,0x000000,data)
    data1=data_gen(16,axi_ram,0x100000)
    await inst_test(dut,0x100000,data1)
    data2=data_gen(16,axi_ram,0x200000)
    await inst_test(dut,0x200000,data2)
    data3=data_gen(16,axi_ram,0x300000)
    await inst_test(dut,0x300000,data3)
    #inst read for cached inst+tracker test
    await inst_test(dut,0x300010,data3)
    await inst_test(dut,0x200010,data2)
    
    #write->read+cache write back test
    await write_read_data_test(dut,0x000100,b'\x45\x64\x32\x81',axil_m)
    await write_read_data_test(dut,0x100100,b'\x55\x66\x77\x88',axil_m)
    await write_read_data_test(dut,0x200100,b'\x44\x97\x11\x21',axil_m)
    await write_read_data_test(dut,0x300100,b'\x4f\x99\x34\x51',axil_m)
    await write_read_data_test(dut,0x400100,b'\x4f\x99\x34\x51',axil_m)
    #write->read test for cached data+tracker test
    await write_read_data_test(dut,0x300104,b'\x44\x59\x24\x21',axil_m)
    await write_read_data_test(dut,0x200104,b'\x35\x52\x23\x42',axil_m)
    
    #read data+cache write back/cache read test
    val1=data_gen(16,axi_ram,0x500200)
    val2=data_gen(16,axi_ram,0x600200)
    val3=data_gen(16,axi_ram,0x700200)
    val4=data_gen(16,axi_ram,0x800200)
    val5=data_gen(16,axi_ram,0x900200)
    await read_data_test(dut,0x500200,val1,axil_m)
    await read_data_test(dut,0x600204,val2,axil_m)
    await read_data_test(dut,0x700208,val3,axil_m)
    await read_data_test(dut,0x500204,val1,axil_m)
    await read_data_test(dut,0x80020c,val4,axil_m)
    await read_data_test(dut,0x900200,val5,axil_m)
    
    #inst+data test
    dat=data_gen(16,axi_ram,0x300500)
    dut.pc.value=0x300500
    axil_m.init_write(0x300600,b'\x45\x78\x89\x23')
    await ClockCycles(dut.clk,40)
    data=await axil_m.read(0x300600,4)
    assert int.from_bytes(data.data)==int.from_bytes(b'\x45\x78\x89\x23')
    assert int(dut.inst.value)==dat[0]