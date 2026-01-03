import cocotb
from random import randint
from cocotb.triggers import Timer

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
        dut.funct7.value=funct_7b5<<5
        await Timer(1,'ns')
        
        reg_wrt=0b1
        mem_wrt=0b0
        imm_src=0b000
        jump=0b0
        branch=0b0
        alu_src=0b1
        rslt_src=0b00
        match funct_3:
            case 0b000: #addi
                alu_ctrl=0b0000
            case 0b001: #slli
                alu_ctrl=0b0101
            case 0b010: #slti
                alu_ctrl=0b0111
            case 0b011: #sltiu
                alu_ctrl=0b1001
            case 0b100: #xori
                alu_ctrl=0b0100
            case 0b101: #srai and srli
                alu_ctrl=0b1000 if funct_7b5 else 0b0110
            case 0b110: #ori
                alu_ctrl=0b0011
            case 0b111: #andi
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
        funct_7b0=1 if funct_7b5==0 else 0
        dut.op.value=opc
        dut.funct3.value=funct_3
        dut.funct7.value=funct_7b5<<5|funct_7b0
        await Timer(1,'ns')
        
        reg_wrt=0b1
        mem_wrt=0b0
        jump=0b0
        branch=0b0
        alu_src=0b0
        rslt_src=0b00
        match funct_3:
            case 0b000: #mul, add, sub
                alu_ctrl=0b01010 if funct_7b0 else 0b0001 if funct_7b5 else 0b0000
            case 0b001: #mulh, sll
                alu_ctrl=0b01011 if funct_7b0 else 0b0101
            case 0b010: #mulhsu, slt
                alu_ctrl=0b01101 if funct_7b0 else 0b0111
            case 0b011: #mulu, sltu
                alu_ctrl=0b01100 if funct_7b0 else 0b1001
            case 0b100: #xor
                alu_ctrl=0b0100
            case 0b101: #sra, srl
                alu_ctrl=0b1000 if funct_7b5 else 0b0110
            case 0b110: #or
                alu_ctrl=0b0011
            case 0b111: #and
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
            case 0b00|0b01: #beq, bne
                alu_ctrl=0b0001
            case 0b100|0b101: #blt,bge
                alu_ctrl=0b0111
            case 0b110|0b111: #bltu,bgeu
                alu_ctrl=0b1001
            case 0b010|0b011:
                pass
        Timer(1,'ns')
        assert dut.regWrt.value==reg_wrt
        assert dut.memWrt.value==mem_wrt
        assert dut.immSrc.value==imm_src
        assert dut.jmp.value==jump
        assert dut.brnch.value==branch
        assert dut.aluSrc.value==alu_src
        if(not(funct_3==0b10 or funct_3==0b011)):
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