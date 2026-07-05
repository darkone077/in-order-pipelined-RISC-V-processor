`timescale 1ns/1ps

module deex (
    input logic clk, clr,en_n,
    //control unit
    input logic regWrtd,memWrtd,jmpd,branchd,aluSrcd,readd,div_end,csr_immd,csr_wrt_end,atomicd,
    input logic [2:0] rsltSrcd,
    input logic [2:0] immSrcd, 
    input logic [1:0] ujMuxd,
    input logic [4:0] aluCtrld,
    input logic [2:0] funct3d,
    input logic [1:0] divCtrld,
    input logic [1:0] csr_srcd,
    input logic [3:0] a_ctrld,

    output logic regWrte,memWrte,jmpe,branche,aluSrce,reade,div_ene,csr_imme,csr_wrt_ene,atomice,
    output logic [2:0] rsltSrce,
    output logic [2:0] immSrce, 
    output logic [1:0] ujMuxe,
    output logic [4:0] aluCtrle,
    output logic [2:0] funct3e,
    output logic [1:0] divCtrle,
    output logic [1:0] csr_srce,
    output logic [3:0] a_ctrle,

    //datapath
    input logic [31:0] rd1d,rd2d,pcd,pc4d,immextd,
    input logic [4:0] ad1d,ad2d,rdd,
    input logic [11:0] csr_addrd,
    //input logic [31:0] csrd,

    output logic [31:0] rd1e,rd2e,pce,pc4e,immexte,
    output logic [4:0] ad1e,ad2e,rde,
    output logic [11:0] csr_addre
    //output logic [31:0] csre
    
);

    always_ff@(posedge clk) begin
        if(clr) begin 
            regWrte<=1'b0;
            memWrte<=1'b0;
            jmpe<=1'b0;
            branche<=1'b0;
            aluSrce<=1'b0;
            rsltSrce<=3'b0;
            immSrce<=3'b0;
            aluCtrle<=5'b0;
            rd1e<=32'b0;
            rd2e<=32'b0;
            pce<=32'b0;
            pc4e<=32'b0;
            immexte<=32'b0;
            ad1e<=5'b0;
            ad2e<=5'b0;
            rde<=5'b0;
            ujMuxe<=2'b0;
            funct3e<=3'b0;
            reade<=1'b0;
            divCtrle<=2'b00;
            div_ene<=1'b0;
            csr_srce<=2'b0;
            csr_imme<=1'b0;
            csr_wrt_ene<=1'b0;
            //csre<=32'b0;
            csr_addre<=12'b0;
            atomice<=1'b0;
            a_ctrle<=4'b0;

        end
        else if(~en_n) begin 
            regWrte<=regWrtd;
            memWrte<=memWrtd;
            jmpe<=jmpd;
            branche<=branchd;
            aluSrce<=aluSrcd;
            rsltSrce<=rsltSrcd;
            immSrce<=immSrcd;
            aluCtrle<=aluCtrld;
            rd1e<=rd1d;
            rd2e<=rd2d;
            pce<=pcd;
            pc4e<=pc4d;
            immexte<=immextd;
            ad1e<=ad1d;
            ad2e<=ad2d;
            rde<=rdd;
            ujMuxe<=ujMuxd;
            funct3e<=funct3d;
            reade<=readd;
            divCtrle<=divCtrld;
            div_ene<=div_end;
            csr_srce<=csr_srcd;
            csr_imme<=csr_immd;
            csr_wrt_ene<=csr_wrt_end;
            //csre<=csrd;
            csr_addre<=csr_addrd;
            a_ctrle<=a_ctrld;
            atomice<=atomicd;
        end
    end
    
endmodule