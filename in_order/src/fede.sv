module fede (
    input clk,
    input clr,
    input en_n,
    input [31:0] instrf,
    input [31:0] pc4f,
    input [31:0] pcf,
    
    output [31:0] instrd,
    output [31:0] pc4d,
    output [31:0] pcd
);

    always @(posedge clk) begin

        if(clr) begin 
            instrd<=0;
            pc4d<=0;
            pcf<=0; 
        end
        else if(~en_n) begin
            instrd<=instrf;
            pc4d<=pc4f;
            pcf<=pcf;
        end
    
    end
    
endmodule