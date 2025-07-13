module alu (
    input [31:0] src1,
    input [31:0] src2,
    input [2:0] aluctrl,

    output [31:0] aluout,
    output zero
);

    always_comb begin : logic
        case(aluctrl)

            3'b000:
                aluout<=src1+src2;
            
        endcase
    end

    
endmodule