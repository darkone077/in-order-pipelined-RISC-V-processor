//`include "../src/datmem_axi-lite.sv"
//`include "../src/axi4-lite_if.sv"
`include "../src/top.sv"
module axi_wrapper (
    //datmem IO
    input  logic clk,
    input  logic rst_n,
    output logic axi_error,
    output logic [31:0] pcf,pcj,

    // Write Address Channel
    output logic [31:0] axi_awaddr,
    output logic axi_awvalid,
    input  logic axi_awready,
    output logic [2:0] axi_awprot,

    // Write Data Channel
    output logic [31:0] axi_wdata,
    output logic [3:0] axi_wstrb,
    output logic axi_wvalid,
    input  logic axi_wready,

    // Write Response Channel
    input  logic [1:0] axi_bresp,
    input  logic axi_bvalid,
    output logic axi_bready,

    // Read Address Channel
    output logic [31:0] axi_araddr,
    output logic axi_arvalid,
    input  logic axi_arready,
    output logic [2:0] axi_arprot,

    // Read Data Channel
    input  logic [31:0] axi_rdata,
    input  logic [1:0] axi_rresp,
    input  logic axi_rvalid,
    output logic axi_rready
);

    axi4_if axi_bus(clk,rst_n);

    //Wrt Addr
    assign axi_awaddr  = axi_bus.AWADDR;
    assign axi_awvalid = axi_bus.AWVALID;
    assign axi_bus.AWREADY = axi_awready; 
    assign axi_awprot  = 3'b000;

    //Wrt Data
    assign axi_wdata   = axi_bus.WDATA;
    assign axi_wstrb   = axi_bus.WSTRB;
    assign axi_wvalid  = axi_bus.WVALID;
    assign axi_bus.WREADY = axi_wready;   

    //Wrt Resp
    assign axi_bus.BRESP = axi_bresp;     
    assign axi_bus.BVALID = axi_bvalid;   
    assign axi_bready  = axi_bus.BREADY;

    //Read Addr
    assign axi_araddr  = axi_bus.ARADDR;
    assign axi_arvalid = axi_bus.ARVALID;
    assign axi_bus.ARREADY = axi_arready; 
    assign axi_arprot  = 3'b000;

    //Read Data
    assign axi_bus.RDATA = axi_rdata;     
    assign axi_bus.RRESP = axi_rresp;     
    assign axi_bus.RVALID = axi_rvalid;   
    assign axi_rready  = axi_bus.RREADY;

    top RV32IM(clk,~rst_n,axi_error,pcf,pcj,axi_bus.MASTER);
endmodule