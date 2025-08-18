import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test(dut):
    f=open('/home/kaush/cpu2/in_order/tb/instmem.mem','r')
    val=['']*3
    for i in range(3):
        val[i]=f.readline()
    await Timer(1,'ns')    
    
    for i in range(3):
        dut.mem_ad.value=i<<2
        await Timer(1,'ns')
        assert int(dut.redDat.value)==int(val[i],base=16)
        
        