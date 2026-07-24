module ram #(
    parameter SIZE=2**25
)(
    axi4_if.SLAVE ais
);

    logic [31:0] mem [0:SIZE-1];
    initial begin
        $readmemh("tb/memory.mem",mem);
    end
    typedef enum logic [1:0] {IDLE,WRT_RECIEVE,WRESP_SEND,RDATA_SEND} state_t;
    state_t state,state_nxt;
    logic [31:0] addr;
    logic [7:0] len;

    always_ff @(posedge ais.ACLK) begin
        if (~ais.ARSTN) begin
            state<=IDLE;
            addr<=32'b0;
            len<=8'b0;
        end
        else begin
            state<=state_nxt;
            
            /* verilator lint_off CASEINCOMPLETE */
            case (state)
                IDLE:begin
                    if (ais.AWVALID) begin
                        addr<=ais.AWADDR;
                        len<=ais.AWLEN;
                    end
                    else if (ais.ARVALID) begin
                        addr<=ais.ARADDR;
                        len<=ais.ARLEN;
                    end
                end
                WRT_RECIEVE:begin
                    addr<=addr+4;
                    len<=len-1;
                    /* verilator lint_off WIDTHTRUNC */
                    mem[addr[31:2]]<={{ais.WSTRB[3]}?ais.WDATA[31:24]:mem[addr[31:2]][31:24],{ais.WSTRB[2]}?ais.WDATA[23:16]:mem[addr[31:2]][23:16],{ais.WSTRB[1]}?ais.WDATA[15:8]:mem[addr[31:2]][15:8],{ais.WSTRB[0]}?ais.WDATA[7:0]:mem[addr[31:2]][7:0]};
                end
                RDATA_SEND:begin
                    addr<=addr+4;
                    len<=len-1;
                end
            endcase
        end
    end

    always_comb begin
        ais.AWREADY=1'b1;
        ais.ARREADY=1'b1;
        ais.WREADY=1'b0;
        ais.BRESP=2'b00;
        ais.BVALID=1'b0;
        ais.RDATA=mem[addr[31:2]];
        ais.RRESP=2'b00;
        ais.RVALID=1'b0;
        ais.RID=4'b0000;
        ais.RLAST=1'b1;
        ais.BID=4'b0000;
        case (state)
            IDLE:begin

                if (ais.AWVALID) begin
                state_nxt=WRT_RECIEVE;
                end
                else if (ais.ARVALID) begin
                    state_nxt=RDATA_SEND;
                end
                else begin
                    state_nxt=IDLE;
                end
            end

            WRT_RECIEVE:begin
                ais.AWREADY=1'b0;
                ais.ARREADY=1'b0;
                ais.WREADY=1'b1;
                if (ais.WLAST&&(len==0)) begin
                    state_nxt=WRESP_SEND;
                end
                else begin
                    state_nxt=WRT_RECIEVE;
                end
            end
            WRESP_SEND:begin
                ais.AWREADY=1'b0;
                ais.ARREADY=1'b0;
                ais.BVALID=1'b1;
                state_nxt=IDLE;
            end
            RDATA_SEND:begin
                ais.AWREADY=1'b0;
                ais.ARREADY=1'b0;
                ais.RVALID=1'b1;
                if (len>0) begin
                    ais.RLAST=1'b0;
                    state_nxt=RDATA_SEND;
                end
                else begin
                    state_nxt=IDLE;
                end
            end

        endcase
    end
endmodule