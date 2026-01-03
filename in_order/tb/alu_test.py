import cocotb
from cocotb.triggers import Timer
from random import randint


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
        eval2=((sr1+sr2)==0)
        eval3=sr1+sr2
        await Timer(1,units='ns')
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
    
    #subtraction    
    aluctl=1
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1-sr2
        eval2=((sr1-sr2)==0)
        eval3=sr1-sr2
        await Timer(1,units='ns')
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
    
    #and
    aluctl=2
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1&sr2
        eval2=((sr1&sr2)==0)
        eval3=sr1&sr2
        await Timer(1,units='ns')
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
    
    #or    
    aluctl=3
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=sr1|sr2
        eval2=((sr1|sr2)==0)
        eval3=sr1|sr2
        await Timer(1,units='ns')
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'    
    
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
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
    
    #shift left    
    aluctl=5
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,31)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=(sr1<<sr2)&0xffffffff
        eval2=((sr1<<sr2)&0xffffffff==0)
        eval3=sr1<<sr2
        await Timer(1,units='ns')
        assert (dut.aluout.value.integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
        
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
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
        
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
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
        
    #shfit right signed
    aluctl=8
    for i in range(1000):
        sr1=randint(-200000,200000)
        sr2=randint(0,31)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=(sr1>>sr2)&(2**(32-sr2)-1)
        eval2=((sr1>>sr2)==0)
        eval3=sr1>>sr2
        await Timer(1,units='ns')
        assert (dut.aluout.value.integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
        
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
        assert (dut.aluout.value.signed_integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
        
    #mul
    aluctl=10
    for i in range(1000):
        sr1=randint(-200000,200000)
        sr2=randint(-200000,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=(sr1*sr2)&0xffffffff
        eval2=(((sr1*sr2)&0xffffffff)==0)
        eval3=(sr1*sr2)&0xffffffff
        await Timer(1,units='ns')
        assert (dut.aluout.value.integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
    
    #mulhu  
    aluctl=12
    for i in range(1000):
        sr1=randint(0,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=((sr1*sr2)>>32)&0xffffffff
        eval2=((((sr1*sr2)>>32)&0xffffffff)==0)
        eval3=((sr1*sr2)>>32)&0xffffffff
        await Timer(1,units='ns')
        assert (dut.aluout.value.integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'
        
    #mulhsu
    aluctl=13
    for i in range(1000):
        sr1=randint(-200000,200000)
        sr2=randint(0,200000)
        dut.aluctrl.value=aluctl
        dut.src1.value=sr1
        dut.src2.value=sr2
        
        eval1=((sr1*sr2)>>32)&0xffffffff
        eval2=((((sr1*sr2)>>32)&0xffffffff)==0)
        eval3=((sr1*sr2)>>32)&0xffffffff
        await Timer(1,units='ns')
        assert (dut.aluout.value.integer)==(eval1),f'failed output on the {i} itr'
        assert (dut.zero.value.integer)==eval2,f'failed 0 on the {i} itr'
        assert (dut.lstBit.value.integer)==(eval3)&0b1,f'failed lstbit on the {i} itr'

