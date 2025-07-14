module exme (
    input clk,

    //control path
    input regWrte, memWrte,
    input [1:0] rsltSrce,
    output regWrtm, memWrtm,
    output [1:0] rsltSrcm,

    //datapath
    input [31:0] aluRslte,wrtDe,pc4e,
    input [4:0] rde,
    output [31:0] aluRsltm,wrtDm,pc4m,
    output [4:0] rdm
);

    always_ff @( clk ) begin

        regWrtm<=regWrte;
        memWrtm<=memWrte;
        rsltSrcm<=rsltSrce;
        aluRsltm<=aluRslte;
        wrtDm<=wrtDe;
        pc4m<=pc4e;
        rdm<=rde;
        
    end
    
endmodule