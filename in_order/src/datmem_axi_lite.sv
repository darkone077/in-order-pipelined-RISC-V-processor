//`include "../src/axi4-lite_if.sv"
module datmem_axi_lite(
    axi4_if.MASTER aim,
    input logic memWrt,
    input logic [31:0] memAd,
    input logic [31:0] wrtDat,
    input logic [3:0] strobe,
    input logic readEN,
    output logic [31:0] readDat,
    output logic error,busy
);

logic [31:0] addr,wdata,rdata;
logic aw_done,w_done;
logic [3:0] stb;
typedef enum logic [2:0] {IDLE,WRT_SEND,WRTRESP_RECIEVE,RADDR_SEND,RDATA_RECIEVE} type_state;
type_state state,next_state;

always_ff @(posedge aim.ACLK) begin
    if(~aim.ARSTN) begin
        state<=IDLE;

        addr<=32'b0;
        wdata<=32'b0;
        stb<=4'b0;
        aw_done<=1'b0;
        w_done<=1'b0;
    end

    else begin
        state<=next_state;
        if (state==IDLE&&(memWrt||readEN)) begin
            addr<={memAd[31:2],2'b00};
            wdata<=wrtDat;
            stb<=strobe;
            aw_done<=1'b0;
            w_done<=1'b0;
            
        end
        else if (state==WRT_SEND) begin
                if (aim.AWVALID&&aim.AWREADY) aw_done<=1'b1;
                if (aim.WVALID&&aim.WREADY)  w_done<=1'b1;
        end

        else if (state==RDATA_RECIEVE&&aim.RVALID) begin
            rdata<=aim.RDATA;
        end
        else begin
            aw_done<=1'b0;
            w_done<=1'b0;
        end
end
end

always_comb begin
    aim.WSTRB=stb;
    aim.AWADDR=addr;
    aim.WDATA=wdata;
    aim.ARADDR=addr;
    readDat=rdata;
    case (state)

        IDLE:begin
            aim.AWVALID=1'b0;
            aim.WVALID=1'b0;
            aim.BREADY=1'b0;
            aim.ARVALID=1'b0;
            aim.RREADY=1'b0;
            error=1'b0;
            
            if (memWrt) begin
                next_state=WRT_SEND;
                busy=1'b1;
            end
            else if (readEN) begin
                next_state=RADDR_SEND;
                busy=1'b1;
            end
            else begin
                next_state=IDLE;
                busy=1'b0;
            end
        end

        WRT_SEND:begin
            aim.AWVALID=~aw_done;
            aim.WVALID=~w_done;
            aim.BREADY=1'b1;
            aim.ARVALID=1'b0;
            aim.RREADY=1'b0;
            busy=1'b1;
            error=1'b0;
            if ((aw_done||(aim.AWVALID && aim.AWREADY))&&(w_done||(aim.WVALID&&aim.WREADY))) begin
                next_state=WRTRESP_RECIEVE;
            end
            else begin
                next_state=WRT_SEND;
            end
            
        end

        WRTRESP_RECIEVE:begin
            aim.AWVALID=1'b0;
            aim.WVALID=1'b0;
            aim.BREADY=1'b1;
            aim.ARVALID=1'b0;
            aim.RREADY=1'b0;
            
            if(aim.BVALID&&aim.BRESP!=2'b00) begin
                error=1'b1;
                next_state=IDLE;
                busy=1'b0;
            end
            else if (aim.BVALID) begin
                next_state=IDLE;
                error=1'b0;
                busy=1'b0;
            end    
            else begin
                next_state=WRTRESP_RECIEVE;
                error=1'b0;
                busy=1'b1;
            end
        end

        RADDR_SEND:begin
            aim.AWVALID=1'b0;
            aim.WVALID=1'b0;
            aim.BREADY=1'b0;
            aim.ARVALID=1'b1;
            aim.RREADY=1'b1;
            error=1'b0;
            busy=1'b1;
            if (aim.ARREADY) begin
                next_state=RDATA_RECIEVE;
            end
            else begin
                next_state=RADDR_SEND;
            end
            
        end

        RDATA_RECIEVE:begin
            aim.AWVALID=1'b0;
            aim.WVALID=1'b0;
            aim.BREADY=1'b0;
            aim.ARVALID=1'b0;
            aim.RREADY=1'b1;
    
            if (aim.RVALID&&aim.RRESP!=2'b00) begin
                error=1'b1;
                next_state=IDLE;
                busy=1'b0;
            end
            else if (aim.RVALID) begin
                error=1'b0;
                next_state=IDLE;
                busy=1'b0;
            end
            else begin
                error=1'b0;
                next_state=RDATA_RECIEVE;
                busy=1'b1;
            end
        end

        
        default: begin
            aim.AWVALID=1'b0;
            aim.WVALID=1'b0;
            aim.BREADY=1'b0;
            aim.ARVALID=1'b0;
            aim.RREADY=1'b0;
            error=1'b0;
            busy=1'b0;
            next_state=IDLE;
        end
    endcase
end
    
endmodule