module pcadd (
    input [31:0] pc_curr,

    output [31:0] pc4
);
    assign pc4=pc_curr+4;
endmodule