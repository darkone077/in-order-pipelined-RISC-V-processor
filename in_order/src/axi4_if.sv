`ifndef AXI4_IF
`define AXI4_IF


interface axi4_if #(
    parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=32,
    parameter ID_WDITH=4
)(
    input logic ACLK,
    input logic ARSTN

);
//wrt addr channel
logic [ID_WDITH-1:0] AWID;
logic AWVALID;
logic AWREADY;
logic [ADDR_WIDTH-1:0] AWADDR;
logic [7:0] AWLEN;
logic [2:0] AWSIZE;
logic [1:0] AWBURST;
logic [3:0] AWQOS;
logic AWLOCK;
logic [1:0] AWPROT;

//wrt data channel
logic WLAST;
logic WVALID;
logic WREADY;
logic [DATA_WIDTH/8-1:0] WSTRB;
logic [DATA_WIDTH-1:0] WDATA;

//wrt resp channel
logic [ID_WDITH-1:0] BID;
logic BVALID;
logic BREADY;
logic [1:0] BRESP;

//read addr channel
logic [ID_WDITH-1:0] ARID;
logic ARVALID;
logic ARREADY;
logic [ADDR_WIDTH-1:0] ARADDR;
logic [7:0] ARLEN;
logic [2:0] ARSIZE;
logic [1:0] ARBURST;
logic ARLOCK;
logic [1:0] ARPROT;
logic [3:0] ARQOS;

//read data channel
logic [ID_WDITH-1:0] RID;
logic RVALID;
logic RREADY;
logic [DATA_WIDTH-1:0] RDATA;
logic [1:0] RRESP;
logic RLAST;

modport MASTER(
    input ACLK,ARSTN,AWREADY,WREADY,BRESP,BVALID,BID,ARREADY,RDATA,RRESP,RVALID,RID,RLAST,
    output AWVALID,AWADDR,AWID,AWLEN,AWSIZE,AWBURST,AWLOCK,AWPROT,AWQOS,WVALID,WDATA,WSTRB,WLAST,BREADY,ARVALID,ARADDR,ARID,ARLEN,ARSIZE,ARBURST,ARLOCK,ARPROT,ARQOS,RREADY
);

modport SLAVE(
    output AWREADY,WREADY,BRESP,BVALID,BID,ARREADY,RDATA,RRESP,RVALID,RID,RLAST,
    input ACLK,ARSTN,AWVALID,AWADDR,AWID,AWLEN,AWSIZE,AWBURST,AWLOCK,AWPROT,AWQOS,WVALID,WDATA,WSTRB,WLAST,BREADY,ARVALID,ARADDR,ARID,ARLEN,ARSIZE,ARBURST,ARLOCK,ARPROT,ARQOS,RREADY
);
    
endinterface

`endif