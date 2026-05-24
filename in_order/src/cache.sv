module cache#(
    parameter INST_BYTES=2**12,
    parameter DATA_BYTES=2**14,
    parameter BLOCK_SIZE=64
) (
    axi4_if.MASTER aim,
    axi4_lite_if.SLAVE ais,
    input logic [31:0] pc,
    input logic flush,
    output logic [31:0] inst,
    output logic busy

);
typedef enum logic [1:0] {IDLE_C,DATA_LOAD,DATA_SAVE,INST_LOAD} cache_state_t;
cache_state_t cache_state,cache_state_nxt;

typedef enum logic [2:0] {IDLE_M,WRT_SEND,WRTRESP_RECIEVE,RADDR_SEND,RDATA_RECIEVE} master_state_t;
master_state_t master_state,master_state_nxt;

typedef enum logic [1:0] {IDLE_S,WRT_RECIEVE,WRTRESP_SEND,RDATA_SEND} slave_state_t;
slave_state_t slave_state,slave_state_nxt;

//INST CACHE
localparam INST_OFFSET_SIZE=$clog2(BLOCK_SIZE);
localparam INST_INDEX_SIZE=$clog2(INST_BYTES/BLOCK_SIZE/4);
localparam INST_TAG_SIZE=32-INST_INDEX_SIZE-INST_OFFSET_SIZE;

logic [3:0] inst_valid [0:2**INST_INDEX_SIZE-1];
logic [INST_TAG_SIZE-1:0] inst_tag [0:2**INST_INDEX_SIZE-1][0:3];
logic [31:0] inst_mem[0:2**INST_INDEX_SIZE-1][0:3][0:BLOCK_SIZE/4-1];
logic [4:0] inst_lru_track[0:2**INST_INDEX_SIZE-1];//4:nnLRU greater than MRU, 3 2:nLRU, 1 0:LRU
logic inst_exist;
logic [7:0] inst_track_unpacked;
logic [31:0] pc_buffer;

//DATA CACHE
localparam DATA_OFFSET_SIZE=$clog2(BLOCK_SIZE);
localparam DATA_INDEX_SIZE=$clog2(DATA_BYTES/BLOCK_SIZE/4);
localparam DATA_TAG_SIZE=32-DATA_INDEX_SIZE-DATA_OFFSET_SIZE;

logic [3:0] data_valid [0:2**DATA_INDEX_SIZE-1];
logic [3:0] data_dirty [0:2**DATA_INDEX_SIZE-1];
logic [DATA_TAG_SIZE-1:0] data_tag [0:2**DATA_INDEX_SIZE-1][0:3];
logic [31:0] data_mem[0:2**DATA_INDEX_SIZE-1][0:3][0:BLOCK_SIZE/4-1];
logic [4:0] data_lru_track[0:2**DATA_INDEX_SIZE-1];//4:nnLRU greater than MRU, 3 2:nLRU, 1 0:LRU
logic data_exist;
logic [1:0] flush_count;
logic flush_buffer;
logic [7:0] data_track_unpacked;
logic [31:0] addr,addr_buffer;
logic aw_done,w_done;
logic [31:0] data;


always_ff @(posedge aim.ACLK) begin
    if(~aim.ARSTN) begin
        cache_state<=IDLE_C;
        //INST CACHE
        for (int i=0;i<2**INST_INDEX_SIZE;i++) begin
            inst_lru_track[i]<=5'b00100;
        end
        inst_track_unpacked=8'b11100100;
        pc_buffer<=32'b0;
        for(int i=0;i<2**INST_INDEX_SIZE;i++)begin
            for (int j=0;j<4;j++) begin
                inst_tag[i][j]<={INST_TAG_SIZE{1'b0}};
            end
        end
        for (int i=0;i<2**INST_INDEX_SIZE;i++) begin
            inst_valid[i]<=4'b0000;
        end
        for (int i=0;i<2**INST_INDEX_SIZE;i++) begin
            for (int j=0;j<4;j++) begin
                for (int k=0;k<BLOCK_SIZE/4;k++) begin
                    inst_mem[i][j][k]<=32'b0;
                end
            end
        end

        //DATA CACHE
        for (int i=0;i<2**DATA_INDEX_SIZE;i++) begin
            data_lru_track[i]<=5'b00100;
        end
        data_track_unpacked=8'b11100100;
        addr_buffer<=32'b0;
        for(int i=0;i<2**DATA_INDEX_SIZE;i++)begin
            for (int j=0;j<4;j++) begin
                data_tag[i][j]<={DATA_TAG_SIZE{1'b0}};
            end
        end
        for (int i=0;i<2**DATA_INDEX_SIZE;i++) begin
            data_valid[i]<=4'b0000;
            data_dirty[i]<=4'b0000;
        end
        for (int i=0;i<2**DATA_INDEX_SIZE;i++) begin
            for (int j=0;j<4;j++) begin
                for (int k=0;k<BLOCK_SIZE/4;k++) begin
                    data_mem[i][j][k]<=32'b0;
                end
            end
        end

    end
    else begin
        cache_state<=cache_state_nxt;
        /* verilator lint_off CASEINCOMPLETE */
        
        case(cache_state)
            IDLE_C:begin

                //INST CACHE 
                for (int i=0;i<4;i++) begin
                    if(inst_valid[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][i])begin
                        /* verilator lint_off WIDTHEXPAND */
                        if(pc[(INST_OFFSET_SIZE+INST_INDEX_SIZE)+:INST_TAG_SIZE]==inst_tag[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][i]) begin
                            if(i==inst_track_unpacked[1:0])begin
                                        inst_lru_track[addr[INST_OFFSET_SIZE+:INST_INDEX_SIZE]]<={inst_track_unpacked[1:0]<inst_track_unpacked[7:6],inst_track_unpacked[5:4],inst_track_unpacked[3:2]};
                                    end
                            else if(i==inst_track_unpacked[3:2])begin
                                inst_lru_track[addr[INST_OFFSET_SIZE+:INST_INDEX_SIZE]]<={inst_track_unpacked[3:2]<inst_track_unpacked[7:6],inst_track_unpacked[5:4],inst_track_unpacked[1:0]};
                            end
                            else if(i==inst_track_unpacked[5:4])begin
                                inst_lru_track[addr[INST_OFFSET_SIZE+:INST_INDEX_SIZE]]<={inst_track_unpacked[5:4]<inst_track_unpacked[7:6],inst_track_unpacked[3:2],inst_track_unpacked[1:0]};
                            end
                            break;
                        end

                    end

                end

                if(~inst_exist)begin
                    pc_buffer<={pc[31:INST_OFFSET_SIZE],{INST_OFFSET_SIZE{1'b0}}};
                end

                for (int i=0;i<4;i++) begin
                    if(~inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][4])begin
                        /* verilator lint_off WIDTHEXPAND */
                        if((inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][1:0]!=i)&(inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][3:2]!=i))begin
                        /* verilator lint_off WIDTHEXPAND */
                            /* verilator lint_off WIDTHTRUNC */
                            inst_track_unpacked[5:4]<=i;
                            for (int j=i+1;j<4;j++) begin
                                if((inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][1:0]!=i)&(inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][3:2]!=i))begin
                                    inst_track_unpacked[7:6]<=j;
                                    break;
                                end
                            end
                            /* verilator lint_off WIDTHTRUNC */
                            break;
                        end

                    end
                    
                    else begin
                        if((inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][1:0]!=i)&(inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][3:2]!=i))begin
                            inst_track_unpacked[7:6]<=i;
                            for (int j=i+1;j<4;j++) begin
                                if((inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][1:0]!=j)&(inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][3:2]!=j))begin
                                    inst_track_unpacked[5:4]<=j;
                                    break;
                                end
                            end
                            break;
                        end
                    end
                end
                inst_track_unpacked[3:0]<=inst_lru_track[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][3:0];

                //DATA CACHE
                if (slave_state==WRTRESP_SEND|((slave_state==RDATA_SEND)&ais.RVALID)) begin
                        
                        for (int i=0;i<4;i++) begin
                            if(data_valid[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i])begin
                                if(addr[(DATA_OFFSET_SIZE+DATA_INDEX_SIZE)+:DATA_TAG_SIZE]==data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i]) begin
                                    if(i==data_track_unpacked[1:0])begin
                                        data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]]<={data_track_unpacked[1:0]<data_track_unpacked[7:6],data_track_unpacked[5:4],data_track_unpacked[3:2]};
                                    end
                                    else if(i==data_track_unpacked[3:2])begin
                                        data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]]<={data_track_unpacked[3:2]<data_track_unpacked[7:6],data_track_unpacked[5:4],data_track_unpacked[1:0]};
                                    end
                                    else if(i==data_track_unpacked[5:4])begin
                                        data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]]<={data_track_unpacked[5:4]<data_track_unpacked[7:6],data_track_unpacked[3:2],data_track_unpacked[1:0]};
                                    end
                                    
                                    break;
                                end
                            end
                        end
                        
                    end
                
                for (int i=0;i<4;i++) begin
                    if(~data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][4])begin
                        /* verilator lint_off WIDTHEXPAND */
                        if((data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]!=i)&(data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][3:2]!=i))begin
                        /* verilator lint_off WIDTHEXPAND */
                            /* verilator lint_off WIDTHTRUNC */
                            data_track_unpacked[5:4]<=i;
                            for (int j=i+1;j<4;j++) begin
                                if((data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]!=j)&(data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][3:2]!=j))begin
                                    data_track_unpacked[7:6]<=j;
                                    break;
                                end
                            end
                            /* verilator lint_off WIDTHTRUNC */
                            break;
                        end

                    end
                    else begin
                        if((data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]!=i)&(data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][3:2]!=i))begin
                            data_track_unpacked[7:6]<=i;
                            for (int j=i+1;j<4;j++) begin
                                if((data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]!=j)&(data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][3:2]!=j))begin
                                    data_track_unpacked[5:4]<=j;
                                    break;
                                end
                            end
                            break;
                        end
                    end
                end
                
                data_track_unpacked[3:0]<=data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][3:0];
            end

            DATA_SAVE:begin
                data_dirty[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]]<=1'b0;
            end

            DATA_LOAD:begin
                data_valid[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]]<=1'b1;
                data_dirty[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]]<=1'b0;
                data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]]<=addr[(DATA_OFFSET_SIZE+DATA_INDEX_SIZE)+:DATA_TAG_SIZE];
                data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]]<={data_track_unpacked[1:0]<data_track_unpacked[7:6],data_track_unpacked[5:4],data_track_unpacked[3:2]};
            end
            
            INST_LOAD:begin
                inst_valid[pc_buffer[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][inst_track_unpacked[1:0]]<=1'b1;
                inst_tag[pc_buffer[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][inst_track_unpacked[1:0]]<=pc_buffer[(INST_OFFSET_SIZE+INST_INDEX_SIZE)+:INST_TAG_SIZE];
                inst_lru_track[pc_buffer[INST_OFFSET_SIZE+:INST_INDEX_SIZE]]<={inst_track_unpacked[1:0]<inst_track_unpacked[7:6],inst_track_unpacked[5:4],inst_track_unpacked[3:2]};
            end
        endcase
        /* verilator lint_off CASEINCOMPLETE */
    end    
end

always_ff @(posedge aim.ACLK) begin
    if(~aim.ARSTN)begin
        master_state<=IDLE_M;
        w_done<=1'b0;
        aw_done<=1'b0;
    end
    else begin
        master_state<=master_state_nxt;
        /* verilator lint_off CASEINCOMPLETE */
        case (master_state)
            IDLE_M:begin
                //if (~data_exist) begin
                    if (ais.AWVALID) addr_buffer<={data_tag[ais.AWADDR[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_lru_track[ais.AWADDR[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]],ais.AWADDR[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE],{DATA_OFFSET_SIZE{1'b0}}};
                    else if (ais.ARVALID) addr_buffer<={data_tag[ais.ARADDR[31:DATA_OFFSET_SIZE]][data_lru_track[ais.ARADDR[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]],ais.ARADDR[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE],{DATA_OFFSET_SIZE{1'b0}}};
                //end
            end
            WRT_SEND:begin
                if(aim.AWREADY) aw_done<=1'b1;
                if(addr_buffer==({data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]],addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE],{DATA_OFFSET_SIZE{1'b0}}}+BLOCK_SIZE-4)) w_done<=1'b1;
                //if(w_done&~aim.WLAST)w_done<=1'b0;

                if(aim.WREADY&aim.WVALID)begin
                    addr_buffer<=addr_buffer+4;
                end
            end
            WRTRESP_RECIEVE:begin
                addr_buffer<=addr;
            end
            RDATA_RECIEVE:begin
                if(aim.RVALID&(aim.RRESP==2'b00))begin
                    if(cache_state==INST_LOAD)begin
                        pc_buffer<=pc_buffer+4;
                        inst_mem[pc_buffer[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][inst_track_unpacked[1:0]][pc_buffer[2+:(INST_OFFSET_SIZE-2)]]<=aim.RDATA;
                        addr_buffer<={data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]],addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE],{DATA_OFFSET_SIZE{1'b0}}};
                    end
                    else begin
                        addr_buffer<=addr_buffer+4;
                        data_mem[addr_buffer[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]][addr_buffer[2+:(DATA_OFFSET_SIZE-2)]]<=aim.RDATA;
                    end
                end
            end
            default:begin
                aw_done<=1'b0;
                w_done<=1'b0;
            end
        endcase
        /* verilator lint_off CASEINCOMPLETE */
    end
end

always_ff @(posedge aim.ACLK) begin
    if (~aim.ARSTN) begin
        slave_state<=IDLE_S;
        addr<=32'b0;
    end
    else begin
        slave_state<=slave_state_nxt;
        case (slave_state)
            IDLE_S:begin
                if (ais.AWVALID) addr<=ais.AWADDR;
                else if (ais.ARVALID) addr<=ais.ARADDR;
            end

            WRT_RECIEVE:begin
                if (ais.WVALID) begin
                    for (int i=0;i<4;i++) begin
                        if(data_valid[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i])begin

                            if(addr[(DATA_OFFSET_SIZE+DATA_INDEX_SIZE)+:DATA_TAG_SIZE]==data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i]) begin
                                data_mem[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i][addr[2+:(DATA_OFFSET_SIZE-2)]]<={{ais.WSTRB[3]}?ais.WDATA[31:24]:data_mem[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i][addr[2+:(DATA_OFFSET_SIZE-2)]][31:24],{ais.WSTRB[2]}?ais.WDATA[23:16]:data_mem[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i][addr[2+:(DATA_OFFSET_SIZE-2)]][23:16],{ais.WSTRB[1]}?ais.WDATA[15:8]:data_mem[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i][addr[2+:(DATA_OFFSET_SIZE-2)]][15:8],{ais.WSTRB[0]}?ais.WDATA[7:0]:data_mem[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i][addr[2+:(DATA_OFFSET_SIZE-2)]][7:0]};
                                data_dirty[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i]<=1'b1;
                                //data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]]<={i>data_track_unpacked[7:6],}
                                break;
                            end
                        end 
                    end 
                end
            end
        endcase
    end

end
always_comb begin
    inst_exist=1'b1;
    data=32'b0;
    data_exist=1'b1;
    for (int i=0;i<4;i++) begin
        if(data_valid[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i])begin
            if(addr[(DATA_OFFSET_SIZE+DATA_INDEX_SIZE)+:DATA_TAG_SIZE]==data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i]) begin
                data=data_mem[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i][addr[2+:(DATA_OFFSET_SIZE-2)]];
                break;
            end
        end
    end
    
    inst=32'b0;
    /* verilator lint_off CASEINCOMPLETE */
    case (cache_state)
        IDLE_C:begin 

            for (int i=0;i<4;i++) begin
                    if(inst_valid[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][i])begin

                        if(pc[(INST_OFFSET_SIZE+INST_INDEX_SIZE)+:INST_TAG_SIZE]==inst_tag[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][i]) begin
                            inst_exist=1'b1; 
                            inst=inst_mem[pc[INST_OFFSET_SIZE+:INST_INDEX_SIZE]][i][pc[2+:(INST_OFFSET_SIZE-2)]];
                            break;
                        end

                        else begin
                            inst_exist=1'b0;
                        end
                    end
                    else begin
                        inst_exist=1'b0;
                    end
                end
            if(slave_state==RDATA_SEND|slave_state==WRT_SEND)begin
                for (int i=0;i<4;i++) begin
                    if(data_valid[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i])begin
                        if(addr[(DATA_OFFSET_SIZE+DATA_INDEX_SIZE)+:DATA_TAG_SIZE]==data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i]) begin
                            data_exist=1'b1; 
                            break;
                        end

                        else begin
                            data_exist=1'b0;
                        end
                    end
                    else begin
                        data_exist=1'b0;
                    end
                end
            end
            /*else begin
                data_exist=1'b1;
            end*/

            if(~inst_exist)begin
                cache_state_nxt=INST_LOAD;
            end
            else if (~data_exist) begin
                if (data_dirty[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]]) begin
                    cache_state_nxt=DATA_SAVE;
                end
                else begin
                    cache_state_nxt=DATA_LOAD;
                end
            end

            else begin
                cache_state_nxt=IDLE_C;
            end
        end
        
        DATA_SAVE:begin
            data_exist=1'b0;
           if (addr_buffer==({data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]],addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE],{DATA_OFFSET_SIZE{1'b0}}}+BLOCK_SIZE-4)) begin
            cache_state_nxt=DATA_LOAD;
           end 
           else begin
            cache_state_nxt=DATA_SAVE;
           end
        end

        DATA_LOAD:begin
            data_exist=1'b0;
            if (aim.RLAST&(master_state==RDATA_RECIEVE)&aim.RVALID) begin
                cache_state_nxt=IDLE_C;
            end
            else begin
                cache_state_nxt=DATA_LOAD;
            end
        end

        INST_LOAD:begin
            if(slave_state==RDATA_SEND|slave_state==WRT_RECIEVE)begin
                for (int i=0;i<4;i++) begin
                    if(data_valid[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i])begin
                        if(addr[(DATA_OFFSET_SIZE+DATA_INDEX_SIZE)+:DATA_TAG_SIZE]==data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][i]) begin
                            data_exist=1'b1;
                            break;
                        end

                        else begin
                            data_exist=1'b0;
                        end
                    end
                    else begin
                        data_exist=1'b0;
                    end
                end
            end

            if (aim.RLAST&(master_state==RDATA_RECIEVE)&aim.RVALID) begin
                if (data_exist) begin
                    cache_state_nxt=IDLE_C;
                end
                else begin
                    if (data_dirty[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]]) begin
                    cache_state_nxt=DATA_SAVE;
                    end
                    else begin
                        cache_state_nxt=DATA_LOAD;
                    end
                end
            end
            else begin
                cache_state_nxt=INST_LOAD;
            end
        end
    endcase
    /* verilator lint_off CASEINCOMPLETE */
end

always_comb begin
    aim.AWVALID=1'b0;
    aim.AWADDR={data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]],addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE],{DATA_OFFSET_SIZE{1'b0}}};
    aim.AWID=4'b0000;
    aim.AWLEN=BLOCK_SIZE/4-1;
    aim.AWSIZE=3'b010;
    aim.AWBURST=2'b01;
    aim.AWLOCK=1'b0;
    aim.AWPROT=2'b00;
    aim.AWQOS=4'b0000;
    
    aim.WVALID=1'b0;
    aim.WDATA=data_mem[addr_buffer[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]][addr_buffer[2+:(DATA_OFFSET_SIZE-2)]];
    aim.WSTRB=4'b1111;
    aim.WLAST=1'b1;

    aim.BREADY=1'b0;
    
    aim.ARVALID=1'b0;
    aim.ARADDR=32'bx;
    aim.ARID=4'b0000;
    aim.ARLEN=BLOCK_SIZE/4-1;
    aim.ARSIZE=3'b010;
    aim.ARBURST=2'b01;
    aim.ARLOCK=1'b0;
    aim.ARPROT=2'b00;
    aim.ARQOS=4'b0000;

    aim.RREADY=1'b0;
    
    busy=1'b0;
    case (master_state)
        /* verilator lint_off CASEINCOMPLETE */
        IDLE_M:begin
            if (cache_state==IDLE_C) begin
                if(~inst_exist)begin
                    master_state_nxt=RADDR_SEND;
                    busy=1'b1;
                end
                else if(~data_exist)begin
                    busy=1'b1;
                    if (data_dirty[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_lru_track[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][1:0]]) begin
                        master_state_nxt=WRT_SEND;
                    end
                    else begin
                        master_state_nxt=RADDR_SEND;
                    end
                end
                else begin
                    master_state_nxt=IDLE_M;
                    busy=1'b0;
                end
            end
            else begin
                master_state_nxt=IDLE_M;
                busy=1'b0;
            end
            
        end

        WRT_SEND:begin
            busy=1'b1;
            aim.AWVALID=~aw_done;
            aim.WVALID=~w_done;
            if (addr_buffer==({data_tag[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]],addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE],{DATA_OFFSET_SIZE{1'b0}}}+BLOCK_SIZE-4)) begin
                aim.WLAST=1'b1;
                master_state_nxt=WRTRESP_RECIEVE;
            end
            else begin
                aim.WLAST=1'b0;
                master_state_nxt=WRT_SEND;
            end

        end

        WRTRESP_RECIEVE:begin
            busy=1'b1;
            aim.BREADY=1'b1;
            if ((aim.BRESP==2'b00)&aim.BVALID) begin
                master_state_nxt=RADDR_SEND;
            end
            else begin
                master_state_nxt=WRTRESP_RECIEVE;
            end
        end

        RADDR_SEND:begin
            busy=1'b1;
            aim.ARVALID=1'b1;
            if (cache_state==INST_LOAD) begin
                aim.ARADDR={pc[31:INST_OFFSET_SIZE],{INST_OFFSET_SIZE{1'b0}}};
            end
            else if (cache_state==DATA_LOAD) begin
               aim.ARADDR={addr[31:DATA_OFFSET_SIZE],{DATA_OFFSET_SIZE{1'b0}}};
            end
            aim.ARLOCK=1'b1;

            if(aim.ARREADY)begin
                master_state_nxt=RDATA_RECIEVE;
            end
            else begin
                master_state_nxt=RADDR_SEND;
            end
        end

        RDATA_RECIEVE:begin
            aim.RREADY=1'b1;

            if(aim.RLAST&aim.RVALID)begin
                if (cache_state==INST_LOAD) begin
                    if (~data_exist) begin
                        busy=1'b1;
                        if (data_dirty[addr[DATA_OFFSET_SIZE+:DATA_INDEX_SIZE]][data_track_unpacked[1:0]]) begin
                            master_state_nxt=WRT_SEND;
                        end
                        else begin
                            master_state_nxt=RADDR_SEND;
                        end
                    end
                    else begin
                        master_state_nxt=IDLE_M;
                        busy=1'b1;
                    end
                end
                else begin
                    master_state_nxt=IDLE_M;
                    busy=1'b1;
                end
                
            end
            else begin
                master_state_nxt=RDATA_RECIEVE;
                busy=1'b1;
            end

        end
    endcase
    /* verilator lint_off CASEINCOMPLETE */
end

always_comb begin
    ais.AWREADY=1'b1;

    ais.WREADY=1'b0;
    
    ais.BRESP=2'b00;
    ais.BVALID=1'b0;
    
    ais.ARREADY=1'b1;
    
    ais.RDATA=32'bx;
    ais.RRESP=2'b00;
    ais.RVALID=1'b0;

    case (slave_state)
        IDLE_S:begin
            if (ais.AWVALID) begin
                slave_state_nxt=WRT_RECIEVE;
            end
            else if (ais.ARVALID) begin
                slave_state_nxt=RDATA_SEND;
            end
            else begin
                slave_state_nxt=IDLE_S;
            end
        end

        WRT_RECIEVE:begin
            ais.WREADY=data_exist;
            ais.AWREADY=1'b0;
            ais.ARREADY=1'b0;
            
            if (ais.WREADY&ais.WVALID) begin
                slave_state_nxt=WRTRESP_SEND;
            end
            else begin
                slave_state_nxt=WRT_RECIEVE;
            end
            
        end

        WRTRESP_SEND:begin
            ais.AWREADY=1'b0;
            ais.ARREADY=1'b0;
            ais.BVALID=1'b1;
            
            slave_state_nxt=IDLE_S;
        end

        RDATA_SEND:begin
            ais.AWREADY=1'b0;
            ais.ARREADY=1'b0;
            ais.RVALID=data_exist;
            ais.RDATA=data;
            
            if(ais.RVALID) slave_state_nxt=IDLE_S;
            else slave_state_nxt=RDATA_SEND;
        end
    endcase
end
endmodule