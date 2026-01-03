`timescale 1ns/1ps

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
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic  [6:0] funct7,
    output logic regWrt,memWrt,jmp,brnch,aluSrc,read,
    output logic [1:0] rsltSrc,ujMux,
    output logic [2:0] immSrc,
    output logic [4:0] aluCtrl
);



    always_comb begin 
        case(op)

            iLoadType:begin
                regWrt=1'b1;
                memWrt=1'b0;
                immSrc=3'b000;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b1;
                rsltSrc=2'b01;
                aluCtrl=5'b00000;
                ujMux=2'bxx;
                read=1'b1;
            end

            iALUType:begin
                regWrt=1'b1;
                memWrt=1'b0;
                immSrc=3'b000;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b1;
                rsltSrc=2'b00;
                ujMux=2'bxx;
                read=1'b0;
                case(funct3)
                    3'b000: //addi
                        aluCtrl=5'b00000;
                    3'b001: //slli
                        aluCtrl=5'b00101;
                    3'b010: //slti
                        aluCtrl=5'b00111;
                    3'b011: //sltiu
                        aluCtrl=5'b01001;
                    3'b100: //xori
                        aluCtrl=5'b00100;
                    3'b101: //srai and srli
                        if(funct7[5]) aluCtrl=5'b01000;
                        else aluCtrl=5'b00110;
                        
                    3'b110: //ori
                        aluCtrl=5'b00011;
                    3'b111: //andi
                        aluCtrl=5'b00010;
                endcase
            end

            rType:begin
                regWrt=1'b1;
                memWrt=1'b0;
                immSrc=3'bxxx;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b0;
                rsltSrc=2'b00;
                ujMux=2'bxx;
                read=1'b0;
                case(funct3)
                    3'b000: //mul, add, sub
                        if(funct7[0]) aluCtrl=5'b01010;
                        else if(~funct7[5]) aluCtrl=5'b00000;
                        else aluCtrl=5'b00001;
                    3'b001: //mulh, sll
                        if(funct7[0]) aluCtrl=5'b01011;
                        else aluCtrl=5'b00101;
                    3'b010: //mulhsu, slt
                        if(funct7[0]) aluCtrl=5'b01101;
                        else aluCtrl=5'b00111;
                    3'b011: //mulu, sltu
                        if(funct7[0]) aluCtrl=5'b01100;
                        else aluCtrl=5'b01001;
                    3'b100: //xor
                        aluCtrl=5'b00100;
                    3'b101: //sra, srl
                        if(funct7[5]) aluCtrl=5'b01000;
                        else aluCtrl=5'b00110;
                        
                    3'b110: //or
                        aluCtrl=5'b00011;
                    3'b111: //and
                        aluCtrl=5'b00010;
                endcase
            end

            sType:begin 
                regWrt=1'b0;
                memWrt=1'b1;
                immSrc=3'b001;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'b1;
                rsltSrc=2'bxx;
                aluCtrl=5'b00000;
                ujMux=2'bxx;
                read=1'b0;
            end

            bType:begin 

                regWrt=1'b0;
                memWrt=1'b0;
                immSrc=3'b010;
                jmp=1'b0;
                brnch=1'b1;
                aluSrc=1'b0;
                rsltSrc=2'bxx;
                ujMux=2'b01;
                read=1'b0;
                case(funct3) 
                    3'b000,3'b001: //beq, bne
                        aluCtrl=5'b00001;
                    3'b100,3'b101: //blt,bge
                        aluCtrl=5'b00111;
                    3'b110,3'b111: //bltu, bgeu
                        aluCtrl=5'b01001;
                    default:
                        aluCtrl=5'b0xxxx;
                                  
                endcase
            end

            uTypeLUI,uTypeAUIPC:begin 
                regWrt=1'b1;
                memWrt=1'b0;
                immSrc=3'b100;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'bx;
                rsltSrc=2'b11;
                aluCtrl=5'b0xxxx;
                read=1'b0;
                if(op==uTypeLUI) ujMux=2'b00;
                else ujMux=2'b01;
                
            end

            jType,jTypeJALR:begin

                regWrt=1'b1;
                memWrt=1'b0;
                read=1'b0;
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
                aluCtrl=5'b0xxxx;
                
            end

            default:begin
                regWrt=1'b0;
                memWrt=1'b0;
                immSrc=3'bxxx;
                jmp=1'b0;
                brnch=1'b0;
                aluSrc=1'bx;
                rsltSrc=2'bxx;
                aluCtrl=5'b0xxxx;
                ujMux=2'bxx; 
                read=1'b0; 
            end  


        endcase
    end



    
    
endmodule