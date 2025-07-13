module extend (
    input [1:0] immsrc,
    input [24:0] imm,
    output [31:0] immext
);

    always_comb begin : immSources

        case(immsrc)
            2'b00:          //I-type
                immext<={{20{imm[24]}},imm[24:13]};
            
            2'b01:          //S-type
                immext<={{20{imm[24]}},imm[24:18],imm[4:0]};

            2'b10:          //B-type
                immext<={{20{imm[24]}},imm[0],imm[23:18],1'b0};

            2'b11:          //J-type
                immext<={{20{imm[24]}},imm[12:5],imm[13],imm[23:14],1'b0};

            default: immext<=32'd0;
        endcase

    end
    
endmodule