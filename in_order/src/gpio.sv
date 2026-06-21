module gpio #(
    parameter GPIO_START=32'h2010000,
    parameter GPIO_END=32'h15000000,
    parameter IO_END=32'hffff
) (
    axi4_lite_if.SLAVE ais,
    output logic [3:0] read,wrt,
    output logic [31:0] addr,
    input logic [31:0] read_data [0:3],
    output logic [31:0] wrt_data [0:3] 
);
    localparam IO1_START=GPIO_START;
    localparam IO1_END=IO1_START+IO_END;
    localparam IO2_START=IO1_END+1;
    localparam IO2_END=IO2_START+IO_END;
    localparam IO3_START=IO2_END+1;
    localparam IO3_END=IO3_START+IO_END;
    localparam IO4_START=IO3_END+1;
    localparam IO4_END=IO4_START+IO_END;

    typedef enum logic [1:0] {IDLE,WRT_RECIEVE,WRTRESP_SEND,RDATA_SEND} state_t;
    state_t state,state_nxt;
    logic [1:0] io;

    always_ff @(posedge ais.ACLK) begin
        if (~ais.ARSTN) begin
            state<=IDLE;
            addr<=32'b0;
        end    
        else begin
            state<=state_nxt;
            case (state)
                IDLE:begin
                    if(ais.AWVALID) addr<=ais.AWADDR;
                    else if(ais.ARVALID) addr<=ais.ARADDR;
                    else addr<=32'b0;
                end
                WRT_RECIEVE:begin
                    wrt_data[io]<=ais.WDATA;
                end
                default:begin
                    
                end
            endcase
        end
    end

    always_comb begin
        io=2'b11;
        for (int i=IO1_END;i<=IO4_END;i+=IO_END+1) begin
            if (addr<=i) begin
                io+=2'b01;
                break;
            end
        end
    end

    always_comb begin
        ais.AWREADY=1'b1;
        ais.WREADY=1'b0;
        ais.ARREADY=1'b1;
        ais.BRESP=2'b00;
        ais.RRESP=2'b00;
        ais.RDATA=read_data[io];
        ais.BVALID=1'b0;
        ais.RVALID=1'b0;
        read=4'b0000;
        wrt=4'b0000;

        case (state)
            IDLE:begin
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
                if (ais.WVALID) begin
                    state_nxt=WRTRESP_SEND;
                end
                else begin
                    state_nxt=WRT_RECIEVE;
                end
            end
            WRTRESP_SEND:begin
                ais.BVALID=1'b1;
                ais.AWREADY=1'b0;
                ais.ARREADY=1'b0;
                wrt[io]=1'b1;
                state_nxt=IDLE;
            end
            RDATA_SEND:begin
                read[io]=1'b1;
                ais.AWREADY=1'b0;
                ais.ARREADY=1'b0;
                ais.RVALID=1'b1;

                state_nxt=IDLE;

            end
        endcase

    end

endmodule