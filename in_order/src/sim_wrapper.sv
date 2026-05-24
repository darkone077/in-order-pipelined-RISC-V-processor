`include "../src/axi_wrapper.sv"
`include "../src/clint_wrapper.sv"
`include "../src/ram_wrapper.sv"
`include "../src/cache_wrapper.sv"
module sim_wrapper#(
    parameter BASE = 32'h2000000
)(
    input logic clk,rst_n,
    output logic axi_error,timerIrq,softIrq,
    output logic [31:0] pcf,pcj
);

    logic [31:0] inst;
    logic cacheBusy;
    logic flush;

    // ==========================================
    // AXI-Lite Signals (CPU & General Routing)
    // ==========================================
    // Write Address Channel
    logic [31:0] axil_awaddr;
    logic axil_awvalid;
    logic axil_awready;
    logic [2:0] axil_awprot;

    // Write Data Channel
    logic [31:0] axil_wdata;
    logic [3:0] axil_wstrb;
    logic axil_wvalid;
    logic axil_wready;

    // Write Response Channel
    logic [1:0] axil_bresp;
    logic axil_bvalid;
    logic axil_bready;

    // Read Address Channel
    logic [31:0] axil_araddr;
    logic axil_arvalid;
    logic axil_arready;
    logic [2:0] axil_arprot;

    // Read Data Channel
    logic [31:0] axil_rdata;
    logic [1:0] axil_rresp;
    logic axil_rvalid;
    logic axil_rready;

    // ==========================================
    // AXI-Lite Signals (CLINT Specific)
    // ==========================================
    logic c_axil_awvalid;
    logic c_axil_awready;
    logic c_axil_wready;
    logic [1:0] c_axil_bresp;
    logic c_axil_bvalid;

    logic c_axil_arvalid;
    logic c_axil_arready;
    logic [31:0] c_axil_rdata;
    logic [1:0] c_axil_rresp;
    logic c_axil_rvalid;

    // ==========================================
    // AXI-Lite Signals (CACHE Specific)
    // ==========================================
    logic d_axil_awvalid;
    logic d_axil_awready;
    logic d_axil_wready;
    logic [1:0] d_axil_bresp;
    logic d_axil_bvalid;

    logic d_axil_arvalid;
    logic d_axil_arready;
    logic [31:0] d_axil_rdata;
    logic [1:0] d_axil_rresp;
    logic d_axil_rvalid;

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

    // ==========================================
    // Modules
    // ==========================================
    
    // CPU with purely AXI-Lite interface
    axi_wrapper CPU (
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // Simple Interface (CPU side)
        .axi_error(axi_error),
        .inst(inst),
        .cacheBusy(cacheBusy),
        .pcf(pcf),
        .pcj(pcj),

        // AXI Write Address
        .axi_awaddr(axil_awaddr),
        .axi_awvalid(axil_awvalid),
        .axi_awready(axil_awready),
        .axi_awprot(axil_awprot),

        // AXI Write Data
        .axi_wdata(axil_wdata),
        .axi_wstrb(axil_wstrb),
        .axi_wvalid(axil_wvalid),
        .axi_wready(axil_wready),

        // AXI Write Response
        .axi_bresp(axil_bresp),
        .axi_bvalid(axil_bvalid),
        .axi_bready(axil_bready),

        // AXI Read Address
        .axi_araddr(axil_araddr),
        .axi_arvalid(axil_arvalid),
        .axi_arready(axil_arready),
        .axi_arprot(axil_arprot),

        // AXI Read Data
        .axi_rdata(axil_rdata),
        .axi_rresp(axil_rresp),
        .axi_rvalid(axil_rvalid),
        .axi_rready(axil_rready)
    );

    // Decoding Valid Logic
    assign c_axil_arvalid = axil_arvalid & (axil_araddr >= BASE);
    assign d_axil_arvalid = axil_arvalid & (axil_araddr < BASE);
    
    assign c_axil_awvalid = axil_awvalid & (axil_awaddr >= BASE);
    assign d_axil_awvalid = axil_awvalid & (axil_awaddr < BASE);
    
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

    cache_wrapper CACHE (
        // cache IO
        .clk(clk),
        .rst_n(rst_n),
        .pc(pcf),
        .flush(flush),
        .inst(inst),
        .busy(cacheBusy),

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
        .axi_rready(d_axi_rready),

        // AXI-Lite Write Address Channel (from CPU)
        .axil_awaddr(axil_awaddr),
        .axil_awvalid(d_axil_awvalid),
        .axil_awready(d_axil_awready),
        .axil_awprot(axil_awprot),

        // AXI-Lite Write Data Channel (from CPU)
        .axil_wdata(axil_wdata),
        .axil_wstrb(axil_wstrb),
        .axil_wvalid(axil_wvalid),
        .axil_wready(d_axil_wready),

        // AXI-Lite Write Response Channel (to CPU)
        .axil_bresp(d_axil_bresp),
        .axil_bvalid(d_axil_bvalid),
        .axil_bready(axil_bready),

        // AXI-Lite Read Address Channel (from CPU)
        .axil_araddr(axil_araddr),
        .axil_arvalid(d_axil_arvalid),
        .axil_arready(d_axil_arready),
        .axil_arprot(axil_arprot),

        // AXI-Lite Read Data Channel (to CPU)
        .axil_rdata(d_axil_rdata),
        .axil_rresp(d_axil_rresp),
        .axil_rvalid(d_axil_rvalid),
        .axil_rready(axil_rready)
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

    // ==========================================
    // Multiplex Responses Back to CPU
    // ==========================================
    assign axil_wready  = (axil_awaddr >= BASE) ? c_axil_wready  : d_axil_wready;
    assign axil_awready = (axil_awaddr >= BASE) ? c_axil_awready : d_axil_awready;
    assign axil_bresp   = (axil_awaddr >= BASE) ? c_axil_bresp   : d_axil_bresp;
    assign axil_bvalid  = (axil_awaddr >= BASE) ? c_axil_bvalid  : d_axil_bvalid;
    
    assign axil_arready = (axil_araddr >= BASE) ? c_axil_arready : d_axil_arready;
    assign axil_rresp   = (axil_araddr >= BASE) ? c_axil_rresp   : d_axil_rresp;
    assign axil_rvalid  = (axil_araddr >= BASE) ? c_axil_rvalid  : d_axil_rvalid;
    assign axil_rdata   = (axil_araddr >= BASE) ? c_axil_rdata   : d_axil_rdata;


endmodule