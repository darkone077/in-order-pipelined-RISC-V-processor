module regfile (
    input clk,
    input rst_n,

    input [4:0] ad1,
    input [4:0] ad2,

    input [4:0] ad3,
    input [31:0] wd3,
    input we3,

    output [31:0] rd1,
    output [31:0] rd2
);

    reg [31:0] register [0:31];
    
    always @(negedge clk) begin
        if(~rst_n) begin 
            for(int i=0;i<32;i=i+1) register[i]<=32'b0;

        end
        else if(we3&&ad3) register[ad3]<=we3;
        
    end
    
    always_comb begin : read

        rd1<=register[ad1];
        rd2<=register[ad2];
        
    end

    
endmodule