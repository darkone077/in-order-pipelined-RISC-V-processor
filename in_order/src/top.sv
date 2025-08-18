`timescale 1ns/1ps

module top (
    input logic clk,
    input logic rst
);

    logic [31:0] pcf;
    logic [31:0] pcd;
    logic [31:0] pc4f;
    logic [31:0] pc4d;
    logic [31:0] pcj;
    logic [31:0] instf;
    logic [31:0] instd;
    logic pc_src;
    
    
    assign pc4d=pc+4;
    pc PC(clk,pc_src,stallf,pc4f,pcj,pcf);
    instmem IM(pcf,instf);
    fede FD(clk,flushd,stalld,instf,pc4f,pcf,instd,pc4d,pcd);

    logic [6:0] op;
    logic [2:0] funct3,funct3e;
    logic funct7b5;
    assign op=instd[6:0];
    assign funct3=instd[14:12];
    assign funct7b5=instd[30];
    logic regWrtd,memWrtd,jmpd,brnchd,aluSrcd;
    logic [1:0] rsltSrcd,ujMuxd;
    logic [2:0] immSrcd;
    logic [3:0] aluCtrld;
    logic regWrte,memWrte,jmpe,brnche,aluSrce;
    logic [1:0] rsltSrce,ujMuxe;
    logic [2:0] immSrce;
    logic [3:0] aluCtrle;

    ctrl Control(op,funct3,funct7b5,regWrtd,memWrtd,jmpd,brnchd,aluSrcd,rsltSrcd,ujMuxd,immSrcd,aluCtrld);
    
    logic [4:0] ad1d,ad2d,rdd;
    assign ad1d=instd[19:15];
    assign ad2d=instd[24:20];
    assign rdd=instd[11:7];
    logic [4:0] ad1e,ad2e,rde;
    logic [31:0] rd1d,rd2d;
    logic [31:0] rd1e,rd2e;
    logic [31:0] rsltw;

    regfile RF(clk,1'b1,ad1d,ad2d,rdw,rsltw,regwrtw,rd1d,rd2d);

    logic [24:0] imm;
    logic [31:0] immextd,immexte;

    extend EXTEND(immSrcd,imm,immextd);

    deex DE(clk,flushe,regWrtd,memWrtd,jmpd,brnchd,aluSrcd,rsltSrcd,immSrcd,ujMuxd,aluCtrld,funct3d,regWrte,memWrte,jmpe,brnche,aluSrce,rsltSrce,immSrce,ujMuxe,aluCtrle,funct3e,rd1d,rd2d,pcd,pc4d,immextd,ad1d,ad2d,rdd,rd1e,rd2e,pce,pc4e,immexte,ad1e,ad2e,rde);

    logic [31:0] srcAe,srcBe,wrtDe;
    logic [1:0] fwdAe,fwdBe;

    case(fwdAe)
        2'b00:
            assign srcAe=rd1e;
        2'b01:
            assign srcAe=rsltw;
        2'b10:
            assign srcAe=aluRsltm;
    endcase

    case(fwdBe)
        2'b00:
            assign wrtDe=rd2e;
        2'b01:
            assign wrtDe=rsltw;
        2'b10:
            assign wrtDe=aluRsltm;
    endcase

    case(aluSrce)
        1'b0:
            assign srcBe=wrtDe;
        1'b1:
            assign srcBe=immexte;

    endcase

    logic [31:0] ujWrtBcke,aluRslte;
    logic zeroe,lstBite;
    logic [31:0] ujWrtBckm,aluRsltm;


    alu ALU(srcAe,srcBe,aluCtrle,aluRslte,zeroe,lstBite);

    case(ujMuxe)
        2'b00:
            assign ujWrtBcke=immexte;
        2'b01:
            assign ujWrtBcke=immexte+pce;
        2'b10:
            assign ujWrtBcke=immexte+rd1e;
    endcase

    logic regWrtm,memWrtm;
    logic [1:0], rsltSrcm;
    logic [31:0] wrtDm,pc4m;
    logic [4:0] rdm;

    exme EM(clk,regWrte,memWrte,rsltSrce,regWrtm,memWrtm,rsltSrcm,aluRslte,wrtDe,pc4e,ujWrtBcke,rde,aluRsltm,wrtDm,pc4m,ujWrtBckm,rdm);

    logic [31:0] readDm;
    logic [31:0] readDw;
    datmem DM(clk,aluRsltm,wrtDm,readDm,memWrtm,rst);

    logic [31:0] aluRsltw,pc4w,ujWrtBckw;
    logic [4:0] rdw;
    logic regWrtw,memWrtw;
    logic [1:0] rsltSrcw;

    mewb MW(clk,regWrtm,memWrtm,rsltSrcm,regWrtw,memWrtw,rsltSrcw,readDm,pc4m,ujWrtBckm,aluRsltm,rdm,readDw,pc4w,ujWrtBckw,aluRsltw,rdw);

    case(rsltSrcw)
        2'b00:
            assign rsltw=aluRsltw;
        2'b01:
            assign rsltw=readDw;
        2'b10:
            assign rsltw=pc4w;
        2'b11:
            assign rsltw=ujWrtBckw;
    endcase

    logic stallf,stalld,flushd,flushe;

    hazardunit HAZARD(ad1d,ad2d,ad1e,ad2e,rde,rdm,rdw,rsltSrce,pcSrce,regWrtm,regWrtw,stallf,stalld,flushd,flushe);

    logic bt;

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
    endcase

    assign pc_src=jmpe|bt;
    
endmodule