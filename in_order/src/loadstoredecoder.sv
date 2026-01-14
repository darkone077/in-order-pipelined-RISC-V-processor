module loadstoredecoder (
    input logic [31:0] ad, inDat,
    input logic [2:0] funct3,
    output logic [31:0] outDat,
    output logic [3:0] strobe
);
always_comb begin
    
    case (funct3)
        3'b000,3'b100:begin //sb,lb,lbu
            case (ad[1:0])
                2'b00:begin
                    strobe=4'b0001;
                    outDat=(inDat&32'h000000FF);
                end
                2'b01:begin
                    strobe=4'b0010;
                    outDat=(inDat&32'h000000FF)<<8;
                end
                2'b10:begin
                    strobe=4'b0100;
                    outDat=(inDat&32'h000000FF)<<16;
                end
                2'b11:begin
                    strobe=4'b1000;
                    outDat=(inDat&32'h000000FF)<<24;
                end
            endcase
            
        end

        3'b001,3'b101:begin //sh,lh,lhu
            case (ad[1:0])
               2'b00:begin
                    strobe=4'b0011;
                    outDat=(inDat&32'h0000FFFF);
                end
                2'b10:begin
                    strobe=4'b1100;
                    outDat=(inDat&32'h0000FFFF)<<16;
                end
                default:begin
                    strobe=4'b0000;
                    outDat=32'hxxxxxxxx;
                end

            endcase
        end

        3'b010:begin //sw,lw
            if(ad[1:0]==2'b00) begin
                strobe=4'b1111;
                outDat=inDat;
            end
            else begin
                strobe=4'b000;
                outDat=32'hxxxxxxxx;
            end
        end
        default:begin
            strobe=4'b0000;
            outDat=32'hxxxxxxxx;
        end
    endcase
end
endmodule