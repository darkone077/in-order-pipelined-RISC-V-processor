module vecalu #(
    parameter VLEN=64,
    parameter ELEN=32,

    parameter ADD=4'b0000,
    parameter SUB=4'b0001,
    parameter AND=4'b0010,
    parameter OR=4'b0011,
    parameter XOR=4'b0100,
    parameter SLL=4'b0101,
    parameter SRL=4'b0110,
    parameter SLT=4'b0111,
    parameter SRA=4'b1000,
    parameter SLTU=4'b1001
) (
    input logic [ELEN-1:0] src1 [0:VLEN-1],
    input logic [ELEN-1:0] src2 [0:VLEN-1],
    input logic [3:0] vecAluCtrl,

    output logic [ELEN-1:0] aluout [0:VLEN-1]

);

    always_comb begin
        case(vecAluCtrl)

            ADD:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=src1[i]+src2[i];
            SUB:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=src1[i]+(~src2[i]+1'b1);
            AND:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=src1[i]&src2[i];
            OR:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=src1[i]|src2[i];
            XOR:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=src1[i]^src2[i];
            SLL:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=src1[i]<<src2[i][4:0];
            SRL:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=src1[i]>>src2[i][4:0];
            SLT:
                for(int i=0;i<VLEN;++i)
                    aluout[i]={31'b0,$signed(src1[i])<$signed(src2[i])};
            SRA:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=$signed(src1[i])>>src2[i][4:0];
            SLTU:
                for(int i=0;i<VLEN;++i)
                    aluout[i]={31'b0,src1[i]<src2[i]};
            default:
                for(int i=0;i<VLEN;++i)
                    aluout[i]=32'b0;
            
        endcase
    end
    
endmodule