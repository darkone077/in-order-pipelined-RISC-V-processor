interface axi4_if #(
    parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=32
)(
    input logic ACLK,
    input logic ARSTN

);
//wrt addr channel
logic AWVALID;
logic AWREADY;
logic [ADDR_WIDTH-1:0] AWADDR;

//wrt data channel
logic WVALID;
logic WREADY;
logic [DATA_WIDTH/8-1:0] WSTRB;
logic [DATA_WIDTH-1:0] WDATA;

//wrt resp channel
logic BVALID;
logic BREADY;
logic [1:0] BRESP;

//read addr channel
logic ARVALID;
logic ARREADY;
logic [ADDR_WIDTH-1:0] ARADDR;

//read data channel
logic RVALID;
logic RREADY;
logic [DATA_WIDTH-1:0] RDATA;
logic [1:0] RRESP;

modport MASTER(
    input ACLK,ARSTN,AWREADY,WREADY,BRESP,BVALID,ARREADY,RDATA,RRESP,RVALID,
    output AWVALID,AWADDR,WVALID,WDATA,WSTRB,BREADY,ARVALID,ARADDR,RREADY
);

modport SLAVE(
    output AWREADY,WREADY,BRESP,BVALID,ARREADY,RDATA,RRESP,RVALID,
    input ACLK,ARSTN,AWVALID,AWADDR,WVALID,WDATA,WSTRB,BREADY,ARVALID,ARADDR,RREADY
);
    
endinterface