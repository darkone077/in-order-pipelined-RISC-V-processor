import cocotb
from random import randint
from cocotb.triggers import Timer
from numpy import binary_repr

@cocotb.test()
async def test(dut):
    
    #iloadtype
    opc=0b0000011
    dut.op.value=opc
    await Timer(1,'ns')
    
    reg_wrt=0b1
    mem_wrt=0b0
    imm_src=0b000
    jump=0b0
    branch=0b0
    alu_src=0b1
    rslt_src=0b01
    alu_ctrl=0b0000
    
    Timer(1,'ns')
    assert dut.regWrt.value==reg_wrt
    assert dut.memWrt.value==mem_wrt
    assert dut.immSrc.value==imm_src
    assert dut.jmp.value==jump
    assert dut.brnch.value==branch
    assert dut.aluSrc.value==alu_src
    assert dut.rsltSrc.value==rslt_src
    assert dut.aluCtrl.value==alu_ctrl
    
    #ialutype
    opc=0b0010011
    for i in range(1000):
        funct_3=randint(0,7)
        funct_7b5=randint(0,1)
        dut.op.value=opc
        dut.funct3.value=funct_3
        dut.funct7b5.value=funct_7b5
        await Timer(1,'ns')
        
        reg_wrt=0b1
        mem_wrt=0b0
        imm_src=0b000
        jump=0b0
        branch=0b0
        alu_src=0b1
        rslt_src=0b00
        match funct_3:
            case 0:
                alu_ctrl=0b0000
            case 1:
                alu_ctrl=0b0101
            case 2:
                alu_ctrl=0b0111
            case 3:
                alu_ctrl=0b1001
            case 4:
                alu_ctrl=0b0100
            case 5:
                alu_ctrl=0b1000 if funct_7b5 else 0b0110
            case 6:
                alu_ctrl=0b0011
            case 7:
                alu_ctrl=0b0010
        
        Timer(1,'ns')
        assert dut.regWrt.value==reg_wrt
        assert dut.memWrt.value==mem_wrt
        assert dut.immSrc.value==imm_src
        assert dut.jmp.value==jump
        assert dut.brnch.value==branch
        assert dut.aluSrc.value==alu_src
        assert dut.rsltSrc.value==rslt_src
        assert dut.aluCtrl.value==alu_ctrl
        
    #rtype
    opc=0b0110011
    for i in range(1000):
        funct_3=randint(0,7)
        funct_7b5=randint(0,1)
        dut.op.value=opc
        dut.funct3.value=funct_3
        dut.funct7b5.value=funct_7b5
        await Timer(1,'ns')
        
        reg_wrt=0b1
        mem_wrt=0b0
        jump=0b0
        branch=0b0
        alu_src=0b0
        rslt_src=0b00
        match funct_3:
            case 0:
                alu_ctrl=0b0001 if funct_7b5 else 0b0000
            case 1:
                alu_ctrl=0b0101
            case 2:
                alu_ctrl=0b0111
            case 3:
                alu_ctrl=0b1001
            case 4:
                alu_ctrl=0b0100
            case 5:
                alu_ctrl=0b1000 if funct_7b5 else 0b0110
            case 6:
                alu_ctrl=0b0011
            case 7:
                alu_ctrl=0b0010
        
        Timer(1,'ns')
        assert dut.regWrt.value==reg_wrt
        assert dut.memWrt.value==mem_wrt
        assert dut.jmp.value==jump
        assert dut.brnch.value==branch
        assert dut.aluSrc.value==alu_src
        assert dut.rsltSrc.value==rslt_src
        assert dut.aluCtrl.value==alu_ctrl
        
    #stype
    opc=0b0100011
    dut.op.value=opc
    await Timer(1,'ns')
    
    reg_wrt=0b0
    mem_wrt=0b1
    imm_src=0b001
    jump=0b0
    branch=0b0
    alu_src=0b1
    alu_ctrl=0b0000
    
    Timer(1,'ns')
    assert dut.regWrt.value==reg_wrt
    assert dut.memWrt.value==mem_wrt
    assert dut.immSrc.value==imm_src
    assert dut.jmp.value==jump
    assert dut.brnch.value==branch
    assert dut.aluSrc.value==alu_src
    assert dut.aluCtrl.value==alu_ctrl
    
    #btype
    opc=0b1100011
    for i in range(1000):
        funct_3=randint(0,7)
        dut.op.value=opc
        dut.funct3.value=funct_3
        await Timer(1,'ns')
        
        reg_wrt=0b0
        mem_wrt=0b0
        imm_src=0b010
        jump=0b0
        branch=0b1
        alu_src=0b0
        match funct_3:
            case 0|1:
                alu_ctrl=0b0001
            case 4|5:
                alu_ctrl=0b0111
            case 6|7:
                alu_ctrl=0b1001
            case 2|3:
                pass
        Timer(1,'ns')
        assert dut.regWrt.value==reg_wrt
        assert dut.memWrt.value==mem_wrt
        assert dut.immSrc.value==imm_src
        assert dut.jmp.value==jump
        assert dut.brnch.value==branch
        assert dut.aluSrc.value==alu_src
        if(not(funct_3==2 or funct_3==3)):
            assert dut.aluCtrl.value==alu_ctrl,f'error in {i} iter with funct3={funct_3}'
            
    #jtypejalr
    opc=0b1100111
    dut.op.value=opc
    await Timer(1,'ns')
    
    reg_wrt=0b1
    mem_wrt=0b0
    imm_src=0b000
    jump=0b1
    branch=0b0
    rslt_src=0b10
    uj_mux=0b10
    
    Timer(1,'ns')
    assert dut.regWrt.value==reg_wrt
    assert dut.memWrt.value==mem_wrt
    assert dut.immSrc.value==imm_src
    assert dut.jmp.value==jump
    assert dut.brnch.value==branch
    assert dut.rsltSrc.value==rslt_src
    assert dut.ujMux.value==uj_mux
    
    #jtype
    opc=0b1101111
    dut.op.value=opc
    await Timer(1,'ns')
    
    reg_wrt=0b1
    mem_wrt=0b0
    imm_src=0b011
    jump=0b1
    branch=0b0
    rslt_src=0b10
    uj_mux=0b01
    
    Timer(1,'ns')
    assert dut.regWrt.value==reg_wrt
    assert dut.memWrt.value==mem_wrt
    assert dut.immSrc.value==imm_src
    assert dut.jmp.value==jump
    assert dut.brnch.value==branch
    assert dut.rsltSrc.value==rslt_src
    assert dut.ujMux.value==uj_mux
    
    #utypelui
    opc=0b0110111
    dut.op.value=opc
    await Timer(1,'ns')
    
    reg_wrt=0b1
    mem_wrt=0b0
    imm_src=0b100
    jump=0b0
    branch=0b0
    rslt_src=0b11
    uj_mux=0b00
    
    Timer(1,'ns')
    assert dut.regWrt.value==reg_wrt
    assert dut.memWrt.value==mem_wrt
    assert dut.immSrc.value==imm_src
    assert dut.jmp.value==jump
    assert dut.brnch.value==branch
    assert dut.rsltSrc.value==rslt_src
    assert dut.ujMux.value==uj_mux
    
    #utypeauipc
    opc=0b0010111
    dut.op.value=opc
    await Timer(1,'ns')
    
    reg_wrt=0b1
    mem_wrt=0b0
    imm_src=0b100
    jump=0b0
    branch=0b0
    rslt_src=0b11
    uj_mux=0b01
    
    Timer(1,'ns')
    assert dut.regWrt.value==reg_wrt
    assert dut.memWrt.value==mem_wrt
    assert dut.immSrc.value==imm_src
    assert dut.jmp.value==jump
    assert dut.brnch.value==branch
    assert dut.rsltSrc.value==rslt_src
    assert dut.ujMux.value==uj_mux