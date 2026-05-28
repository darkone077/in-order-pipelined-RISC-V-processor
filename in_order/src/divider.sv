module divider(
    input logic clk,rst_n,div_en,
    input logic [1:0] divCtrl,
    input logic [31:0] src1,src2,
    output logic [31:0] divOut,
    output logic busy,done
);

typedef enum logic [1:0] {IDLE,DIV,DONE} state_t;

state_t state,state_nxt;
logic [5:0] zCount,zCountBuffer,N;
logic lzcDone;
logic [31:0] Q,src1t,src2t;
logic [32:0] M,A;

assign src1t=(divCtrl[0])?src1:(src1[31]?(~src1+1):src1);
assign src2t=(divCtrl[0])?src2:(src2[31]?(~src2+1):src2);
always_comb begin
    zCount=6'b0;
    for(int i=31;i>=0;i--) begin
        if (~src1t[i]) begin
            zCount=zCount+1;
        end
        else begin
            break;
        end
    end
end

logic [31:0] divrslt,remrslt;
logic divDone,sign;
always_ff @(posedge clk) begin
    if (~rst_n) begin
        zCountBuffer<=6'b0;
        state<=IDLE;
        divDone<=1'b0;
        M<=33'b0;
        N<=6'b0;
        Q<=32'b0;
        A<=33'b0;
        sign<=1'b0;
    end    
    else begin
        state<=state_nxt;
        case (state)
            IDLE:begin
                zCountBuffer<=zCount;
                Q<=src1t;
                M<={1'b0,src2t};
                A=33'b0;
                N<=32-zCount;
                sign=src1[31]^(~divCtrl[1]&src2[31]);
                divDone<=1'b0;
                if (~src2Valid) begin
                    if(~divCtrl[1]) divOut<=32'hffffffff;
                    else divOut<=src1;
                end
                else if (src1Zero) begin
                    divOut<=32'b0;
                end
            end
            DIV:begin
                if (N==0) begin
                    divDone<=1'b1;
                    /* verilator lint_off WIDTHTRUNC */
                    case (divCtrl)
                    2'b00://div
                        divOut<=(sign)?(~Q+1):Q;
                    2'b01://divu
                        divOut<=Q;
                    2'b10://rem
                        divOut<=(sign)?(~A+1):A;
                    2'b11://remu
                        divOut<=A;
                    endcase
                end
                else begin
                    /* verilator lint_off WIDTHEXPAND */
                   A<=({{A[31:0],{Q<<zCountBuffer}[31]}-M}[32])?{A[31:0],{Q<<zCountBuffer}[31]}:({A[31:0],{Q<<zCountBuffer}[31]}-M);
                   Q<=({{Q<<zCountBuffer}[30:0]>>zCountBuffer,1'b0})+{({{A[31:0],{Q<<zCountBuffer}[31]}-M}[32])?1'b0:1'b1};
                   N<=N-1;
                   divDone<=1'b0;
                end
            end
            DONE:begin
                divDone<=1'b1;
                M<=33'b0;
                N<=6'b0;
                Q<=32'b0;
                A<=33'b0;
            end
            
            default:begin
                state<=IDLE;
                divDone<=1'b0;
                M<=33'b0;
                N<=6'b0;
                Q<=32'b0;
                A<=33'b0;
            end

        endcase
    end
end

logic src2Valid,src1Zero;

always_comb begin
    src2Valid=src2!=32'b0;
    src1Zero=src1==32'b0;
    
    case(state)
        IDLE:begin
            done=1'b0;
            if (div_en) begin
                if (~src2Valid|src1Zero) begin
                    state_nxt=DONE;
                end
                else begin
                    state_nxt=DIV;
                end
                busy=1'b1;

            end
            else begin
                state_nxt=IDLE;
                busy=1'b0;
            end
        end

        DIV:begin
            done=1'b0;
            busy=1'b1;
            if(divDone) begin
                state_nxt=DONE;
            end
            else begin
                state_nxt=DIV;
            end
        end

        DONE:begin
            done=1'b1;
            busy=1'b0;
            state_nxt=IDLE;
        end
        default:begin
            done=1'b0;
            busy=1'b0;
            state_nxt=IDLE;
        end

    endcase


end

endmodule