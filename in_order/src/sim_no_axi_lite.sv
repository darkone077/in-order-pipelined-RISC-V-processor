`include "../src/top_no_axi.sv"
`include "../src/clint_wrapper.sv"
`include "../src/ram_wrapper.sv"
`include "../src/cache_no_axi_lite_wrapper.sv"
module sim_no_axi_lite#(
    parameter BASE = 32'h2000000
)(
    input logic clk,rst_n,
    output logic axi_error,timerIrq,softIrq,
    output logic [31:0] pcf,pcj
);

    logic [31:0] inst;
    logic cacheBusy;
    logic flush;
    logic read,wrt;
    logic [31:0] wrt_data,mem_ad;
    logic [31:0] read_data;
    logic [3:0] wrt_stb;


    // ==========================================
    // Full AXI Signals (RAM)
    // ==========================================
    // Write Address Channel
    logic [31:0] d_axi_awaddr;
    logic d_axi_awvalid;
    logic d_axi_awready;
    logic [2:0] d_axi_awprot;
    logic [3:0] d_axi_awid;
    logic [7:0] d_axi_awlen;
    logic [1:0] d_axi_awburst;
    logic [2:0] d_axi_awsize;
    logic [3:0] d_axi_awqos;
    logic [3:0] d_axi_awregion;
    logic [3:0] d_axi_awcache;
    logic d_axi_awlock;

    // Write Data Channel
    logic [31:0] d_axi_wdata;
    logic [3:0] d_axi_wstrb;
    logic d_axi_wlast;
    logic d_axi_wvalid;
    logic d_axi_wready;

    // Write Response Channel
    logic [3:0] d_axi_bid;
    logic [1:0] d_axi_bresp;
    logic d_axi_bvalid;
    logic d_axi_bready;

    // Read Address Channel
    logic [3:0] d_axi_arid;
    logic [31:0] d_axi_araddr;
    logic [7:0] d_axi_arlen;
    logic [2:0] d_axi_arsize;
    logic [1:0] d_axi_arburst;
    logic [3:0] d_axi_arcache;
    logic [2:0] d_axi_arprot;
    logic [3:0] d_axi_arqos;
    logic [3:0] d_axi_arregion;
    logic d_axi_arlock;
    logic d_axi_arvalid;
    logic d_axi_arready;

    // Read Data Channel
    logic [3:0] d_axi_rid;
    logic [31:0] d_axi_rdata;
    logic [1:0] d_axi_rresp;
    logic d_axi_rlast;
    logic d_axi_rvalid;
    logic d_axi_rready;

    top_no_axi CPU (clk,~rst_n,axi_error,pcf,pcj,inst,cacheBusy,read,wrt,wrt_data,mem_ad,wrt_stb,read_data);
   /* 
    clint_wrapper CLINT(
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // Simple Interface (CLINT side)
        .timerIrq(timerIrq),
        .softIrq(softIrq),

        // AXI-Lite Interface
        .axi_awaddr(axil_awaddr),
        .axi_awvalid(c_axil_awvalid),
        .axi_awready(c_axil_awready),

        .axi_wdata(axil_wdata),
        .axi_wstrb(axil_wstrb),
        .axi_wvalid(axil_wvalid),
        .axi_wready(c_axil_wready),

        .axi_bresp(c_axil_bresp),
        .axi_bvalid(c_axil_bvalid),
        .axi_bready(axil_bready),

        .axi_araddr(axil_araddr),
        .axi_arvalid(c_axil_arvalid),
        .axi_arready(c_axil_arready),

        .axi_rdata(c_axil_rdata),
        .axi_rresp(c_axil_rresp),
        .axi_rvalid(c_axil_rvalid),
        .axi_rready(axil_rready)
    );
*/
    cache_no_axi_lite_wrapper CACHE (
        // cache IO
        .clk(clk),
        .rst_n(rst_n),
        .pc(pcf),
        .flush(flush),
        .inst(inst),
        .busy(cacheBusy),
        .wrt_data(wrt_data),
        .wrt_stb(wrt_stb),
        .read_data(read_data),
        .read(read),
        .wrt(wrt),
        .mem_ad(mem_ad),

        // Full AXI Write Address Channel (to RAM)
        .axi_awaddr(d_axi_awaddr),
        .axi_awvalid(d_axi_awvalid),
        .axi_awready(d_axi_awready),
        .axi_awprot(d_axi_awprot),
        .axi_awid(d_axi_awid),
        .axi_awlen(d_axi_awlen),
        .axi_awburst(d_axi_awburst),
        .axi_awsize(d_axi_awsize),
        .axi_awqos(d_axi_awqos),
        .axi_awregion(d_axi_awregion),
        .axi_awcache(d_axi_awcache),
        .axi_awlock(d_axi_awlock),

        // Full AXI Write Data Channel (to RAM)
        .axi_wdata(d_axi_wdata),
        .axi_wstrb(d_axi_wstrb),
        .axi_wlast(d_axi_wlast),
        .axi_wvalid(d_axi_wvalid),
        .axi_wready(d_axi_wready),

        // Full AXI Write Response Channel (from RAM)
        .axi_bid(d_axi_bid),
        .axi_bresp(d_axi_bresp),
        .axi_bvalid(d_axi_bvalid),
        .axi_bready(d_axi_bready),

        // Full AXI Read Address Channel (to RAM)
        .axi_arid(d_axi_arid),
        .axi_araddr(d_axi_araddr),
        .axi_arlen(d_axi_arlen),
        .axi_arsize(d_axi_arsize),
        .axi_arburst(d_axi_arburst),
        .axi_arcache(d_axi_arcache),
        .axi_arprot(d_axi_arprot),
        .axi_arqos(d_axi_arqos),
        .axi_arregion(d_axi_arregion),
        .axi_arlock(d_axi_arlock),
        .axi_arvalid(d_axi_arvalid),
        .axi_arready(d_axi_arready),

        // Full AXI Read Data Channel (from RAM)
        .axi_rid(d_axi_rid),
        .axi_rdata(d_axi_rdata),
        .axi_rresp(d_axi_rresp),
        .axi_rlast(d_axi_rlast),
        .axi_rvalid(d_axi_rvalid),
        .axi_rready(d_axi_rready)
    );
  
    ram_wrapper RAM(
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // Full AXI Interface
        .axi_awaddr(d_axi_awaddr),
        .axi_awvalid(d_axi_awvalid),
        .axi_awready(d_axi_awready),
        .axi_awprot(d_axi_awprot),
        .axi_awid(d_axi_awid),
        .axi_awlen(d_axi_awlen),
        .axi_awburst(d_axi_awburst),
        .axi_awsize(d_axi_awsize),
        .axi_awqos(d_axi_awqos),
        .axi_awregion(d_axi_awregion),
        .axi_awcache(d_axi_awcache),
        .axi_awlock(d_axi_awlock),

        .axi_wdata(d_axi_wdata),
        .axi_wstrb(d_axi_wstrb),
        .axi_wlast(d_axi_wlast),
        .axi_wvalid(d_axi_wvalid),
        .axi_wready(d_axi_wready),

        .axi_bid(d_axi_bid),
        .axi_bresp(d_axi_bresp),
        .axi_bvalid(d_axi_bvalid),
        .axi_bready(d_axi_bready),

        .axi_arid(d_axi_arid),
        .axi_araddr(d_axi_araddr),
        .axi_arlen(d_axi_arlen),
        .axi_arsize(d_axi_arsize),
        .axi_arburst(d_axi_arburst),
        .axi_arcache(d_axi_arcache),
        .axi_arprot(d_axi_arprot),
        .axi_arqos(d_axi_arqos),
        .axi_arregion(d_axi_arregion),
        .axi_arlock(d_axi_arlock),
        .axi_arvalid(d_axi_arvalid),
        .axi_arready(d_axi_arready),

        .axi_rid(d_axi_rid),
        .axi_rdata(d_axi_rdata),
        .axi_rresp(d_axi_rresp),
        .axi_rlast(d_axi_rlast),
        .axi_rvalid(d_axi_rvalid),
        .axi_rready(d_axi_rready)
    );


endmodule