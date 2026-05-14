module clint#(
    parameter BASE=32'h200000
)(
    axi4_if.SLAVE ais,
    output logic timerIrq,softIrq
);

    localparam MSIP=32'h0000;
    localparam MTIMECMPLOW=32'h4000; 
    localparam MTIMECMPHIGH=32'h4004;
    localparam MTIMELOW=32'hbff8;
    localparam MTIMEHIGH=32'hbffc;

    typedef enum logic [1:0] {IDLE,WRT_RECIEVE,WRTRESP_SEND,RDATA_SEND} state_t;
    state_t state,state_nxt;

    logic [63:0] mtime,mtimecmp;
    logic [31:0] msip,msip_nxt;

    always_ff @(posedge ais.ACLK) begin
        if(~ais.ARSTN)begin
            mtime<=64'b0;
            mtimecmp<=64'hffffffffffffffff;
            msip<=32'b0;

        end
        else begin
            mtime<=mtime+1'b1;
            if (state==WRT_RECIEVE&(addr-BASE)==MTIMECMPLOW) begin
                mtimecmp[31:0]<=ais.WDATA;
            end
            else if(state==WRT_RECIEVE&(addr-BASE)==MTIMECMPHIGH)begin
                mtimecmp[63:32]<=ais.WDATA;
            end
            
            msip<=msip_nxt;
        end
    end

    logic [31:0] addr;
    always_ff @(posedge ais.ACLK) begin
        if (~ais.ARSTN) begin
            state<=IDLE;
            addr<=32'b0;
        end
        else begin
            state<=state_nxt;
            /* verilator lint_off CASEINCOMPLETE */
            case (state)
                IDLE:begin
                    if(ais.AWVALID) addr<=ais.AWADDR;
                    else if(ais.ARVALID) addr<=ais.ARADDR;
                end
            endcase
            /* verilator lint_off CASEINCOMPLETE */
        end
    end

    always_comb begin
        case (state)
           IDLE:begin
            ais.AWREADY=1'b1;
            ais.WREADY=1'b0;
            ais.ARREADY=1'b1;
            ais.BRESP=2'b00;
            ais.RRESP=2'b00;
            ais.RDATA=32'b0;
            ais.BVALID=1'b0;
            ais.RVALID=1'b0;
            if (ais.ARVALID) begin
                state_nxt=RDATA_SEND;
            end
            else if (ais.AWVALID) begin
                state_nxt=WRT_RECIEVE;
            end
            else begin
                state_nxt=IDLE;
            end
           end
           
           WRT_RECIEVE:begin
            ais.AWREADY=1'b0;
            ais.ARREADY=1'b0;
            ais.WREADY=1'b1;
            ais.BRESP=2'b00;
            ais.RRESP=2'b00;
            ais.RDATA=32'b0;
            ais.BVALID=1'b0;
            ais.RVALID=1'b0;
            if (ais.WVALID) begin
                case (addr-BASE)
                    MSIP:begin
                        msip_nxt=ais.WDATA;
                        state_nxt=WRTRESP_SEND;
                    end
                    MTIMECMPLOW:begin
                        state_nxt=WRTRESP_SEND;
                    end
                    MTIMECMPHIGH:begin
                        state_nxt=WRTRESP_SEND;
                    end
                    default:begin
                        state_nxt=WRTRESP_SEND;
                    end
                    
                endcase
                
            end
            else begin
                state_nxt=WRT_RECIEVE;
            end
           end

           WRTRESP_SEND:begin
            ais.AWREADY=1'b0;
            ais.ARREADY=1'b0;
            ais.RRESP=2'b00;
            ais.RDATA=32'b0;
            ais.WREADY=1'b0;
            ais.BVALID=1'b1;
            ais.RVALID=1'b0;
            
            if((addr-BASE)==MSIP|(addr-BASE)==MTIMECMPLOW|(addr-BASE)==MTIMECMPHIGH) ais.BRESP=2'b00;
            else ais.BRESP=2'b11;
            state_nxt=IDLE;
           end

           RDATA_SEND:begin
            ais.AWREADY=1'b0;
            ais.ARREADY=1'b0;
            ais.BRESP=2'b00;
            ais.WREADY=1'b0;
            ais.BVALID=1'b0;
            ais.RVALID=1'b1;
            case (addr-BASE)
                MSIP:begin
                    ais.RDATA=msip;
                    ais.RRESP=2'b00;
                end
                MTIMECMPLOW:begin
                    ais.RDATA=mtimecmp[31:0];
                    ais.RRESP=2'b00;
                end
                MTIMECMPHIGH:begin
                    ais.RDATA=mtimecmp[63:32];
                    ais.RRESP=2'b00;
                end
                MTIMELOW:begin
                    ais.RDATA={mtime[7:0],mtime[15:8],mtime[23:16],mtime[31:24]};
                    ais.RRESP=2'b00;
                end
                MTIMEHIGH:begin
                    ais.RDATA={mtime[39:32],mtime[47:40],mtime[55:48],mtime[63:56]};
                    ais.RRESP=2'b00;
                end
                default:begin
                    ais.RDATA=32'hffffffff;
                    ais.RRESP=2'b11;
                end
            endcase

            state_nxt=IDLE;
           end

        endcase
    end

    assign softIrq=msip[24];
    assign timerIrq=(mtime>={mtimecmp[39:32],mtimecmp[47:40],mtimecmp[55:48],mtimecmp[63:56],mtimecmp[7:0],mtimecmp[15:8],mtimecmp[23:16],mtimecmp[31:24]});
endmodule