`timescale 1ns/1ps
`include "../src/alu.sv"
`include "../src/ctrl.sv"
`include "../src/deex.sv"
`include "../src/extend.sv"
`include "../src/fede.sv"
`include "../src/hazardunit.sv"
`include "../src/instmem.sv"
`include "../src/mewb.sv"
`include "../src/pc.sv"
`include "../src/regfile.sv"
`include "../src/exme.sv"
`include "../src/loadstoredecoder.sv"
`include "../src/loadunit.sv"
`include "../src/divider.sv"
`include "../src/csr.sv"

module top_no_axi (
    input logic clk,
    input logic rst,
    input logic timerIrq,swIrq,
    output logic axi_error,
    output logic [31:0] pcf, pcj,
    input logic [31:0] instf,
    input logic cacheBusy,axiBusy,
    output logic read,wrt,
    output logic [31:0] wrt_data,
    output logic [31:0] mem_ad,
    output logic [3:0] wrt_strb,
    input logic [31:0] read_data
);
    
    logic [31:0] pcd;
    logic [31:0] pc4f;
    logic [31:0] pc4d;
    logic [31:0] instd;
    logic trap;
    logic [31:0] exception_pc;
    logic pcSrc;
    
    assign pcj=ujWrtBcke;
    assign pc4f=pcf+4;
    pc PC(clk,pcSrc,trap,stallf,rst,exception_pc,pc4f,pcj,pcf);
    //instmem IM(pcf,instf);
    fede FD(clk,flushd|rst,stalld,instf,pc4f,pcf,instd,pc4d,pcd);

    logic [2:0] funct3e,funct3d;
    assign funct3d=instd[14:12];
    logic regWrtd,memWrtd,jmpd,brnchd,aluSrcd,readd,div_end;
    logic [1:0] ujMuxd,divCtrld;
    logic [2:0] rsltSrcd,immSrcd;
    logic [4:0] aluCtrld;
    logic [1:0]csr_srcd;
    logic csr_wrt_end,csr_immd;

    logic regWrte,memWrte,jmpe,brnche,aluSrce,reade,div_ene;
    logic [1:0] ujMuxe,divCtrle;
    logic [2:0] rsltSrce,immSrce;
    logic [4:0] aluCtrle;
    logic [1:0]csr_srce;
    logic csr_wrt_ene,csr_imme;
    logic ecall,ebreak,mret,illegal_inst;

    ctrl Control(instd,pcSrc,regWrtd,memWrtd,jmpd,brnchd,aluSrcd,readd,div_end,csr_wrt_end,csr_immd,ebreak,ecall,mret,illegal_inst,ujMuxd,csr_srcd,immSrcd,rsltSrcd,divCtrld,aluCtrld);
    
    logic [4:0] ad1d,ad2d,rdd;
    assign ad1d=instd[19:15];
    assign ad2d=instd[24:20];
    assign rdd=instd[11:7];
    logic [4:0] ad1e,ad2e,rde;
    logic [31:0] rd1d,rd2d;
    logic [31:0] rd1e,rd2e,pce;
    logic [31:0] pc4e;
    logic [31:0] rsltw;

    regfile RF(clk,~rst,ad1d,ad2d,rdw,rsltw,regWrtw,rd1d,rd2d);

    logic [24:0] imm;
    assign imm=instd[31:7];
    logic [31:0] immextd,immexte;
    
    extend EXTEND(immSrcd,imm,immextd);

    //logic [31:0] csrd,csre;
    logic [31:0] rd1_csr_immd;
    logic [4:0] ad1_csrd;
    logic [11:0] csr_addrd,csr_addre;
    assign csr_addrd = instd[31:20];

    always_comb begin
        rd1_csr_immd=csr_immd?{27'b0,instd[19:15]}:rd1d;
        ad1_csrd=csr_immd?5'b0:ad1d; 
    end
    deex DE(clk,flushe,stalle,regWrtd,memWrtd,jmpd,brnchd,aluSrcd,readd,div_end,csr_wrt_end,csr_immd,rsltSrcd,immSrcd,ujMuxd,aluCtrld,funct3d,divCtrld,csr_srcd,regWrte,memWrte,jmpe,brnche,aluSrce,reade,div_ene,csr_wrt_ene,csr_imme,rsltSrce,immSrce,ujMuxe,aluCtrle,funct3e,divCtrle,csr_srce,rd1_csr_immd,rd2d,pcd,pc4d,immextd,ad1_csrd,ad2d,rdd,csr_addrd,rd1e,rd2e,pce,pc4e,immexte,ad1e,ad2e,rde,csr_addre);

    logic [31:0] srcAe,srcBe,wrtDe,srcAe_buffer,wrtDe_buffer,srcAe_pre,wrtDe_pre;
    logic [1:0] fwdAe,fwdBe;
    logic busy_buffer;

    always_ff @(posedge clk) begin
        if (rst) begin
            srcAe_buffer<=32'b0;
            wrtDe_buffer<=32'b0;
            busy_buffer<=1'b0;
        end
        else begin
            busy_buffer<=cacheBusy|axiBusy;
            if (~(busy_buffer)) begin
                srcAe_buffer<=srcAe_pre;
            end
            if (~(busy_buffer)) begin
                wrtDe_buffer<=wrtDe_pre;
            end
        end
    end
    always_comb begin
        case(fwdAe)
            2'b00:
                srcAe_pre=rd1e;
            2'b01:
                srcAe_pre=rsltw;
            2'b10:
                srcAe_pre=aluRsltm;
            2'b11:
                srcAe_pre=ujWrtBckm;
        endcase

        srcAe=busy_buffer?srcAe_buffer:srcAe_pre;
    end

    always_comb begin
        case(fwdBe)
            2'b00:
                wrtDe_pre=rd2e;
            2'b01:
                wrtDe_pre=rsltw;
            2'b10:
                wrtDe_pre=aluRsltm;
            2'b11:
                wrtDe_pre=ujWrtBckm;
        endcase

        wrtDe=busy_buffer?wrtDe_buffer:wrtDe_pre;
    end

    always_comb begin
        case(aluSrce)
            1'b0:
                srcBe=wrtDe;
            1'b1:
                srcBe=immexte;
        endcase
    end

    logic [31:0] ujWrtBcke,aluRslte,divOut,aluOut;
    logic zeroe,lstBite,divBusy,divDone;
    logic [31:0] ujWrtBckm,aluRsltm;


    alu ALU(srcAe,srcBe,aluCtrle,aluOut,zeroe,lstBite);
    divider DIV(clk,~rst,div_ene,divCtrle,srcAe,srcBe,divOut,divBusy,divDone);
    
    always_comb begin
        if (csr_wrt_ene) begin
            aluRslte=srcAe;
        end
        else if (divDone) begin
           aluRslte=divOut; 
        end
        else begin
            aluRslte=aluOut;
        end
    end

    always_comb begin
        case(ujMuxe)
            2'b00:
                ujWrtBcke=immexte;
            2'b01:
                ujWrtBcke=immexte+pce;
            2'b10:
                ujWrtBcke=(immexte+srcAe)&~{31'b0,1'b1};
            default:
                ujWrtBcke=32'bxx;
        endcase
    end

    logic regWrtm,memWrtm;
    logic [2:0] rsltSrcm;
    logic [31:0] wrtDm,pc4m;
    logic [4:0] rdm;
    logic readm;
    logic [2:0] funct3m;
    logic [31:0] csrm;
    logic [11:0] csr_addrm;
    logic csr_wrt_enm;
    logic [1:0] csr_srcm;

    exme EM(clk,stallm,regWrte,memWrte,reade,rsltSrce,funct3e,csr_srce,csr_wrt_ene,regWrtm,memWrtm,readm,rsltSrcm,funct3m,csr_srcm,csr_wrt_enm,aluRslte,wrtDe,pc4e,ujWrtBcke,rde,csr_addre,aluRsltm,wrtDm,pc4m,ujWrtBckm,rdm,csr_addrm);
    
    logic [31:0] wrtDShiftedm;
    logic [31:0] readDPreShiftm;
    logic [31:0] readDm;
    logic [31:0] readDw;
    logic [3:0] strobem;
    loadstoredecoder LSD(aluRsltm,wrtDm,funct3m,wrtDShiftedm,strobem);

    always_comb begin
        read=readm;
        wrt=memWrtm;
        wrt_data=wrtDShiftedm;
        wrt_strb=strobem;
        mem_ad=aluRsltm;
        readDPreShiftm=read_data;
    end
    //datmem_axi_lite DM(inf,memWrtm,aluRsltm,wrtDShiftedm,strobem,readm,readDPreShiftm,axi_error,axiBusy);
    loadunit LU(funct3m,strobem,readDPreShiftm,readDm);

    logic [31:0] aluRsltw,pc4w,ujWrtBckw;
    logic [4:0] rdw;
    logic regWrtw,memWrtw;
    logic [2:0] rsltSrcw;
    logic [31:0] csrw;
    logic [31:0] csr_val;

    always_comb begin
        case (csr_srcm)
            2'b00:
                csr_val=aluRsltm;
            2'b01:
                csr_val=csrm|aluRsltm;
            2'b10:
                csr_val=csrm&~aluRsltm;
            default:
                csr_val=32'b0;
        endcase
    end

    logic inst_addr_misaligned;
    csr CSR(clk,~rst,csr_addrm,csr_wrt_enm,csr_val,csrm,timerIrq,swIrq,inst_addr_misaligned,illegal_inst,ebreak,1'b0,1'b0,ecall,pc4d,exception_pc,cacheBusy|axiBusy,divBusy,16'b0,1'b0,trap,mret);

    mewb MW(clk,regWrtm,memWrtm,rsltSrcm,regWrtw,memWrtw,rsltSrcw,readDm,pc4m,ujWrtBckm,aluRsltm,rdm,csrm,readDw,pc4w,ujWrtBckw,aluRsltw,rdw,csrw);

    always_comb begin
        case(rsltSrcw)
            3'b000:
                rsltw=aluRsltw;
            3'b001:
                rsltw=readDw;
            3'b010:
                rsltw=pc4w;
            3'b011:
                rsltw=ujWrtBckw;
            3'b100:
                rsltw=csrw;
            default:
                rsltw=32'b0;
        endcase
    end

    logic stallf,stalld,stalle,stallm,flushd,flushe;

    logic irq,de_exception,ex_exception;
    assign irq=swIrq|timerIrq;
    assign de_exception=illegal_inst|ebreak|ecall|mret;
    assign ex_exception=inst_addr_misaligned;
    hazardunit HAZARD(ad1d,ad2d,ad1e,ad2e,rde,rdm,rdw,rsltSrce,rsltSrcm,irq,de_exception,ex_exception,pcSrc,regWrtm,regWrtw,axiBusy,divBusy,cacheBusy,stallf,stalld,stalle,stallm,flushd,flushe,fwdAe,fwdBe);

    logic bt;
    
    always_comb begin
        case(funct3e)
            3'b000:
                bt=brnche&zeroe;
            3'b001:
                bt=brnche&~zeroe;
            3'b100:
                bt=brnche&lstBite;
            3'b101:
                bt=brnche&~lstBite;
            3'b110:
                bt=brnche&lstBite;
            3'b111:
                bt=brnche&~lstBite;
            default:
                bt=1'bx;
        endcase
    end

    assign pcSrc=(jmpe|bt)&(pcj[1:0]==2'b00);
    assign inst_addr_misaligned=(jmpe|bt)&(pcj[1:0]!=2'b00);
    
endmodule