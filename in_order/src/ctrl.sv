module ctrl#(
    parameter iLoadType=7'b0000011,
    parameter iALUType=7'b0010011,
    parameter rType=7'b0110011,
    parameter sType=7'b0100011,
    parameter bType=7'b1100011,
    parameter jType=7'b1101111,
    parameter jTypeJALR=7'b1100111,
    parameter uTypeLUI=7'b0110111,
    parameter uTypeAUIPC=7'b0010111
) (
    input [6:0] op,
    input [2:0] funct3,
    input  funct7b5,
    output regwrt,memwrt,jmp,brnch,aluSrc,
    output [1:0] rsltSrc,ujMux,
    output [2:0] immSrc,
    output [3:0] aluCtrl
);



    always_comb begin 
        case(op)

            iLoadType:begin
                regwrt=1'b1;
                memwrt=1'b0;
                immSrc=3'b000;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b1;
                rsltSrc=2'b01;
                aluCtrl=4'b0000;
            end

            iALUType:begin
                regwrt=1'b1;
                memwrt=1'b0;
                immSrc=3'b000;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b1;
                rsltSrc=2'b00;
                case(funct3)
                    3'b000:
                        aluCtrl=4'b0000;
                    3'b001:
                        aluCtrl=4'b0101;
                    3'b010:
                        aluCtrl=4'b0111;
                    3'b011:
                        aluCtrl=4'b1001;
                    3'b100:
                        aluCtrl=4'b0100;
                    3'b101:
                        if(funct7b5) aluCtrl=4'b1000;
                        else aluCtrl=4'b0110;
                        
                    3'b110:
                        aluCtrl=4'b0011;
                    3'b111:
                        aluCtrl=4'b0010;
                endcase
            end

            rType:begin
                regwrt=1'b1;
                memwrt=1'b0;
                immSrc=3'bxxx;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b0;
                rsltSrc=2'b00;
                case(funct3)
                    3'b000:
                        if(~funct7b5) aluCtrl=4'b0000;
                        else aluCtrl=4'b0001;
                    3'b001:
                        aluCtrl=4'b0101;
                    3'b010:
                        aluCtrl=4'b0111;
                    3'b011:
                        aluCtrl=4'b1001;
                    3'b100:
                        aluCtrl=4'b0100;
                    3'b101:
                        if(funct7b5) aluCtrl=4'b1000;
                        else aluCtrl=4'b0110;
                        
                    3'b110:
                        aluCtrl=4'b0011;
                    3'b111:
                        aluCtrl=4'b0010;
                endcase
            end

            sType:begin 
                regwrt=1'b0;
                memwrt=1'b1;
                immSrc=3'b001;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b1;
                rsltSrc=2'bxx;
                aluCtrl=4'b0000;
            end

            bType:begin 

                regwrt=1'b0;
                memwrt=1'b0;
                immSrc=3'b010;
                jmp=1'b0;
                brnch=1'b1;
                aluSrc=1'b0;
                rsltSrc=2'bxx;
                case(funct3) 
                    000,001:
                        aluCtrl=4'b0001;
                    100,101:
                        aluCtrl=4'b0111;
                    110,111:
                        aluCtrl=4'b1001;
                                  
                endcase
            end

            uTypeLUI,uTypeAUIPC:begin 
                regwrt=1'b1;
                memwrt=1'b0;
                immSrc=3'b100;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'bx;
                rsltSrc=2'b11;
                aluCtrl=4'bxxxx;
                if(op==uTypeLUI) ujMux=2'b00;
                else ujMux=2'b01;
                
            end
            jType,jTypeJALR:begin

                regwrt=1'b1;
                memwrt=1'b0;
                if(op==jType) begin 
                    immSrc=3'b011;
                    ujMux=2'b01;
                end
                else begin 
                    immSrc=3'b000;
                    ujMux=2'b10;
                end
                jmp=1'b1;
                brnch=1'b0;
                aluSrc=1'bx;
                rsltSrc=2'b10;
                aluCtrl=4'bxxxx;
                
             end



        endcase
    end



    
    
endmodule