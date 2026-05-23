`include "../src/axi_wrapper.sv"
`include "../src/clint_wrapper.sv"
`include "../src/datram_wrapper.sv"
module sim_wrapper#(
    parameter BASE = 32'h200000
)(
    input logic clk,rst_n,
    output logic axi_error,timerIrq,softIrq,
    output logic [31:0] pcf,pcj
);

    axi4_lite_if axiBus(clk,rst_n);
    
    // Write Address Channel
    logic [31:0] axi_awaddr;
    logic axi_awvalid;
    logic axi_awready;
    logic [2:0] axi_awprot;

    // Write Data Channel
    logic [31:0] axi_wdata;
    logic [3:0] axi_wstrb;
    logic axi_wvalid;
    logic axi_wready;

    // Write Response Channel
    logic [1:0] axi_bresp;
    logic axi_bvalid;
    logic axi_bready;

    // Read Address Channel
    logic [31:0] axi_araddr;
    logic axi_arvalid;
    logic axi_arready;
    logic [2:0] axi_arprot;

    // Read Data Channel
    logic [31:0] axi_rdata;
    logic [1:0] axi_rresp;
    logic axi_rvalid;
    logic axi_rready;

    // Write Address Channel CLINT
    logic [31:0] c_axi_awaddr;
    logic c_axi_awvalid;
    logic c_axi_awready;
    logic [2:0] c_axi_awprot;

    // Write Data Channel CLINT
    logic [31:0] c_axi_wdata;
    logic [3:0] c_axi_wstrb;
    logic c_axi_wvalid;
    logic c_axi_wready;

    // Write Response Channel CLINT
    logic [1:0] c_axi_bresp;
    logic c_axi_bvalid;
    logic c_axi_bready;

    // Read Address  CLINT
    logic [31:0] c_axi_araddr;
    logic c_axi_arvalid;
    logic c_axi_arready;
    logic [2:0] c_axi_arprot;

    // Read Data Channel CLINT
    logic [31:0] c_axi_rdata;
    logic [1:0] c_axi_rresp;
    logic c_axi_rvalid;
    logic c_axi_rready;

    // Write Address Channel dram
    logic [31:0] d_axi_awaddr;
    logic d_axi_awvalid;
    logic d_axi_awready;
    logic [2:0] d_axi_awprot;

    // Write Data Channel dram
    logic [31:0] d_axi_wdata;
    logic [3:0] d_axi_wstrb;
    logic d_axi_wvalid;
    logic d_axi_wready;

    // Write Response Channel dram
    logic [1:0] d_axi_bresp;
    logic d_axi_bvalid;
    logic d_axi_bready;

    // Read Address Channel dram
    logic [31:0] d_axi_araddr;
    logic d_axi_arvalid;
    logic d_axi_arready;
    logic [2:0] d_axi_arprot;

    // Read Data Channel
    logic [31:0] d_axi_rdata;
    logic [1:0] d_axi_rresp;
    logic d_axi_rvalid;
    logic d_axi_rready;

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

    assign c_axi_arvalid=axi_arvalid&(axi_araddr>=BASE);
    assign d_axi_arvalid=axi_arvalid&(axi_araddr<BASE);
    assign c_axi_awvalid=axi_awvalid&(axi_awaddr>=BASE);
    assign d_axi_awvalid=axi_awvalid&(axi_awaddr<BASE);
    
    clint_wrapper CLINT(
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // Simple Interface (CLINT side)
        .timerIrq(timerIrq),
        .softIrq(softIrq),

        // AXI Write Address
        .axi_awaddr(axi_awaddr),
        .axi_awvalid(c_axi_awvalid),
        .axi_awready(c_axi_awready),

        // AXI Write Data
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wvalid(axi_wvalid),
        .axi_wready(c_axi_wready),

        // AXI Write Response
        .axi_bresp(c_axi_bresp),
        .axi_bvalid(c_axi_bvalid),
        .axi_bready(axi_bready),

        // AXI Read Address
        .axi_araddr(axi_araddr),
        .axi_arvalid(c_axi_arvalid),
        .axi_arready(c_axi_arready),

        // AXI Read Data
        .axi_rdata(c_axi_rdata),
        .axi_rresp(c_axi_rresp),
        .axi_rvalid(c_axi_rvalid),
        .axi_rready(axi_rready));

    datram_wrapper DATRAM(
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // AXI Write Address
        .axi_awaddr(axi_awaddr),
        .axi_awvalid(d_axi_awvalid),
        .axi_awready(d_axi_awready),

        // AXI Write Data
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wvalid(axi_wvalid),
        .axi_wready(d_axi_wready),

        // AXI Write Response
        .axi_bresp(d_axi_bresp),
        .axi_bvalid(d_axi_bvalid),
        .axi_bready(axi_bready),

        // AXI Read Address
        .axi_araddr(axi_araddr),
        .axi_arvalid(d_axi_arvalid),
        .axi_arready(d_axi_arready),

        // AXI Read Data
        .axi_rdata(d_axi_rdata),
        .axi_rresp(d_axi_rresp),
        .axi_rvalid(d_axi_rvalid),
        .axi_rready(axi_rready));

        assign axi_wready=(axi_awaddr>=BASE)?c_axi_wready:d_axi_wready;
        assign axi_awready=(axi_awaddr>=BASE)?c_axi_awready:d_axi_awready;
        assign axi_bresp=(axi_awaddr>=BASE)?c_axi_bresp:d_axi_bresp;
        assign axi_bvalid=(axi_awaddr>=BASE)?c_axi_bvalid:d_axi_bvalid;
        assign axi_arready=(axi_araddr>=BASE)?c_axi_arready:d_axi_arready;
        assign axi_rresp=(axi_araddr>=BASE)?c_axi_rresp:d_axi_rresp;
        assign axi_rvalid=(axi_araddr>=BASE)?c_axi_rvalid:d_axi_rvalid;
        assign axi_rdata=(axi_araddr>=BASE)?c_axi_rdata:d_axi_rdata;

endmodule