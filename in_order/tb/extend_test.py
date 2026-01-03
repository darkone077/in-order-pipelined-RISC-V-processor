import cocotb
from cocotb.triggers import Timer
from random import randint
from numpy import binary_repr

@cocotb.test()
async def test(dut):
    eval=0
    
    await Timer(1,'ns')
    #itype
    imsrc=0
    for i in range(10000):
        val=randint(-8388608,8388607)
        dut.imm.value=val
        dut.immsrc.value=imsrc
        
        bval=binary_repr(val,25)
        eval=bval[0]*20+bval[0:12]
        await Timer(1,'ns')
        
        assert int(dut.immext.value)==int('0b'+eval,base=2),f"error in {i} iter with {eval}"
        
        
    #stype    
    imsrc=1
    for i in range(10000):
        val=randint(-8388608,8388607)
        dut.imm.value=val
        dut.immsrc.value=imsrc
        
        bval=binary_repr(val,25)
        eval=bval[0]*20+bval[0:7]+bval[20:25]
        await Timer(1,'ns')
        
        assert int(dut.immext.value)==int('0b'+eval,base=2),f"error in {i} iter with {eval}"
        
    #btype    
    imsrc=2
    for i in range(10000):
        val=randint(-8388608,8388607)
        dut.imm.value=val
        dut.immsrc.value=imsrc
        
        bval=binary_repr(val,25)
        eval=bval[0]*20+bval[24]+bval[1:7]+bval[20:24]+'0'
        await Timer(1,'ns')
        
        assert int(dut.immext.value)==int('0b'+eval,base=2),f"error in {i} iter with {eval}"
        
    #jtype    
    imsrc=3
    for i in range(10000):
        val=randint(-8388608,8388607)
        dut.imm.value=val
        dut.immsrc.value=imsrc
        
        bval=binary_repr(val,25)
        eval=bval[0]*12+bval[12:20]+bval[11]+bval[1:11]+'0'
        await Timer(1,'ns')
        
        assert int(dut.immext.value)==int('0b'+eval,base=2),f"error in {i} iter with {eval}"
        
    #utype    
    imsrc=4
    for i in range(10000):
        val=randint(-8388608,8388607)
        dut.imm.value=val
        dut.immsrc.value=imsrc
        
        bval=binary_repr(val,25)
        eval=bval[0:20]+'0'*12
        await Timer(1,'ns')
        
        assert int(dut.immext.value)==int('0b'+eval,base=2),f"error in {i} iter with {eval}"