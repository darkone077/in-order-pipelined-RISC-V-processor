module loadunit (
    input logic [2:0] funct3,
    input logic [3:0] strobe,
    input logic [31:0] inDat,
    output logic [31:0] outDat
);
    logic [31:0] dat;

always_comb begin
    
    case (funct3)
        3'b000,3'b100:begin //lb,lbu
            case (strobe)
                4'b0000:
                    dat=32'h00000000;
                4'b0001:
                    dat=(inDat&32'h000000FF);
                4'b0010:
                    dat=(inDat&32'h0000FF00)>>8;
                4'b0100:
                    dat=(inDat&32'h00FF0000)>>16;
                4'b1000:
                    dat=(inDat&32'hFF000000)>>24;
                default:
                    dat=32'hxxxxxxxx;
            endcase
        end

        3'b001,3'b101:begin //lh,lhu
            case (strobe)
                4'b0000:
                    dat=32'h00000000;
                4'b0011:
                    dat=(inDat&32'h0000FFFF);
                4'b1100:
                    dat=(inDat&32'hFFFF0000)>>16;
                default:
                    dat=32'hxxxxxxxx;
            endcase
        end
        3'b010:begin //lw
            if(strobe==4'b1111) dat=inDat;
            else dat=32'h00000000;
            
        end
        default:begin
            dat=32'hxxxxxxxx;
        end
    endcase
end

always_comb begin
    case (funct3)
        3'b000,3'b100:begin //lb,lbu
            outDat=(funct3[2])?({24'h000000,dat[7:0]}):({{24{dat[7]}},dat[7:0]});
        end 
        3'b001,3'b101:begin //lh,lhu
            outDat=(funct3[2])?({16'h000000,dat[15:0]}):({{16{dat[15]}},dat[15:0]});
        end       
        3'b010:begin //lw
            outDat=dat;
        end
        default:begin
            outDat=32'hxxxxxxxx;
        end
    endcase
end

endmodule