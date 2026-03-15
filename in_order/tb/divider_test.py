import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from random import randint

@cocotb.test()
async def test(dut):
    clk=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clk.start(start_high=False))
    dut.div_en.value=0b1
    dut.rst_n.value=0b1
    
    #div
    for i in range(1000):
        sr1=randint(-0x80000000,0x7fffffff)
        sr2=randint(-0x80000000,0x7fffffff)
        dut.src1.value=sr1
        dut.src2.value=sr2
        dut.divCtrl.value=0b00
        while(dut.busy.value!=1):
            await RisingEdge(dut.clk)
        while(dut.busy.value):
            await RisingEdge(dut.clk)
        ans=dut.divOut.value-(1<<32) if dut.divOut.value&0x80000000 else dut.divOut.value
        if(sr2!=0):
            assert ans==int(sr1/sr2),f'{dut.divOut.value}!={dut.src1.value}/s{dut.src2.value}'
    
    #divu     
    for i in range(1000):
        sr1=randint(0x0,0xffffffff)
        sr2=randint(0x1,0xffffffff)
        dut.src1.value=sr1
        dut.src2.value=sr2
        dut.divCtrl.value=0b01
        while(dut.busy.value!=1):
            await RisingEdge(dut.clk)
        while(dut.busy.value):
            await RisingEdge(dut.clk)
        ans=dut.divOut.value
        if(sr2!=0):
            assert ans==int(sr1/sr2),f'{dut.divOut.value}!={dut.src1.value}/u{dut.src2.value}'
     
    #rem       
    for i in range(1000):
        sr1=randint(-0x80000000,0x7fffffff)
        sr2=randint(-0x80000000,0x7fffffff)
        dut.src1.value=sr1
        dut.src2.value=sr2
        dut.divCtrl.value=0b10
        while(dut.busy.value!=1):
            await RisingEdge(dut.clk)
        while(dut.busy.value):
            await RisingEdge(dut.clk)
        ans=dut.divOut.value-(1<<32) if dut.divOut.value&0x80000000 else dut.divOut.value
        rem=(abs(sr1)%abs(sr2))*(-1 if sr1<0 else 1)
        if(sr2!=0):
            assert ans==int(rem),f'{hex(dut.divOut.value)}!={hex(dut.src1.value)}%s{hex(dut.src2.value)}'
    #remu    
    for i in range(1000):
        sr1=randint(0x0,0xffffffff)
        sr2=randint(0x1,0xffffffff)
        dut.src1.value=sr1
        dut.src2.value=sr2
        dut.divCtrl.value=0b11
        while(dut.busy.value!=1):
            await RisingEdge(dut.clk)
        while(dut.busy.value):
            await RisingEdge(dut.clk)
        ans=dut.divOut.value
        if(sr2!=0):
            assert ans==int(sr1%sr2),f'{dut.divOut.value}!={dut.src1.value}%u{dut.src2.value}'