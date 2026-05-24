`include "../src/axi4_if.sv"
`include "../src/ram.sv"
module ram_wrapper(
    //ram IO
    input  logic clk,
    input  logic rst_n,

    // Write Address Channel
    input  logic [31:0] axi_awaddr,
    input  logic axi_awvalid,
    output logic axi_awready,
    input  logic [2:0] axi_awprot,
    input  logic [3:0] axi_awid,
    input  logic [7:0] axi_awlen,
    input  logic [1:0] axi_awburst,
    input  logic [2:0] axi_awsize,
    input  logic [3:0] axi_awqos,
    input  logic [3:0] axi_awregion,
    input  logic [3:0] axi_awcache,
    input  logic axi_awlock,

    // Write Data Channel
    input  logic [31:0] axi_wdata,
    input  logic [3:0] axi_wstrb,
    input  logic axi_wlast,
    input  logic axi_wvalid,
    output logic axi_wready,

    // Write Response Channel
    output logic [3:0] axi_bid,
    output logic [1:0] axi_bresp,
    output logic axi_bvalid,
    input  logic axi_bready,

    // Read Address Channel
    input  logic [3:0] axi_arid,
    input  logic [31:0] axi_araddr,
    input  logic [7:0] axi_arlen,
    input  logic [2:0] axi_arsize,
    input  logic [1:0] axi_arburst,
    input  logic [3:0] axi_arcache,
    input  logic [2:0] axi_arprot,
    input  logic [3:0] axi_arqos,
    input  logic [3:0] axi_arregion,
    input  logic axi_arlock,
    input  logic axi_arvalid,
    output logic axi_arready,

    // Read Data Channel
    output logic [3:0] axi_rid,
    output logic [31:0] axi_rdata,
    output logic [1:0] axi_rresp,
    output logic axi_rlast,
    output logic axi_rvalid,
    input  logic axi_rready
);

    axi4_if axi_bus(clk,rst_n);

    //Wrt Addr
    assign axi_bus.AWID     = axi_awid;
    assign axi_bus.AWADDR   = axi_awaddr;
    assign axi_bus.AWLEN    = axi_awlen;
    assign axi_bus.AWSIZE   = axi_awsize;
    assign axi_bus.AWBURST  = axi_awburst;
    assign axi_bus.AWLOCK   = axi_awlock;
    /* verilator lint_off WIDTHTRUNC */
    assign axi_bus.AWPROT   = axi_awprot;
    assign axi_bus.AWQOS    = axi_awqos;
    assign axi_bus.AWVALID  = axi_awvalid;
    assign axi_awready      = axi_bus.AWREADY; 

    //Wrt Data
    assign axi_bus.WDATA    = axi_wdata;
    assign axi_bus.WSTRB    = axi_wstrb;
    assign axi_bus.WLAST    = axi_wlast;
    assign axi_bus.WVALID   = axi_wvalid;
    assign axi_wready       = axi_bus.WREADY;   

    //Wrt Resp
    assign axi_bid          = axi_bus.BID;
    assign axi_bresp        = axi_bus.BRESP;     
    assign axi_bvalid       = axi_bus.BVALID;   
    assign axi_bus.BREADY   = axi_bready;

    //Read Addr
    assign axi_bus.ARID     = axi_arid;
    assign axi_bus.ARADDR   = axi_araddr;
    assign axi_bus.ARLEN    = axi_arlen;
    assign axi_bus.ARSIZE   = axi_arsize;
    assign axi_bus.ARBURST  = axi_arburst;
    assign axi_bus.ARLOCK   = axi_arlock;
    assign axi_bus.ARPROT   = axi_arprot;
    assign axi_bus.ARQOS    = axi_arqos;
    assign axi_bus.ARVALID  = axi_arvalid;
    assign axi_arready      = axi_bus.ARREADY;

    //Read Data
    assign axi_rid          = axi_bus.RID;
    assign axi_rdata        = axi_bus.RDATA;     
    assign axi_rresp        = axi_bus.RRESP;
    assign axi_rlast        = axi_bus.RLAST;
    assign axi_rvalid       = axi_bus.RVALID;   
    assign axi_bus.RREADY   = axi_rready;

    ram RAM(axi_bus.SLAVE);
endmodule