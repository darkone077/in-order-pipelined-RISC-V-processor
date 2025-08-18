`timescale 1ns/1ps

module mewb (
    input logic clk,

    //control path
    input logic regWrtm,memWrtm,
    input logic [1:0] rsltSrcm,
    output logic regWrtw,memWrtw,
    output logic [1:0] rsltSrcw,

    //datapath
    input logic [31:0] readDm,pc4m,ujWrtBckm,aluRsltm,
    input logic [4:0] rdm,
    output logic [31:0] readDw,pc4w,ujWrtBckw,aluRsltw,
    output logic [4:0] rdw

);

    always_ff @(posedge clk ) begin
        
        regWrtw<=regWrtm;
        memWrtw<=memWrtm;
        rsltSrcw<=rsltSrcm;
        readDw<=readDm;
        pc4w<=pc4m;
        rdw<=rdm;
        ujWrtBckw<=ujWrtBckm;
        aluRsltw<=aluRsltm;
        
    end
    
endmodule