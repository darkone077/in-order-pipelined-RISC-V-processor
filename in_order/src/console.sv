module console(
    input logic clk,
    input logic [31:0] addr, 
    input logic [7:0] wrt_data,
    output logic [7:0] read_data,
    input logic wrt,
    input logic read,
    input logic in_wrt,
    input logic [7:0] in_data 
);
logic written;
logic [7:0] ip_data;
always_ff@(posedge clk) begin
    if (in_wrt) begin
        ip_data<=in_data;
        written<=1'b1;
    end
    else if(read&addr==32'h10000004)begin
        written<=1'b0;
        read_data<=ip_data;
    end
    if (wrt&addr==32'h10000000) begin
        $write("%c",wrt_data);
    end
    if (read&addr==32'h10000008) begin
        read_data<={7'b0,written};
    end
end
    
endmodule