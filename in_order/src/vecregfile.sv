module vecregfile #(
    parameter ELEN=32,
    parameter VLEN=64
) (
    input logic clk,rst,wrten,
    input logic [4:0] addr1,addr2,addr3,
    input logic [ELEN-1:0] v3dat [0:VLEN-1],
    output logic [ELEN-1:0] v1 [0:VLEN-1],
    output logic [ELEN-1:0] v2 [0:VLEN-1]
);

    logic [ELEN-1:0] REGISTERS [0:VLEN-1][0:31];

    always@(posedge clk) begin
        if(rst) 
            for(int i=0;i<VLEN;++i)
                for(int j=0;j<32;++j)
                    REGISTERS[i][j]<=32'h0000;
        else if (wrten) 
            for(int i=0;i<VLEN;++i)
                REGISTERS[i][addr3]<=v3dat[i];
        
     end

    always_comb begin
        for(int i=0;i<VLEN;++i) begin
            v1[i]=REGISTERS[i][addr1];
            v2[i]=REGISTERS[i][addr2];
        end
    end
    
endmodule