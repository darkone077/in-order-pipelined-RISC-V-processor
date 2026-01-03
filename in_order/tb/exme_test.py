from random import randint
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

@cocotb.test()
async def test(dut):
    clock=Clock(dut.clk,10,'ns')
    cocotb.start_soon(clock.start(start_high=False))
    
    eval=[0]*9
    await RisingEdge(dut.clk)
    
    for i in range(10000):
        val=[randint(0,1),randint(0,1),randint(0,3),randint(0,4294967295),randint(0,4294967295),randint(0,4294967295),randint(0,4294967295),randint(0,1)]
        dut.regWrte.value=val[0]
        dut.memWrte.value=val[1]
        dut.rsltSrce.value=val[2]
        dut.aluRslte.value=val[3]
        dut.wrtDe.value=val[4]
        dut.pc4e.value=val[5]
        dut.rde.value=val[7]
        dut.ujWrtBcke.value=val[6]
        dut.reade.value=val[7]
        
        await RisingEdge(dut.clk)
        assert dut.regWrtm.value==eval[0],f'wrong in the {i} iter'
        assert dut.memWrtm.value==eval[1],f'wrong in the {i} iter'
        assert dut.rsltSrcm.value==eval[2],f'wrong in the {i} iter'
        assert dut.aluRsltm.value==eval[3],f'wrong in the {i} iter'
        assert dut.wrtDm.value==eval[4],f'wrong in the {i} iter'
        assert dut.pc4m.value==eval[5],f'wrong in the {i} iter'
        assert dut.rdm.value==eval[7],f'wrong in the {i} iter'
        assert dut.ujWrtBckm.value==eval[6],f'wrong in the {i} iter'
        assert dut.readm.value==eval[7],f'wrong in the {i} iter'
        
        eval=val.copy()