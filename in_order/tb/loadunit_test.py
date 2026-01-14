import cocotb
from cocotb.triggers import Timer
from random import randint

@cocotb.test()
async def test(dut):
    #byte
    stblistb=[0b0000,0b0001,0b0010,0b0100,0b1000]
    
    dut.funct3.value=0b000 #lb
    for _ in range(1000):
        datin=randint(0,0xFFFFFFFF)
        dut.inDat.value=datin
        index=randint(0,4)
        dut.strobe.value=stblistb[index]
        await Timer(1,'ns')
        
        match index:
            case 0:
                assert int(dut.outDat.value)==0
            case 1:
                assert int(dut.outDat.value)==(datin&0x000000FF)|(0xFFFFFF00 if (datin>>7)&1 else 0)
            case 2:
                assert int(dut.outDat.value)==((datin&0x0000FF00)>>8)|(0xFFFFFF00 if (datin>>15)&1 else 0)
            case 3:
                assert int(dut.outDat.value)==((datin&0x00FF0000)>>16)|(0xFFFFFF00 if (datin>>23)&1 else 0)
            case 4:
                assert int(dut.outDat.value)==((datin&0xFF000000)>>24)|(0xFFFFFF00 if (datin>>31)&1 else 0)
    
    
    dut.funct3.value=0b100 #lbu
    for _ in range(1000):
        datin=randint(0,0xFFFFFFFF)
        dut.inDat.value=datin
        index=randint(0,4)
        dut.strobe.value=stblistb[index]
        await Timer(1,'ns')
        
        match index:
            case 0:
                assert int(dut.outDat.value)==0
            case 1:
                assert int(dut.outDat.value)==(datin&0x000000FF)
            case 2:
                assert int(dut.outDat.value)==(datin&0x0000FF00)>>8
            case 3:
                assert int(dut.outDat.value)==(datin&0x00FF0000)>>16
            case 4:
                assert int(dut.outDat.value)==(datin&0xFF000000)>>24
     
          
    #halfword    
    stblisth=[0b0000,0b0011,0b1100]   
    
    dut.funct3.value=0b001
    for _ in range(1000): #lh
        datin=randint(0,0xFFFFFFFF)
        dut.inDat.value=datin
        index=randint(0,2)
        dut.strobe.value=stblisth[index]
        await Timer(1,'ns')
        
        match index:
            case 0:
                assert int(dut.outDat.value)==0
            case 1:
                assert int(dut.outDat.value)==(datin&0x0000FFFF)|(0xFFFF0000 if (datin>>15)&1 else 0)
            case 2:
                assert int(dut.outDat.value)==((datin&0xFFFF0000)>>16)|(0xFFFF0000 if (datin>>31)&1 else 0)
    
       
    dut.funct3.value=0b101 #lhu
    for _ in range(1000):
        datin=randint(0,0xFFFFFFFF)
        dut.inDat.value=datin
        index=randint(0,2)
        dut.strobe.value=stblisth[index]
        await Timer(1,'ns')
        
        match index:
            case 0:
                assert int(dut.outDat.value)==0
            case 1:
                assert int(dut.outDat.value)==(datin&0x0000FFFF)
            case 2:
                assert int(dut.outDat.value)==(datin&0xFFFF0000)>>16
                
    stblistw=[0b0000,0b1111]      
    dut.funct3.value=0b010 #lw
    for _ in range(1000):
        datin=randint(0,0xFFFFFFFF)
        dut.inDat.value=datin
        index=randint(0,1)
        dut.strobe.value=stblistw[index]
        await Timer(1,'ns')
        
        match index:
            case 0:
                assert int(dut.outDat.value)==0
            case 1:
                assert int(dut.outDat.value)==datin
                