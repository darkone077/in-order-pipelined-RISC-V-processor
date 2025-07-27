module pc (
    input clk,
    input pc_src,
    input en_n,
    input [31:0]pc4,
    input [31:0]pcj

    output [31:0]pc_nxt
);

    always @(posedge clk) begin

        if(~en_n) begin
            if(pc_src) pc_nxt<=pcj;
            else pc_nxt<=pc4;
        end
        
    end
    
endmodule