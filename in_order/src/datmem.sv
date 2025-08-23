`timescale 1ns/1ps

module datmem #(
    parameter WORDS = 256
)(
    input logic clk,
    input logic [31:0] mem_ad,
    input logic [31:0] wrtDat,
    output logic [31:0] redDat,

    input logic memWrt,
    input logic rst 
);

    logic [31:0] mem [0:WORDS-1];
    int i;

    always_ff @(posedge clk) begin
        if(rst) begin
            for(i=0;i<WORDS;i=i+1) begin 
                mem[i]<=32'b0;

            end
        end

        else begin 
            if(memWrt) begin
                /* verilator lint_off WIDTHTRUNC */
                mem[mem_ad[31:2]]<=wrtDat;
            end
        end       
    end

    always_comb begin
        redDat=mem[mem_ad[31:2]];
    end
    
endmodule