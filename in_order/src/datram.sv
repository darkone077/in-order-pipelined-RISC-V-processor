module datram#(
    parameter WORDS=2**32
)(
    axi4_if.SLAVE ais
);

    typedef enum logic [1:0] {IDLE,WRT_RECIEVE,WRTRESP_SEND,RDATA_SEND} state_t;
    state_t state,state_nxt;

    logic [31:0] mem [0:WORDS-1];

    always_ff@(posedge ais.ACLK) begin
        if(~ais.ARSTN)begin
            for(int i=0;i<WORDS;i++) begin
                mem[i]<=32'b0;
            end
        end
        else begin
            if (state==WRT_RECIEVE) begin
                mem[addr[31:2]]<={{ais.WSTRB[3]}?ais.WDATA[31:24]:mem[addr[31:2]][31:24],{ais.WSTRB[2]}?ais.WDATA[23:16]:mem[addr[31:2]][23:16],{ais.WSTRB[1]}?ais.WDATA[15:8]:mem[addr[31:2]][15:8],{ais.WSTRB[0]}?ais.WDATA[7:0]:mem[addr[31:2]][7:0]};
            end
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
                state_nxt=WRTRESP_SEND;
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
            ais.BRESP=2'b00;
            state_nxt=IDLE;
           end

           RDATA_SEND:begin
            ais.AWREADY=1'b0;
            ais.ARREADY=1'b0;
            ais.BRESP=2'b00;
            ais.WREADY=1'b0;
            ais.BVALID=1'b0;
            ais.RVALID=1'b1;
            ais.RRESP=2'b00;
            ais.RDATA=mem[addr[31:2]];
            state_nxt=IDLE;
           end

        endcase
    end

endmodule