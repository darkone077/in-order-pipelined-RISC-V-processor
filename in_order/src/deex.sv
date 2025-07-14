module deex (
    input clk, clr,
    //control unit
    input regWrtd, memWrtd,jmpd,branchd,aluSrcd,
    input [1:0] resltSrcd,immSrcd,
    input [3:0] aluCtrld,
    output regWrte, memWrte,jmpe,branche,aluSrce,
    output [1:0] resltSrce,immSrce,
    output [3:0] aluCtrle,

    //datapath
    input [31:0] rd1d,rd2d,pcd,pc4d,immextd,
    input [4:0] ad1d,ad2d,rdd,
    output [31:0] rd1e,rd2e,pce,pc4e,immexte,
    output [4:0] ad1e,ad2e,rde
    
);

    always_ff @( clk ) begin : decode_excuteReg
        if(clr) begin 
            regWrte<=1'b0;
            memWrte<=1'b0;
            jmpe<=1'b0;
            branche<=1'b0;
            aluSrce<=1'b0;
            resltSrce<=2'b0;
            immSrce<=2'b0;
            aluCtrle<=3'b00;
            rd1e<=32'b0;
            rd2e<=32'b0;
            pce<=32'b0;
            pc4e<=32'b0;
            immexte<=32'b0;
            ad1e<=5'b0;
            add2e<=5'b0;
            rde<=5'b0;

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
            add2e<=ad2d;
            rde<=rdd;
        end
    end
    
endmodule