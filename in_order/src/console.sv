module console(
    input logic clk,
    input logic [31:0] addr, 
    input logic [7:0] wrt_data,
    input logic wrt
);

always_ff@(posedge clk) begin
    if (wrt&addr==32'h10000000) begin
        $write("%c",wrt_data);
    end
end
    
endmodule