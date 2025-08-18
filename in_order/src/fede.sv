`timescale 1ns/1ps

module fede (
    input logic clk,
    input logic clr,
    input logic en_n,
    input logic [31:0] instrf,
    input logic [31:0] pc4f,
    input logic [31:0] pcf,
    
    output logic [31:0] instrd,
    output logic [31:0] pc4d,
    output logic [31:0] pcd
);

    always_ff @(posedge clk) begin

        if(clr) begin 
            instrd<=32'b0;
            pc4d<=32'b0;
            pcd<=32'b0; 
        end
        else if(~en_n) begin
            instrd<=instrf;
            pc4d<=pc4f;
            pcd<=pcf;
        end
    
    end
    
endmodule