`timescale 1ns/1ps
`include "/home/kaush/cpu2/in_order/src/alu.sv"
`include "/home/kaush/cpu2/in_order/src/ctrl.sv"
`include "/home/kaush/cpu2/in_order/src/datmem.sv"
`include "/home/kaush/cpu2/in_order/src/deex.sv"
`include "/home/kaush/cpu2/in_order/src/extend.sv"
`include "/home/kaush/cpu2/in_order/src/fede.sv"
`include "/home/kaush/cpu2/in_order/src/hazardunit.sv"
`include "/home/kaush/cpu2/in_order/src/instmem.sv"
`include "/home/kaush/cpu2/in_order/src/mewb.sv"
`include "/home/kaush/cpu2/in_order/src/pc.sv"
`include "/home/kaush/cpu2/in_order/src/regfile.sv"
`include "/home/kaush/cpu2/in_order/src/exme.sv"

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
    
    
    assign pc4f=pcf+4;
    pc PC(clk,pc_src,stallf,pc4f,pcj,pcf);
    instmem IM(pcf,instf);
    fede FD(clk,flushd,stalld,instf,pc4f,pcf,instd,pc4d,pcd);

    logic [6:0] op;
    logic [2:0] funct3,funct3e,funct3d;
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
    logic [31:0] rd1e,rd2e,pce;
    logic [31:0] pc4e;
    logic [31:0] rsltw;

    regfile RF(clk,1'b1,ad1d,ad2d,rdw,rsltw,regWrtw,rd1d,rd2d);

    logic [24:0] imm;
    assign imm=instd[31:7];
    logic [31:0] immextd,immexte;

    extend EXTEND(immSrcd,imm,immextd);

    deex DE(clk,flushe,regWrtd,memWrtd,jmpd,brnchd,aluSrcd,rsltSrcd,immSrcd,ujMuxd,aluCtrld,funct3d,regWrte,memWrte,jmpe,brnche,aluSrce,rsltSrce,immSrce,ujMuxe,aluCtrle,funct3e,rd1d,rd2d,pcd,pc4d,immextd,ad1d,ad2d,rdd,rd1e,rd2e,pce,pc4e,immexte,ad1e,ad2e,rde);

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
            default:
                srcAe=32'bx;
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

    exme EM(clk,regWrte,memWrte,rsltSrce,regWrtm,memWrtm,rsltSrcm,aluRslte,wrtDe,pc4e,ujWrtBcke,rde,aluRsltm,wrtDm,pc4m,ujWrtBckm,rdm);

    logic [31:0] readDm;
    logic [31:0] readDw;
    datmem DM(clk,aluRsltm,wrtDm,readDm,memWrtm,rst);

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

    logic stallf=1;
    logic stalld,flushd,flushe;

    hazardunit HAZARD(ad1d,ad2d,ad1e,ad2e,rde,rdm,rdw,rsltSrce,pc_src,regWrtm,regWrtw,stallf,stalld,flushd,flushe,fwdAe,fwdBe);

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

    assign pc_src=jmpe|bt;
    
endmodule