`timescale 1ns/1ps

module alu #(
    parameter ADD=5'b00000,
    parameter SUB=5'b00001,
    parameter AND=5'b00010,
    parameter OR=5'b00011,
    parameter XOR=5'b00100,
    parameter SLL=5'b00101,
    parameter SRL=5'b00110,
    parameter SLT=5'b00111,
    parameter SRA=5'b01000,
    parameter SLTU=5'b01001,
    parameter MUL=5'b01010,
    parameter MULH=5'b01011,
    parameter MULHU=5'b01100,
    parameter MULHSU=5'b01101,
    parameter DIV=5'b01110,
    parameter DIVU=5'b01111,
    parameter REM=5'b10000,
    parameter REMU=5'b10001

) (
    input logic [31:0] src1,
    input logic [31:0] src2,
    input logic [4:0] aluctrl,

    output logic [31:0] aluout,
    output logic zero,
    output logic lstBit
);

    always_comb begin
        case(aluctrl)

            ADD:
                aluout=src1+src2;
            SUB:
                aluout=src1+(~src2+1'b1);
            AND:
                aluout=src1&src2;
            OR:
                aluout=src1|src2;
            XOR:
                aluout=src1^src2;
            SLL:
                aluout=src1<<src2[4:0];
            SRL:
                aluout=src1>>src2[4:0];
            SLT:
                aluout={31'b0,$signed(src1)<$signed(src2)};
            SRA:
                aluout=$signed(src1)>>src2[4:0];
            SLTU:
                aluout={31'b0,src1<src2};
            MUL:
                aluout=src1*src2;
            MULH:
                /* verilator lint_off WIDTHTRUNC */
                aluout=($signed({{32{src1[31]}},src1})*$signed({{32{src2[31]}},src2}))>>32;
            MULHU:
                aluout=($unsigned({32'b0,src1})*$unsigned({32'b0,src2}))>>32;
            MULHSU:
                aluout=($signed({{32{src1[31]}},src1})*$unsigned({32'b0,src2}))>>32;
            default:
                aluout=32'b0;
            
        endcase
    end

    assign zero=(aluout==32'b0);
    assign lstBit=aluout[0];

    
endmodule