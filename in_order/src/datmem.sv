module datmem #(
    parameter WORDS = 64;
)(

    input logic clk,
    input logic [31:0] mem_ad,
    input logic [31:0] writ_dat,
    output logic [31:0] red_dat,

    input logic mem_wrt,
    input logic rst 
);

    reg [31:0] mem [0:WORDS-1];
    int i;

    always @(posedge clk) begin
        if(rst) begin
            for(i=0;i<WORDS;i=i+1) begin 
                mem[i]<=32'b0;
                red_dat<=32'bx;

            end

        end

        else begin 
            if(mem_wrt) begin
                mem[mem_ad[31:2]]<=writ_dat;
                red_dat<=32'bx;
            end
            else begin
                red_dat<=mem[mem_ad[31:2]];


             end



        end

        
    end


    
    
endmodule