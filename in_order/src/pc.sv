`timescale 1ns/1ps

module pc (
    input logic clk,
    input logic pc_src,
    input logic en_n,
    input logic [31:0]pc4,
    input logic [31:0]pcj,

    output logic [31:0]pc_nxt
);

    always @(posedge clk) begin

        if(~en_n) begin
            if(pc_src) pc_nxt<=pcj;
            else pc_nxt<=pc4;
        end
        
    end
    
endmodule