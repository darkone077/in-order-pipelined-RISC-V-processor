`include "../src/top_no_axi.sv"
`include "../src/clint_wrapper.sv"
`include "../src/ram_wrapper.sv"
`include "../src/cache_io_wrapper.sv"
`include "../src/gpio_wrapper.sv"
`include "../src/console.sv"
module sim_no_axi_lite#(
    parameter CLINT_START = 32'h2000000,
    parameter CLINT_END = 32'h200ffff,
    parameter GPIO_START = 32'h2010000,
    parameter GPIO_END = 32'h15000000
)(
    input logic clk,rst_n,
    output logic axi_error,
    output logic [31:0] pcf,pcj
);

    logic [31:0] inst;
    logic cacheBusy,axiBusy;
    logic flush;
    logic read,wrt;
    logic [31:0] wrt_data,mem_ad;
    logic [31:0] read_data;
    logic [3:0] wrt_stb;
    logic timerIrq,swIrq;

    logic [31:0] read_data_io [0:3],wrt_data_io [0:3];
    logic [3:0] read_io,wrt_io;
    logic [31:0] addr;

    // Write Address Channel
    logic [31:0] axi_awaddr;
    logic axi_awvalid;
    logic axi_awready;
    logic [2:0] axi_awprot;
    logic [3:0] axi_awid;
    logic [7:0] axi_awlen;
    logic [1:0] axi_awburst;
    logic [2:0] axi_awsize;
    logic [3:0] axi_awqos;
    logic [3:0] axi_awregion;
    logic [3:0] axi_awcache;
    logic axi_awlock;

    // Write Data Channel
    logic [31:0] axi_wdata;
    logic [3:0] axi_wstrb;
    logic axi_wlast;
    logic axi_wvalid;
    logic axi_wready;

    // Write Response Channel
    logic [3:0] axi_bid;
    logic [1:0] axi_bresp;
    logic axi_bvalid;
    logic axi_bready;

    // Read Address Channel
    logic [3:0] axi_arid;
    logic [31:0] axi_araddr;
    logic [7:0] axi_arlen;
    logic [2:0] axi_arsize;
    logic [1:0] axi_arburst;
    logic [3:0] axi_arcache;
    logic [2:0] axi_arprot;
    logic [3:0] axi_arqos;
    logic [3:0] axi_arregion;
    logic axi_arlock;
    logic axi_arvalid;
    logic axi_arready;

    // Read Data Channel
    logic [3:0] axi_rid;
    logic [31:0] axi_rdata;
    logic [1:0] axi_rresp;
    logic axi_rlast;
    logic axi_rvalid;
    logic axi_rready;

    // Write Address Channel
    logic [31:0] axil_awaddr;
    logic axil_awvalid,c_axil_awvalid,g_axil_awvalid;
    logic axil_awready,c_axil_awready,g_axil_awready;
    logic [2:0] axil_awprot;

    // Write Data Channel
    logic [31:0] axil_wdata;
    logic [3:0] axil_wstrb;
    logic axil_wvalid;
    logic axil_wready,c_axil_wready,g_axil_wready;

    // Write Response Channel
    logic [1:0] axil_bresp,c_axil_bresp,g_axil_bresp;
    logic axil_bvalid,c_axil_bvalid,g_axil_bvalid;
    logic axil_bready;

    // Read Address Channel
    logic [31:0] axil_araddr;
    logic axil_arvalid,c_axil_arvalid,g_axil_arvalid;
    logic axil_arready,c_axil_arready,g_axil_arready;
    logic [2:0] axil_arprot;

    // Read Data Channel
    logic [31:0] axil_rdata,c_axil_rdata,g_axil_rdata;
    logic [1:0] axil_rresp,c_axil_rresp,g_axil_rresp;
    logic axil_rvalid,c_axil_rvalid,g_axil_rvalid;
    logic axil_rready;
    logic c_rselector;
    logic c_wselector;

    top_no_axi CPU (clk,~rst_n,timerIrq,swIrq,axi_error,pcf,pcj,inst,cacheBusy,axiBusy,read,wrt,wrt_data,mem_ad,wrt_stb,read_data);
   
    always_comb begin
        c_rselector=axil_araddr>=CLINT_START&axil_araddr<=CLINT_END;
        c_wselector=axil_awaddr>=CLINT_START&axil_awaddr<=CLINT_END;

        c_axil_awvalid=c_wselector?axil_awvalid:1'b0;
        g_axil_awvalid=c_wselector?1'b0:axil_awvalid;
        axil_awready=c_wselector?c_axil_awready:g_axil_awready;
        
        axil_wready=c_wselector?c_axil_wready:g_axil_wready;

        axil_bresp=c_wselector?c_axil_bresp:g_axil_bresp;
        axil_bvalid=c_wselector?c_axil_bvalid:g_axil_bvalid;

        c_axil_arvalid=c_rselector?axil_arvalid:1'b0;
        g_axil_arvalid=c_rselector?1'b0:axil_arvalid;
        axil_arready=c_rselector?c_axil_arready:g_axil_arready;
        
        axil_rdata=c_rselector?c_axil_rdata:g_axil_rdata;
        axil_rresp=c_rselector?c_axil_rresp:g_axil_rresp;
        axil_rvalid=c_rselector?c_axil_rvalid:g_axil_rvalid;

    end

    clint_wrapper CLINT(
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // Simple Interface (CLINT side)
        .timerIrq(timerIrq),
        .softIrq(swIrq),

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

    gpio_wrapper GPIO(// System Signals
        .clk(clk),
        .rst_n(rst_n),
        .read_data(read_data_io),
        .wrt_data(wrt_data_io),
        .read(read_io),
        .wrt(wrt_io),
        .addr(addr),

        // AXI-Lite Interface
        .axi_awaddr(axil_awaddr),
        .axi_awvalid(g_axil_awvalid),
        .axi_awready(g_axil_awready),

        .axi_wdata(axil_wdata),
        .axi_wstrb(axil_wstrb),
        .axi_wvalid(axil_wvalid),
        .axi_wready(g_axil_wready),

        .axi_bresp(g_axil_bresp),
        .axi_bvalid(g_axil_bvalid),
        .axi_bready(axil_bready),

        .axi_araddr(axil_araddr),
        .axi_arvalid(g_axil_arvalid),
        .axi_arready(g_axil_arready),

        .axi_rdata(g_axil_rdata),
        .axi_rresp(g_axil_rresp),
        .axi_rvalid(g_axil_rvalid),
        .axi_rready(axil_rready)
        );

    console CON(clk,addr,wrt_data_io[3][7:0],wrt_io[3]);
    cache_io_wrapper CACHE (
        // cache IO
        .clk(clk),
        .rst_n(rst_n),
        .pc(pcf),
        .flush(flush),
        .inst(inst),
        .busy(cacheBusy),
        .axi_busy(axiBusy),
        .wrt_data(wrt_data),
        .wrt_stb(wrt_stb),
        .read_data(read_data),
        .read(read),
        .wrt(wrt),
        .mem_ad(mem_ad),

        // Full AXI Write Address Channel (to RAM)
        .axi_awaddr(axi_awaddr),
        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),
        .axi_awprot(axi_awprot),
        .axi_awid(axi_awid),
        .axi_awlen(axi_awlen),
        .axi_awburst(axi_awburst),
        .axi_awsize(axi_awsize),
        .axi_awqos(axi_awqos),
        .axi_awregion(axi_awregion),
        .axi_awcache(axi_awcache),
        .axi_awlock(axi_awlock),

        // Full AXI Write Data Channel (to RAM)
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wlast(axi_wlast),
        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),

        // Full AXI Write Response Channel (from RAM)
        .axi_bid(axi_bid),
        .axi_bresp(axi_bresp),
        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready),

        // Full AXI Read Address Channel (to RAM)
        .axi_arid(axi_arid),
        .axi_araddr(axi_araddr),
        .axi_arlen(axi_arlen),
        .axi_arsize(axi_arsize),
        .axi_arburst(axi_arburst),
        .axi_arcache(axi_arcache),
        .axi_arprot(axi_arprot),
        .axi_arqos(axi_arqos),
        .axi_arregion(axi_arregion),
        .axi_arlock(axi_arlock),
        .axi_arvalid(axi_arvalid),
        .axi_arready(axi_arready),

        // Full AXI Read Data Channel (from RAM)
        .axi_rid(axi_rid),
        .axi_rdata(axi_rdata),
        .axi_rresp(axi_rresp),
        .axi_rlast(axi_rlast),
        .axi_rvalid(axi_rvalid),
        .axi_rready(axi_rready),

        // AXI Write Address
        .axil_awaddr(axil_awaddr),
        .axil_awvalid(axil_awvalid),
        .axil_awready(axil_awready),
        .axil_awprot(axil_awprot),

        // AXI Write Data
        .axil_wdata(axil_wdata),
        .axil_wstrb(axil_wstrb),
        .axil_wvalid(axil_wvalid),
        .axil_wready(axil_wready),

        // AXI Write Response
        .axil_bresp(axil_bresp),
        .axil_bvalid(axil_bvalid),
        .axil_bready(axil_bready),

        // AXI Read Address
        .axil_araddr(axil_araddr),
        .axil_arvalid(axil_arvalid),
        .axil_arready(axil_arready),
        .axil_arprot(axil_arprot),

        // AXI Read Data
        .axil_rdata(axil_rdata),
        .axil_rresp(axil_rresp),
        .axil_rvalid(axil_rvalid),
        .axil_rready(axil_rready)
    );
  
    ram_wrapper RAM(
        // System Signals
        .clk(clk),
        .rst_n(rst_n),
        
        // Full AXI Interface
        .axi_awaddr(axi_awaddr),
        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),
        .axi_awprot(axi_awprot),
        .axi_awid(axi_awid),
        .axi_awlen(axi_awlen),
        .axi_awburst(axi_awburst),
        .axi_awsize(axi_awsize),
        .axi_awqos(axi_awqos),
        .axi_awregion(axi_awregion),
        .axi_awcache(axi_awcache),
        .axi_awlock(axi_awlock),

        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wlast(axi_wlast),
        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),

        .axi_bid(axi_bid),
        .axi_bresp(axi_bresp),
        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready),

        .axi_arid(axi_arid),
        .axi_araddr(axi_araddr),
        .axi_arlen(axi_arlen),
        .axi_arsize(axi_arsize),
        .axi_arburst(axi_arburst),
        .axi_arcache(axi_arcache),
        .axi_arprot(axi_arprot),
        .axi_arqos(axi_arqos),
        .axi_arregion(axi_arregion),
        .axi_arlock(axi_arlock),
        .axi_arvalid(axi_arvalid),
        .axi_arready(axi_arready),

        .axi_rid(axi_rid),
        .axi_rdata(axi_rdata),
        .axi_rresp(axi_rresp),
        .axi_rlast(axi_rlast),
        .axi_rvalid(axi_rvalid),
        .axi_rready(axi_rready)
    );

        /*always_comb begin
        if (axil_awaddr==32'h10000000&addr==32'h10000000) begin
            $display("%d %d",wrt_data_io[0],wrt_io);
            $display("%d",wrt_data_io[1],);
            $display("%d",wrt_data_io[2]);
            $display("%d\n\n",wrt_data_io[3]);
        end
    end*/
endmodule