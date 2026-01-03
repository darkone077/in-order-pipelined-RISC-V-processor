`include "../tb/axi_wrapper.sv"
module axi_verilog_wrapper(
    input  wire clk,
    input  wire rst_n,
    output wire axi_error,
    output wire [31:0] pcf,
    output wire [31:0] pcj,

    // Write Address Channel
    output wire [31:0] axi_awaddr,
    output wire axi_awvalid,
    input  wire axi_awready,
    output wire [2:0] axi_awprot,

    // Write Data Channel
    output wire [31:0] axi_wdata,
    output wire [3:0] axi_wstrb,
    output wire axi_wvalid,
    input  wire axi_wready,

    // Write Response Channel
    input  wire [1:0] axi_bresp,
    input  wire axi_bvalid,
    output wire axi_bready,

    // Read Address Channel
    output wire [31:0] axi_araddr,
    output wire axi_arvalid,
    input  wire axi_arready,
    output wire [2:0] axi_arprot,

    // Read Data Channel
    input  wire [31:0] axi_rdata,
    input  wire [1:0] axi_rresp,
    input  wire axi_rvalid,
    output wire axi_rready
    );
    axi_wrapper CPU (
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // Simple Interface (CPU side)
        .axi_error(axi_error),
        .pcf(pcf),
        .pcj(pcj),

        // AXI Write Address
        .axi_awaddr(axi_awaddr),
        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),
        .axi_awprot(axi_awprot),

        // AXI Write Data
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),

        // AXI Write Response
        .axi_bresp(axi_bresp),
        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready),

        // AXI Read Address
        .axi_araddr(axi_araddr),
        .axi_arvalid(axi_arvalid),
        .axi_arready(axi_arready),
        .axi_arprot(axi_arprot),

        // AXI Read Data
        .axi_rdata(axi_rdata),
        .axi_rresp(axi_rresp),
        .axi_rvalid(axi_rvalid),
        .axi_rready(axi_rready)
    );
endmodule