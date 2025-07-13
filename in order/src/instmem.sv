module instmem #(
    parameter WORDS=64
) (
    input [31:0] mem_ad,
    output [31:0] red_dat
);
    logic [31:0] ROM [0:WORDS-1];
    assign red_dat=ROM[mem_ad[31:2]];

    
endmodule