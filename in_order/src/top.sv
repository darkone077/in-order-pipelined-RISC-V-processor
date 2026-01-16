`timescale 1ns/1ps
`include "../src/alu.sv"
`include "../src/ctrl.sv"
`include "../src/datmem.sv"
`include "../src/deex.sv"
`include "../src/extend.sv"
`include "../src/fede.sv"
`include "../src/hazardunit.sv"
`include "../src/instmem.sv"
`include "../src/mewb.sv"
`include "../src/pc.sv"
`include "../src/regfile.sv"
`include "../src/exme.sv"
`include "../src/axi4-lite_if.sv"
`include "../src/datmem_axi_lite.sv"
`include "../src/loadstoredecoder.sv"
`include "../src/loadunit.sv"

module top (
    input logic clk,
    input logic rst,
    output logic axi_error,
    output logic [31:0] pcf, pcj,
    axi4_if.MASTER inf
    
);
    
    logic [31:0] pcd;
    logic [31:0] pc4f;
    logic [31:0] pc4d;
    logic [31:0] instf;
    logic [31:0] instd;
    logic pcSrc;
    
    assign pcj=ujWrtBcke;
    assign pc4f=pcf+4;
    pc PC(clk,pcSrc,stallf,rst,pc4f,pcj,pcf);
    instmem IM(pcf,instf);
    fede FD(clk,flushd|rst,stalld,instf,pc4f,pcf,instd,pc4d,pcd);

    logic [6:0] op;
    logic [2:0] funct3,funct3e,funct3d;
    logic [6:0] funct7;
    assign op=instd[6:0];
    assign funct3d=instd[14:12];
    assign funct7=instd[31:25];
    logic regWrtd,memWrtd,jmpd,brnchd,aluSrcd,readd;
    logic [1:0] rsltSrcd,ujMuxd;
    logic [2:0] immSrcd;
    logic [4:0] aluCtrld;
    logic regWrte,memWrte,jmpe,brnche,aluSrce,reade;
    logic [1:0] rsltSrce,ujMuxe;
    logic [2:0] immSrce;
    logic [4:0] aluCtrle;

    ctrl Control(op,funct3d,funct7,regWrtd,memWrtd,jmpd,brnchd,aluSrcd,readd,rsltSrcd,ujMuxd,immSrcd,aluCtrld);
    
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

    deex DE(clk,flushe,stalle,regWrtd,memWrtd,jmpd,brnchd,aluSrcd,readd,rsltSrcd,immSrcd,ujMuxd,aluCtrld,funct3d,regWrte,memWrte,jmpe,brnche,aluSrce,reade,rsltSrce,immSrce,ujMuxe,aluCtrle,funct3e,rd1d,rd2d,pcd,pc4d,immextd,ad1d,ad2d,rdd,rd1e,rd2e,pce,pc4e,immexte,ad1e,ad2e,rde);

    logic [31:0] srcAe,srcBe,wrtDe;
    logic [1:0] fwdAe,fwdBe;

    always_comb begin
        case(fwdAe)
            2'b00:
                srcAe=rd1e;
            2'b01:
                srcAe=rsltw;
            2'b10:
                srcAe=aluRsltm;
            2'b11:
                srcAe=ujWrtBckm;
        endcase
    end

    always_comb begin
        case(fwdBe)
            2'b00:
                wrtDe=rd2e;
            2'b01:
                wrtDe=rsltw;
            2'b10:
                wrtDe=aluRsltm;
            default:
                wrtDe=32'bx;
        endcase
    end

    always_comb begin
        case(aluSrce)
            1'b0:
                srcBe=wrtDe;
            1'b1:
                srcBe=immexte;
        endcase
    end

    logic [31:0] ujWrtBcke,aluRslte;
    logic zeroe,lstBite;
    logic [31:0] ujWrtBckm,aluRsltm;


    alu ALU(srcAe,srcBe,aluCtrle,aluRslte,zeroe,lstBite);

    always_comb begin
        case(ujMuxe)
            2'b00:
                ujWrtBcke=immexte;
            2'b01:
                ujWrtBcke=immexte+pce;
            2'b10:
                ujWrtBcke=immexte+rd1e;
            default:
                ujWrtBcke=32'bxx;
        endcase
    end

    logic regWrtm,memWrtm;
    logic [1:0] rsltSrcm;
    logic [31:0] wrtDm,pc4m;
    logic [4:0] rdm;
    logic readm;
    logic [2:0] funct3m;

    exme EM(clk,stallm,regWrte,memWrte,reade,rsltSrce,funct3e,regWrtm,memWrtm,readm,rsltSrcm,funct3m,aluRslte,wrtDe,pc4e,ujWrtBcke,rde,aluRsltm,wrtDm,pc4m,ujWrtBckm,rdm);
    
    logic [31:0] wrtDShiftedm;
    logic [31:0] readDPreShiftm;
    logic [31:0] readDm;
    logic [31:0] readDw;
    logic busy;
    logic [2:0] funct3Bufferm;
    logic [3:0] strobem,strobeBufferm;
    loadstoredecoder LSD(aluRsltm,wrtDm,funct3m,wrtDShiftedm,strobem);

    datmem_axi_lite DM(inf,memWrtm,aluRsltm,wrtDShiftedm,strobem,readm,readDPreShiftm,axi_error,busy);
    loadunit LU(funct3m,strobem,readDPreShiftm,readDm);

    logic [31:0] aluRsltw,pc4w,ujWrtBckw;
    logic [4:0] rdw;
    logic regWrtw,memWrtw;
    logic [1:0] rsltSrcw;

    mewb MW(clk,regWrtm,memWrtm,rsltSrcm,regWrtw,memWrtw,rsltSrcw,readDm,pc4m,ujWrtBckm,aluRsltm,rdm,readDw,pc4w,ujWrtBckw,aluRsltw,rdw);

    always_comb begin
        case(rsltSrcw)
            2'b00:
                rsltw=aluRsltw;
            2'b01:
                rsltw=readDw;
            2'b10:
                rsltw=pc4w;
            2'b11:
                rsltw=ujWrtBckw;
        endcase
    end

    logic stallf,stalld,stalle,stallm,flushd,flushe;

    hazardunit HAZARD(ad1d,ad2d,ad1e,ad2e,rde,rdm,rdw,rsltSrce,rsltSrcm,pcSrc,regWrtm,regWrtw,busy,stallf,stalld,stalle,stallm,flushd,flushe,fwdAe,fwdBe);

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

    assign pcSrc=jmpe|bt;
    
endmodule