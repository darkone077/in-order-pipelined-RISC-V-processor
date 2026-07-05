`timescale 1ns/1ps

module exme (
    input logic clk,
    input logic en_n,
    //control path
    input logic regWrte, memWrte,reade,
    input logic [2:0] rsltSrce,
    input logic [2:0] funct3e,
    input logic [1:0] csr_srce,
    input logic csr_wrt_ene,atomice,
    input logic [3:0] a_ctrle,
    output logic regWrtm, memWrtm,readm,
    output logic [2:0] rsltSrcm,
    output logic [2:0] funct3m,
    output logic [1:0] csr_srcm,
    output logic csr_wrt_enm,atomicm,
    output logic [3:0] a_ctrlm,

    //datapath
    input logic [31:0] aluRslte,wrtDe,pc4e,ujWrtBcke,
    input logic [4:0] rde,
    input logic [11:0] csr_addre,
    //input logic [31:0] csre,
    output logic [31:0] aluRsltm,wrtDm,pc4m,ujWrtBckm,
    output logic [4:0] rdm,
    output logic [11:0] csr_addrm
    //output logic [31:0] csrm
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
            //csrm<=csre;
            csr_srcm<=csr_srce;
            csr_addrm<=csr_addre;
            csr_wrt_enm<=csr_wrt_ene;
            a_ctrlm<=a_ctrle;
            atomicm<=atomice;
        end
    end
    
endmodule