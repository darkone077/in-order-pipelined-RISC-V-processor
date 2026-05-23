`include "../src/axi4_if.sv"
`include "../src/axi4-lite_if.sv"
`include "../src/cache.sv"
module cache_wrapper (
    //cache IO
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] pc,
    input  logic flush,
    output logic [31:0] inst,
    output logic busy,

    // Write Address Channel
    output logic [31:0] axi_awaddr,
    output logic axi_awvalid,
    input  logic axi_awready,
    output logic [2:0] axi_awprot,
    output logic [3:0] axi_awid,
    output logic [7:0] axi_awlen,
    output logic [1:0] axi_awburst,
    output logic [2:0] axi_awsize,
    output logic [3:0] axi_awqos,
    output logic [3:0] axi_awregion,
    output logic [3:0] axi_awcache,
    output logic axi_awlock,

    // Write Data Channel
    output logic [31:0] axi_wdata,
    output logic [3:0] axi_wstrb,
    output logic axi_wlast,
    output logic axi_wvalid,
    input  logic axi_wready,

    // Write Response Channel
    input  logic [3:0] axi_bid,
    input  logic [1:0] axi_bresp,
    input  logic axi_bvalid,
    output logic axi_bready,

    // Read Address Channel
    output logic [3:0] axi_arid,
    output logic [31:0] axi_araddr,
    output logic [7:0] axi_arlen,
    output logic [2:0] axi_arsize,
    output logic [1:0] axi_arburst,
    output logic [3:0] axi_arcache,
    output logic [2:0] axi_arprot,
    output logic [3:0] axi_arqos,
    output logic [3:0] axi_arregion,
    output logic axi_arlock,
    output logic axi_arvalid,
    input  logic axi_arready,

    // Read Data Channel
    input  logic [3:0] axi_rid,
    input  logic [31:0] axi_rdata,
    input  logic [1:0] axi_rresp,
    input  logic axi_rlast,
    input  logic axi_rvalid,
    output logic axi_rready,

    // AXI-Lite Write Address Channel
    input  logic [31:0] axil_awaddr,
    input  logic axil_awvalid,
    output logic axil_awready,
    input  logic [2:0] axil_awprot,

    // AXI-Lite Write Data Channel
    input  logic [31:0] axil_wdata,
    input  logic [3:0] axil_wstrb,
    input  logic axil_wvalid,
    output logic axil_wready,

    // AXI-Lite Write Response Channel
    output logic [1:0] axil_bresp,
    output logic axil_bvalid,
    input  logic axil_bready,

    // AXI-Lite Read Address Channel
    input  logic [31:0] axil_araddr,
    input  logic axil_arvalid,
    output logic axil_arready,
    input  logic [2:0] axil_arprot,

    // AXI-Lite Read Data Channel
    output logic [31:0] axil_rdata,
    output logic [1:0] axil_rresp,
    output logic axil_rvalid,
    input  logic axil_rready
);

    axi4_if axi_bus(clk,rst_n);
    axi4_lite_if axil_bus(clk,rst_n);

    //Wrt Addr
    assign axi_awid    = axi_bus.AWID;
    assign axi_awaddr  = axi_bus.AWADDR;
    assign axi_awlen   = axi_bus.AWLEN;
    assign axi_awsize  = axi_bus.AWSIZE;
    assign axi_awburst = axi_bus.AWBURST;
    assign axi_awlock  = axi_bus.AWLOCK;
    assign axi_awcache = 4'b0000;
    assign axi_awprot  = 3'b000;
    assign axi_awqos   = axi_bus.AWQOS;
    assign axi_awregion= 4'b0000;
    assign axi_awvalid = axi_bus.AWVALID;
    assign axi_bus.AWREADY = axi_awready; 

    //Wrt Data
    assign axi_wdata   = axi_bus.WDATA;
    assign axi_wstrb   = axi_bus.WSTRB;
    assign axi_wlast   = axi_bus.WLAST;
    assign axi_wvalid  = axi_bus.WVALID;
    assign axi_bus.WREADY = axi_wready;   

    //Wrt Resp
    assign axi_bus.BID    = axi_bid;
    assign axi_bus.BRESP  = axi_bresp;     
    assign axi_bus.BVALID = axi_bvalid;   
    assign axi_bready     = axi_bus.BREADY;

    //Read Addr
    assign axi_arid    = axi_bus.ARID;
    assign axi_araddr  = axi_bus.ARADDR;
    assign axi_arlen   = axi_bus.ARLEN;
    assign axi_arsize  = axi_bus.ARSIZE;
    assign axi_arburst = axi_bus.ARBURST;
    assign axi_arlock  = axi_bus.ARLOCK;
    assign axi_arcache = 4'b0000;
    assign axi_arprot  = 3'b000;
    assign axi_arqos   = axi_bus.ARQOS;
    assign axi_arregion= 4'b0000;
    assign axi_arvalid = axi_bus.ARVALID;
    assign axi_bus.ARREADY = axi_arready; 

    //Read Data
    assign axi_bus.RID    = axi_rid;
    assign axi_bus.RDATA  = axi_rdata;     
    assign axi_bus.RRESP  = axi_rresp;
    assign axi_bus.RLAST  = axi_rlast;
    assign axi_bus.RVALID = axi_rvalid;   
    assign axi_rready     = axi_bus.RREADY;

    // AXI-Lite Write Address
    assign axil_bus.AWADDR  = axil_awaddr;
    assign axil_bus.AWVALID = axil_awvalid;
    assign axil_awready     = axil_bus.AWREADY;

    // AXI-Lite Write Data
    assign axil_bus.WDATA   = axil_wdata;
    assign axil_bus.WSTRB   = axil_wstrb;
    assign axil_bus.WVALID  = axil_wvalid;
    assign axil_wready      = axil_bus.WREADY;

    // AXI-Lite Write Response
    assign axil_bresp       = axil_bus.BRESP;
    assign axil_bvalid      = axil_bus.BVALID;
    assign axil_bus.BREADY  = axil_bready;

    // AXI-Lite Read Address
    assign axil_bus.ARADDR  = axil_araddr;
    assign axil_bus.ARVALID = axil_arvalid;
    assign axil_arready     = axil_bus.ARREADY;

    // AXI-Lite Read Data
    assign axil_rdata       = axil_bus.RDATA;
    assign axil_rresp       = axil_bus.RRESP;
    assign axil_rvalid      = axil_bus.RVALID;
    assign axil_bus.RREADY  = axil_rready;

    cache CACHE(axi_bus.MASTER,axil_bus.SLAVE,pc,flush,inst,busy);
endmodule