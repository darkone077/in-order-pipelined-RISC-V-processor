module pc (
    input clk,
    input pc_src,
    input [31:0]pc4,
    input [31:0]pcj

    output [31:0]pc_now
);

    always @(posedge clk) begin

        if(pc_src) pc_now<=pcj;
        else pc_now<=pc4;
        
    end
    
endmodule