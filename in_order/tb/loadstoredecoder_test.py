import cocotb
from cocotb.triggers import Timer
from random import randint


@cocotb.test()
async def test(dut):
    
    dut.funct3.value=0b000 #byte
    for _ in range(1000):
        addr=randint(0,0xFFFFFFFF)
        datin=randint(0,0xFFFFFFFF)
        
        dut.ad.value=addr
        dut.inDat.value=datin
        
        await Timer(1,'ns')
        match addr&0x00000003:
            case 0b00:
                assert int(dut.outDat.value)==(datin&0x000000FF)
                assert dut.strobe.value==0b0001
            case 0b01:
                assert int(dut.outDat.value)==(datin&0x000000FF)<<8
                assert dut.strobe.value==0b0010
            case 0b10:
                assert int(dut.outDat.value)==(datin&0x000000FF)<<16
                assert dut.strobe.value==0b0100
            case 0b11:
                assert int(dut.outDat.value)==(datin&0x000000FF)<<24
                assert dut.strobe.value==0b1000
                
    dut.funct3.value=0b001 #halfword
    for _ in range(1000):
        addr=randint(0,0xFFFFFFFF)
        datin=randint(0,0xFFFFFFFF)
        
        dut.ad.value=addr
        dut.inDat.value=datin
        
        await Timer(1,'ns')
        match addr&0x00000003:
            case 0b00:
                assert int(dut.outDat.value)==(datin&0x0000FFFF)
                assert dut.strobe.value==0b0011
            case 0b10:
                assert int(dut.outDat.value)==(datin&0x0000FFFF)<<16
                assert dut.strobe.value==0b1100
            case _:
                assert dut.strobe.value==0b0000
                
    
    dut.funct3.value=0b010 #word
    for _ in range(1000):
        addr=randint(0,0xFFFFFFFF)
        datin=randint(0,0xFFFFFFFF)
        
        dut.ad.value=addr
        dut.inDat.value=datin
        
        await Timer(1,'ns')
        match addr&0x00000003:
            case 0b00:
                assert int(dut.outDat.value)==datin
                assert dut.strobe.value==0b1111
            case _:
                assert dut.strobe.value==0b0000