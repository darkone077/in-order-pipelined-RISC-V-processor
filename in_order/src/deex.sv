`timescale 1ns/1ps

module deex (
    input logic clk, clr,
    //control unit
    input logic regWrtd, memWrtd,jmpd,branchd,aluSrcd,readd,
    input logic [1:0] resltSrcd,
    input logic [2:0] immSrcd, 
    input logic [1:0] ujMuxd,
    input logic [4:0] aluCtrld,
    input logic [2:0] funct3d,
    output logic regWrte, memWrte,jmpe,branche,aluSrce,reade,
    output logic [1:0] resltSrce,
    output logic [2:0] immSrce, 
    output logic [1:0] ujMuxe,
    output logic [4:0] aluCtrle,
    output logic [2:0] funct3e,

    //datapath
    input logic [31:0] rd1d,rd2d,pcd,pc4d,immextd,
    input logic [4:0] ad1d,ad2d,rdd,
    output logic [31:0] rd1e,rd2e,pce,pc4e,immexte,
    output logic [4:0] ad1e,ad2e,rde
    
);

    always_ff@(posedge clk) begin
        if(clr) begin 
            regWrte<=1'b0;
            memWrte<=1'b0;
            jmpe<=1'b0;
            branche<=1'b0;
            aluSrce<=1'b0;
            resltSrce<=2'b0;
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

        end
        else begin 
            regWrte<=regWrtd;
            memWrte<=memWrtd;
            jmpe<=jmpd;
            branche<=branchd;
            aluSrce<=aluSrcd;
            resltSrce<=resltSrcd;
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
        end
    end
    
endmodule