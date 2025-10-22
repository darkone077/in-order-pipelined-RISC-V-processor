import cocotb
from cocotb.triggers import Timer
from random import randint

VLEN=64

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
    eval1=[0]*VLEN
    await Timer(1,'ns')
    sr1=[0]*VLEN
    sr2=[0]*VLEN
    #addition
    aluctl=0
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,200000)
            eval1[j]=sr1[j]+sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'

    #subtraction    
    aluctl=1
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,200000)
            eval1[j]=sr1[j]-sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
    
    #and
    aluctl=2
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,200000)
            eval1[j]=sr1[j]&sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
    
    #or    
    aluctl=3
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,200000)
            eval1[j]=sr1[j]|sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
    
    #xor
    aluctl=4
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,200000)
            eval1[j]=sr1[j]^sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
    
    #shift left    
    aluctl=5
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,31)
            eval1[j]=sr1[j]<<sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
        
    #shift right
    aluctl=6
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,31)
            eval1[j]=sr1[j]>>sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
        
    #set less than
    aluctl=7
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,200000)
            eval1[j]=sr1[j]<sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
        
    #shfit right signed
    aluctl=8
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,31)
            eval1[j]=(sr1[j]>>sr2[j])&(2**(32-sr2[j])-1)
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
        
    #set less than unsigned
    aluctl=9
    for i in range(1000):
        for j in range(VLEN):
            sr1[j]=randint(0,200000)
            sr2[j]=randint(0,200000)
            eval1[j]=sr1[j]<sr2[j]
        
        dut.vecAluCtrl.value=aluctl    
        dut.src1.value=sr1
        dut.src2.value=sr2
        await Timer(1,units='ns')
        
        for j in range(VLEN):
            assert dut.aluout[j].value==binary(eval1[j],32),f'failed output on the {i} itr'
        
