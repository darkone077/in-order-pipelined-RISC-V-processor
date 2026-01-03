`timescale 1ns/1ps

module pc (
    input logic clk,
    input logic pc_src,
    input logic en_n,
    input logic rst,
    input logic [31:0]pc4,
    input logic [31:0]pcj,

    output logic [31:0]pc_nxt
);

    logic [31:0] pc;

    always_comb begin
        if (rst) begin
            pc=0;
        end

        else begin
            case(pc_src)
                1'b0:
                    pc=pc4;
                1'b1:
                    pc=pcj;
            endcase
        end
    end

    always @(posedge clk) begin
        
        if(~en_n) begin
            pc_nxt<=pc;
        end
        
    end
    
endmodule