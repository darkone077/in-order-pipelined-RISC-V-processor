`include "../src/axi4_if.sv"
`include "../src/axi4-lite_if.sv"
`include "../src/cache_io.sv"
module cache_io_wrapper (
    //cache IO
    input  logic clk,
    input  logic rst_n,
    input logic [31:0] pc,
    input logic [31:0] mem_ad,
    input logic read,wrt,
    input logic flush,
    input logic [3:0] wrt_stb,
    output logic [31:0] inst,
    output logic [31:0] read_data,
    input logic [31:0] wrt_data,
    output logic busy,axi_busy,

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

    // Write Address Channel
    output logic [31:0] axil_awaddr,
    output logic axil_awvalid,
    input  logic axil_awready,
    output logic [2:0] axil_awprot,

    // Write Data Channel
    output logic [31:0] axil_wdata,
    output logic [3:0] axil_wstrb,
    output logic axil_wvalid,
    input  logic axil_wready,

    // Write Response Channel
    input  logic [1:0] axil_bresp,
    input  logic axil_bvalid,
    output logic axil_bready,

    // Read Address Channel
    output logic [31:0] axil_araddr,
    output logic axil_arvalid,
    input  logic axil_arready,
    output logic [2:0] axil_arprot,

    // Read Data Channel
    input  logic [31:0] axil_rdata,
    input  logic [1:0] axil_rresp,
    input  logic axil_rvalid,
    output logic axil_rready
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

    //Wrt Addr
    assign axil_awaddr  = axil_bus.AWADDR;
    assign axil_awvalid = axil_bus.AWVALID;
    assign axil_bus.AWREADY = axil_awready; 
    assign axil_awprot  = 3'b000;

    //Wrt Data
    assign axil_wdata   = axil_bus.WDATA;
    assign axil_wstrb   = axil_bus.WSTRB;
    assign axil_wvalid  = axil_bus.WVALID;
    assign axil_bus.WREADY = axil_wready;   

    //Wrt Resp
    assign axil_bus.BRESP = axil_bresp;     
    assign axil_bus.BVALID = axil_bvalid;   
    assign axil_bready  = axil_bus.BREADY;

    //Read Addr
    assign axil_araddr  = axil_bus.ARADDR;
    assign axil_arvalid = axil_bus.ARVALID;
    assign axil_bus.ARREADY = axil_arready; 
    assign axil_arprot  = 3'b000;

    //Read Data
    assign axil_bus.RDATA = axil_rdata;     
    assign axil_bus.RRESP = axil_rresp;     
    assign axil_bus.RVALID = axil_rvalid;   
    assign axil_rready  = axil_bus.RREADY;

    cache_io CACHE(axi_bus.MASTER,axil_bus.MASTER,pc,mem_ad,read,wrt,flush,wrt_stb,inst,read_data,wrt_data,busy,axi_busy);
endmodule