from random import randint
import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test(dut):
    
    await Timer(1,'ns')
    
    #forwarding alu rslt from mem stage
    for i in range(10000):
        rd_m=randint(1,31)
        rs1_e=rd_m
        rs2_e=rd_m
        regWrt_m=1
        
        dut.rdm.value=rd_m
        dut.rs1e.value=rs1_e
        dut.rs2e.value=rs2_e
        dut.regWrtm.value=regWrt_m
        
        await Timer(1,'ns')
        assert dut.fwdAe.value==0b10,f'wrong fwdA in {i} iter'
        assert dut.fwdBe.value==0b10,f'wrong fwdB in {i} iter'
    
    #forwarding alu rslt from wrt stage    
    for i in range(10000):
        rd_m=0
        rd_w=randint(1,31)
        rs1_e=rd_w
        rs2_e=rd_w
        regWrt_w=1
        
        dut.rdm.value=rd_m
        dut.rdw.value=rd_w
        dut.rs1e.value=rs1_e
        dut.rs2e.value=rs2_e
        dut.regWrtw.value=regWrt_w
        
        await Timer(1,'ns')
        assert dut.fwdAe.value==0b01,f'wrong fwdA in {i} iter'
        assert dut.fwdBe.value==0b01,f'wrong fwdB in {i} iter'
        
    #no forwarding
    for i in range(10000):
        rd_m=0
        rd_w=randint(1,31)
        rs1_e=rd_w-1
        rs2_e=rd_w-1
        
        dut.rdm.value=rd_m
        dut.rdw.value=rd_w
        dut.rs1e.value=rs1_e
        dut.rs2e.value=rs2_e
        
        await Timer(1,'ns')
        assert dut.fwdAe.value==0b00,f'wrong fwdA in {i} iter'
        assert dut.fwdBe.value==0b00,f'wrong fwdB in {i} iter'
        
    #stall test
    for i in range(10000):
        rd_e=randint(1,31)
        neq1=randint(0,1)
        neq2=randint(0,1)
        rs1_d=rd_e-neq1
        rs2_d=rd_e-neq2
        rslt_src=randint(0,1)
        stallw=rslt_src and not (neq1 and neq2)
        
        dut.rde.value=rd_e
        dut.rs1d.value=rs1_d
        dut.rs2d.value=rs2_d
        dut.rsltSrce.value=rslt_src
        
        await Timer(1,'ns')
        assert dut.stalld.value==stallw,f'wrong stalld in {i} iter'
        assert dut.stallf.value==stallw,f'wrong stallf in {i} iter'
        
    for i in range(10000):
        rd_e=randint(1,31)
        neq1=randint(0,1)
        neq2=randint(0,1)
        rs1_d=rd_e-neq1
        rs2_d=rd_e-neq2
        rslt_src=randint(0,1)
        stallw=rslt_src and not (neq1 and neq2)
        pc_src=randint(0,1)
        
        dut.rde.value=rd_e
        dut.rs1d.value=rs1_d
        dut.rs2d.value=rs2_d
        dut.rsltSrce.value=rslt_src
        dut.pcSrce.value=pc_src
        
        await Timer(1,'ns')
        assert dut.flushd.value==pc_src,f'wrong flushd in {i} iter'
        assert dut.flushe.value==stallw|pc_src,f'wrong flushe in {i} iter'