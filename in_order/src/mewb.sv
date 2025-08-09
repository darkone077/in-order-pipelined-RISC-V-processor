module mewb (
    input clk,

    //control path
    input regWrtm,memWrtm,
    input [1:0] rsltSrcm,
    output regWrtw,memWrtw,
    output [1:0] rsltSrcw,

    //datapath
    input [31:0] readDm,pc4m,ujWrtBckm,aluRsltm,
    input [4:0] rdm,
    output [31:0] readDw,pc4w,ujWrtBckw,aluRsltw,
    output [4:0] rdw

);

    always_ff @( clk ) begin : 
        
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