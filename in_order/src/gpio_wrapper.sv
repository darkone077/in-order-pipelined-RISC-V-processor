`include "../src/gpio.sv"
module gpio_wrapper(
    //GPIO IO
    input  logic clk,
    input  logic rst_n,
    output logic [3:0] read,wrt,
    output logic [31:0] addr,
    input logic [31:0] read_data [0:3],
    output logic [31:0] wrt_data [0:3],

    // Write Address Channel
    input logic [31:0] axi_awaddr,
    input logic axi_awvalid,
    output  logic axi_awready,

    // Write Data Channel
    input logic [31:0] axi_wdata,
    input logic [3:0] axi_wstrb,
    input logic axi_wvalid,
    output  logic axi_wready,

    // Write Response Channel
    output  logic [1:0] axi_bresp,
    output  logic axi_bvalid,
    input logic axi_bready,

    // Read Address Channel
    input logic [31:0] axi_araddr,
    input logic axi_arvalid,
    output  logic axi_arready,

    // Read Data Channel
    output  logic [31:0] axi_rdata,
    output  logic [1:0] axi_rresp,
    output  logic axi_rvalid,
    input logic axi_rready
);
    axi4_lite_if axi_bus(clk,rst_n);

    //Wrt Addr
    assign axi_bus.AWADDR = axi_awaddr;
    assign axi_bus.AWVALID = axi_awvalid;
    assign axi_awready = axi_bus.AWREADY; 

    //Wrt Data
    assign axi_bus.WDATA   = axi_wdata;
    assign axi_bus.WSTRB   = axi_wstrb;
    assign axi_bus.WVALID  = axi_wvalid;
    assign axi_wready = axi_bus.WREADY;   

    //Wrt Resp
    assign axi_bresp = axi_bus.BRESP;     
    assign axi_bvalid = axi_bus.BVALID;   
    assign axi_bus.BREADY  = axi_bready;

    //Read Addr
    assign axi_bus.ARADDR= axi_araddr;
    assign axi_bus.ARVALID = axi_arvalid;
    assign axi_arready = axi_bus.ARREADY;

    //Read Data
    assign axi_rdata = axi_bus.RDATA;     
    assign axi_rresp = axi_bus.RRESP;     
    assign axi_rvalid = axi_bus.RVALID;   
    assign axi_bus.RREADY = axi_rready;

    gpio GPIO(axi_bus.SLAVE,read,wrt,addr,read_data,wrt_data);
    
endmodule