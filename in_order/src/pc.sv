`timescale 1ns/1ps

module pc (
    input logic clk,
    input logic pc_src,
    input logic trap,
    input logic en_n,
    input logic rst,
    input logic [31:0]exception_pc,
    input logic [31:0]pc4,
    input logic [31:0]pcj,

    output logic [31:0]pc_nxt
);

    logic [31:0] pc;

    always_comb begin
        if (trap) begin
            pc=exception_pc;
        end
        else if (pc_src) begin
            pc=pcj;
        end
        else begin
            pc=pc4;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            pc_nxt<=32'b0;
        end
        else if(~en_n) begin
            pc_nxt<=pc;
        end
        
    end
    
endmodule