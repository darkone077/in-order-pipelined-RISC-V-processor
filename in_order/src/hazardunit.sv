module hazardunit (
    input[4:0] rs1d,rs2d,rs1e,rs2e,rde,rdm,rdw,
    input [1:0] rsltSrce,
    input pcSrce,regWrtm,regWrtw,
    output stallf,stalld,flushd,flushe,
    output [1:0] fwdAe,fwdBe
);
    reg lwstall;
    always_comb begin

        if((rdm==rs1e)&&(regWrtm)&&rs1e!=0) fwdAe=2'b10;
        else if((rdw==rs1e)&&(regWrtw)&&rs1e!=0) fwdAe=2'b01;
        else fwdAe=2'b00;

        if((rdm==rs2e)&&(regWrtm)&&rs2e!=0) fwdAe=2'b10;
        else if((rdw==rs2e)&&(regWrtw)&&rs2e!=0) fwdAe=2'b01;
        else fwdAe=2'b00;

        lwstall=(rsltSrce==2'b01)&(rdw==rs1d)||(rdw==rs2d);
        stalld=lwstall;
        stallf=lwstall;
        flushe=lwstall|pcSrce;
        flushd=pcSrce;
    end
    
endmodule