`timescale 1ns/1ps

module exme (
    input logic clk,
    input logic en_n,
    //control path
    input logic regWrte, memWrte,reade,
    input logic [1:0] rsltSrce,
    input logic [2:0] funct3e,
    output logic regWrtm, memWrtm,readm,
    output logic [1:0] rsltSrcm,
    output logic [2:0] funct3m,

    //datapath
    input logic [31:0] aluRslte,wrtDe,pc4e,ujWrtBcke,
    input logic [4:0] rde,
    output logic [31:0] aluRsltm,wrtDm,pc4m,ujWrtBckm,
    output logic [4:0] rdm
);

    always_ff @( posedge clk ) begin
        if(~en_n) begin
            regWrtm<=regWrte;
            memWrtm<=memWrte;
            rsltSrcm<=rsltSrce;
            aluRsltm<=aluRslte;
            wrtDm<=wrtDe;
            pc4m<=pc4e;
            rdm<=rde;
            ujWrtBckm<=ujWrtBcke;
            readm<=reade;
            funct3m<=funct3e;
        end
    end
    
endmodule