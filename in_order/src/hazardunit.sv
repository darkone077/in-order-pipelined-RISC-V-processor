`timescale 1ns/1ps

module hazardunit (
    input logic[4:0] rs1d,rs2d,rs1e,rs2e,rde,rdm,rdw,
    input logic [1:0] rsltSrce,
    input logic pcSrce,regWrtm,regWrtw,
    output logic stallf,stalld,flushd,flushe,
    output logic [1:0] fwdAe,fwdBe
);
    logic lwstall;
    always_comb begin

        if((rdm==rs1e)&&(regWrtm)&&rs1e!=0) fwdAe=2'b10;
        else if((rdw==rs1e)&&(regWrtw)&&rs1e!=0) fwdAe=2'b01;
        else fwdAe=2'b00;

        if((rdm==rs2e)&&(regWrtm)&&rs2e!=0) fwdBe=2'b10;
        else if((rdw==rs2e)&&(regWrtw)&&rs2e!=0) fwdBe=2'b01;
        else fwdBe=2'b00;

        lwstall=(rsltSrce==2'b01)&&((rde==rs1d)||(rde==rs2d));
        stalld=lwstall;
        stallf=lwstall;
        flushe=lwstall|pcSrce;
        flushd=pcSrce;
    end
    
endmodule