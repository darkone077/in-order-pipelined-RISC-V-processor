from random import randint
import cocotb
from cocotb.triggers import RisingEdge,Timer
from cocotb.clock import Clock
from copy import deepcopy

@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clock.start(start_high=False))
    
    
    await RisingEdge(dut.clk)
    eval=[0]*18
    eclr=0
    dut.clr.value=0
    
    
    for i in range(1000):
        val=[randint(0,1),randint(0,1),randint(0,1),randint(0,1),randint(0,1),randint(0,3),randint(0,3),randint(0,7),randint(0,4294967295),randint(0,4294967295),randint(0,4294967295),randint(0,4294967295),randint(0,4294967295),randint(0,31),randint(0,31),randint(0,31),randint(0,3),randint(0,7)]
    
        dut.regWrtd.value=val[0]
        dut.memWrtd.value=val[1]
        dut.jmpd.value=val[2]
        dut.branchd.value=val[3]
        dut.aluSrcd.value=val[4]
        dut.resltSrcd.value=val[5]
        dut.immSrcd.value=val[6]
        dut.aluCtrld.value=val[7]
        dut.rd1d.value=val[8]
        dut.rd2d.value=val[9]
        dut.pcd.value=val[10]
        dut.pc4d.value=val[11]
        dut.immextd.value=val[12]
        dut.ad1d.value=val[13]
        dut.ad2d.value=val[14]
        dut.rdd.value=val[15]
        dut.ujMuxd.value=val[16]
        dut.funct3d.value=val[17]
        
        await RisingEdge(dut.clk)
        
        assert dut.regWrte.value==eval[0],f'error in {i} iter'
        assert dut.memWrte.value==eval[1],f'error in {i} iter'
        assert dut.jmpe.value==eval[2],f'error in {i} iter'
        assert dut.branche.value==eval[3],f'error in {i} iter'
        assert dut.aluSrce.value==eval[4],f'error in {i} iter'
        assert dut.resltSrce.value==eval[5],f'error in {i} iter'
        assert dut.immSrce.value==eval[6],f'error in {i} iter'
        assert dut.aluCtrle.value==eval[7],f'error in {i} iter'
        assert dut.rd1e.value==eval[8],f'error in {i} iter'
        assert dut.rd2e.value==eval[9],f'error in {i} iter'
        assert dut.pce.value==eval[10],f'error in {i} iter'
        assert dut.pc4e.value==eval[11],f'error in {i} iter'
        assert dut.immexte.value==eval[12],f'error in {i} iter'
        assert dut.ad1e.value==eval[13],f'error in {i} iter'
        assert dut.ad2e.value==eval[14],f'error in {i} iter'
        assert dut.rde.value==eval[15],f'error in {i} iter'
        assert dut.ujMuxe.value==eval[16],f'error in {i} iter'
        assert dut.funct3e.value==eval[17],f'error in {i} iter'
        eval=deepcopy(val)
        