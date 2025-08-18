import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from random import randint

@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clock.start(start_high=False))
    
    await RisingEdge(dut.clk)
    eval=[0]*8
    
    for i in range(10000):
        val=[randint(0,1),randint(0,1),randint(0,3),randint(0,4294967295),randint(0,4294967295),randint(0,31),randint(0,4294967295),randint(0,4294967295)]
        dut.regWrtm.value=val[0]
        dut.memWrtm.value=val[1]
        dut.rsltSrcm.value=val[2]
        dut.readDm.value=val[3]
        dut.pc4m.value=val[4]
        dut.rdm.value=val[5]
        dut.ujWrtBckm.value=val[6]
        dut.aluRsltm.value=val[7]
        
        await RisingEdge(dut.clk)
        
        assert dut.regWrtw.value==eval[0],f'error in {i} iter'
        assert dut.memWrtw.value==eval[1],f'error in {i} iter'
        assert dut.rsltSrcw.value==eval[2],f'error in {i} iter'
        assert dut.readDw.value==eval[3],f'error in {i} iter'
        assert dut.pc4w.value==eval[4],f'error in {i} iter'
        assert dut.rdw.value==eval[5],f'error in {i} iter'
        assert dut.ujWrtBckw.value==eval[6],f'error in {i} iter'
        assert dut.aluRsltw.value==eval[7],f'error in {i} iter'
        
        eval=val.copy()