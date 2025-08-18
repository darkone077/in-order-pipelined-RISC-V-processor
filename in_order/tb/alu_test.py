import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer,FallingEdge
from cocotb.binary import BinaryValue
from random import randint

def binary(num, bit):
    if num==0:
        return '0'*bit
    
    stri=""
    while(bit):
        t=num%2
        stri=str(t)+stri
        num=num//2
        bit-=1

        
    return stri

@cocotb.test()
async def test(dut):
    eval1=0
    eval2=0
    eval3=0
    await Timer(1,'ns')
    
    #addition
    aluctl=0
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1+sr2
        eval2=(sr1+sr2==0)
        eval3=sr1+sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
    
    #subtraction    
    aluctl=1
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1-sr2
        eval2=(sr1-sr2==0)
        eval3=sr1-sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
    
    #and
    aluctl=2
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1&sr2
        eval2=(sr1&sr2==0)
        eval3=sr1&sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
    
    #or    
    aluctl=3
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1|sr2
        eval2=(sr1|sr2==0)
        eval3=sr1|sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'    
    
    #xor
    aluctl=4
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1^sr2
        eval2=(sr1^sr2==0)
        eval3=sr1^sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
    
    #shift left    
    aluctl=5
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,31)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1<<sr2
        eval2=((sr1<<sr2)&4294967295==0)
        eval3=sr1<<sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
        
    #shift right
    aluctl=6
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,31)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1>>sr2
        eval2=(sr1>>sr2==0)
        eval3=sr1>>sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
        
    #set less than
    aluctl=7
    for i in range(1000):
        sr1=randint(-200000,200000)
        sr2=randint(-200000,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1<sr2
        eval2=((sr1<sr2)==0)
        eval3=sr1<sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
        
    #shfit right signed
    aluctl=8
    for i in range(1000):
        sr1=randint(-200000,200000)
        sr2=randint(0,31)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=(sr1>>sr2)&(2**(32-sr2)-1)
        eval2=(sr1>>sr2==0)
        eval3=sr1>>sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'
        
    #set less than unsigned
    aluctl=9
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1<sr2
        eval2=((sr1<sr2)==0)
        eval3=sr1<sr2
        await Timer(1,units='ns')
        assert dut.aluout.value==binary(eval1,32),f'failed output on the {i} itr'
        assert dut.zero.value==eval2,f'failed 0 on the {i} itr'
        assert dut.lstBit.value==binary(eval3,32)[31],f'failed lstbit on the {i} itr'