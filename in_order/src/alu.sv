module alu #(
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
    input [31:0] src1,
    input [31:0] src2,
    input [3:0] aluctrl,

    output [31:0] aluout,
    output zero
);

    always_comb begin : logic
        case(aluctrl)

            ADD:
                aluout<=src1+src2;
            SUB:
                aluout<=src1+(~src2+1'b1);
            AND:
                aluout<=src1&src2;
            OR:
                aluout<=src1|src2;
            XOR:
                aluout<=src1^src2;
            SLL:
                aluout<=src1<<src2[4:0];
            SRL:
                aluout<=src1>>src2[4:0];
            SLT:
                aluout<={31'b0,$signed(src1)<$signed(src2)};
            SRA:
                aluout<=$signed(src1)>>src2[4:0];
            SLTU:
                aluout<={31'b0,src1<src2};
            default:
                aluout<=32'b0;
            
        endcase
    end

    assign zero=(aluout==32'b0);

    
endmodule