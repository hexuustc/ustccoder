`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 10:02:33
// Design Name: 
// Module Name: myCPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top
#(parameter WIDTH = 32)
(
    //clock and reset
    input         aclk,
    input         aresetn,
    
//    input             i_req,
//    input             i_wreq,
//    input [WIDTH-1:0] i_write_data,
//    output  [WIDTH-1:0] i_read_data,
//    input [WIDTH-1:0] i_addr,
//    input [4      :0] i_wbyte,
//    output              i_ok,
    
//    input             d_req,
//    input             d_wreq,
//    input [WIDTH-1:0] d_write_data,
//    output  [WIDTH-1:0] d_read_data,
//    input [WIDTH-1:0] d_addr,
//    input [4      :0] d_wbyte,
//    output              d_ok,
    
    output        led
);

wire cpu_clk, sys_clk;

    //ar
wire [3 :0] cpu_arid;
wire [31:0] cpu_araddr;
wire [7 :0] cpu_arlen;
wire [2 :0] cpu_arsize;
wire [1 :0] cpu_arburst;
wire        cpu_arlock;
wire [3 :0] cpu_arcache;
wire [2 :0] cpu_arprot;
wire        cpu_arvalid;
wire        cpu_arready;
    //r
wire  [3 :0] cpu_rid;
wire  [31:0] cpu_rdata;
wire  [1 :0] cpu_rresp;
wire         cpu_rlast;
wire         cpu_rvalid;
wire         cpu_rready;
    //aw
wire [3 :0] cpu_awid;
wire [31:0] cpu_awaddr;
wire [7 :0] cpu_awlen;
wire [2 :0] cpu_awsize;
wire [1 :0] cpu_awburst;
wire        cpu_awlock;
wire [3 :0] cpu_awcache;
wire [2 :0] cpu_awprot;
wire        cpu_awvalid;
wire        cpu_awready;
    //w
wire [3 :0] cpu_wid;
wire [31:0] cpu_wdata;
wire [3 :0] cpu_wstrb;
wire        cpu_wlast;
wire        cpu_wvalid;
wire        cpu_wready;
    //b
wire  [3 :0] cpu_bid;
wire  [1 :0] cpu_bresp;
wire         cpu_bvalid;
wire         cpu_bready;

    //ar
wire [3 :0] sys_arid;
wire [31:0] sys_araddr;
wire [7 :0] sys_arlen;
wire [2 :0] sys_arsize;
wire [1 :0] sys_arburst;
wire        sys_arlock;
wire [3 :0] sys_arcache;
wire [2 :0] sys_arprot;
wire        sys_arvalid;
wire        sys_arready;
    //r
wire  [3 :0] sys_rid;
wire  [31:0] sys_rdata;
wire  [1 :0] sys_rresp;
wire         sys_rlast;
wire         sys_rvalid;
wire         sys_rready;
    //aw
wire [3 :0] sys_awid;
wire [31:0] sys_awaddr;
wire [7 :0] sys_awlen;
wire [2 :0] sys_awsize;
wire [1 :0] sys_awburst;
wire        sys_awlock;
wire [3 :0] sys_awcache;
wire [2 :0] sys_awprot;
wire        sys_awvalid;
wire        sys_awready;
    //w
wire [3 :0] sys_wid;
wire [31:0] sys_wdata;
wire [3 :0] sys_wstrb;
wire        sys_wlast;
wire        sys_wvalid;
wire        sys_wready;
    //b
wire  [3 :0] sys_bid;
wire  [1 :0] sys_bresp;
wire         sys_bvalid;
wire         sys_bready;

//cpu inst
wire cpu_i_req, cpu_i_wreq;
wire [31:0] cpu_i_write_data, cpu_i_addr, cpu_i_read_data;
wire [3:0] cpu_i_wbyte;
wire cpu_i_miss;

//icache
wire icache_en, icache_wen;
wire [31:0] icache_read_data;
wire [31:0] icache_write_data;
wire [31:0] icache_addr;
wire icache_burst_ok, icache_addr_ok, icache_data_ok;
//ar
wire [3 :0] i_arid;
wire [31:0] i_araddr;
wire [7 :0] i_arlen;
wire [2 :0] i_arsize;
wire [1 :0] i_arburst;
wire        i_arlock;
wire [3 :0] i_arcache;
wire [2 :0] i_arprot;
wire        i_arvalid;
wire        i_arready;
//r
wire [3 :0] i_rid;
wire [31:0] i_rdata;
wire [1 :0] i_rresp;
wire        i_rlast;
wire        i_rvalid;
wire        i_rready;
//aw
wire [3 :0] i_awid;
wire [31:0] i_awaddr;
wire [7 :0] i_awlen;
wire [2 :0] i_awsize;
wire [1 :0] i_awburst;
wire        i_awlock;
wire [3 :0] i_awcache;
wire [2 :0] i_awprot;
wire        i_awvalid;
wire        i_awready;
//w
wire [3 :0] i_wid;
wire [31:0] i_wdata;
wire [3 :0] i_wstrb;
wire        i_wlast;
wire        i_wvalid;
wire        i_wready;
//b
wire [3 :0] i_bid;
wire [1 :0] i_bresp;
wire        i_bvalid;
wire        i_bready;
//cpu data
wire cpu_d_req, cpu_d_wreq;
wire [31:0] cpu_d_write_data, cpu_d_addr, cpu_d_read_data;
wire [3:0] cpu_d_wbyte;
wire cpu_d_miss;
//dcache
wire dcache_en, dcache_wen;
wire [31:0] dcache_read_data;
wire [31:0] dcache_write_data;
wire [31:0] dcache_addr;
wire dcache_burst_ok, dcache_addr_ok, dcache_data_ok;
//ar
wire [3 :0] d_arid;
wire [31:0] d_araddr;
wire [7 :0] d_arlen;
wire [2 :0] d_arsize;
wire [1 :0] d_arburst;
wire        d_arlock;
wire [3 :0] d_arcache;
wire [2 :0] d_arprot;
wire        d_arvalid;
wire        d_arready;
//r
wire [3 :0] d_rid;
wire [31:0] d_rdata;
wire [1 :0] d_rresp;
wire        d_rlast;
wire        d_rvalid;
wire        d_rready;
//aw
wire [3 :0] d_awid;
wire [31:0] d_awaddr;
wire [7 :0] d_awlen;
wire [2 :0] d_awsize;
wire [1 :0] d_awburst;
wire        d_awlock;
wire [3 :0] d_awcache;
wire [2 :0] d_awprot;
wire        d_awvalid;
wire        d_awready;
//w
wire [3 :0] d_wid;
wire [31:0] d_wdata;
wire [3 :0] d_wstrb;
wire        d_wlast;
wire        d_wvalid;
wire        d_wready;
//b
wire [3 :0] d_bid;
wire [1 :0] d_bresp;
wire        d_bvalid;
wire        d_bready;

clk_wiz_0 clk_0(
    .clk_in1    (aclk     ),
    .cpu_clk    (cpu_clk  ),
    .sys_clk    (sys_clk  )
);

cpu_pipeline cpu_0(
    .clk        (cpu_clk  ),
    .rst        (~aresetn  ),
    
    .i_write_data (cpu_i_write_data ),
    .i_addr       (cpu_i_addr       ),
    .i_read_data  (cpu_i_read_data  ),
    .i_req        (cpu_i_req        ),
    .i_wreq       (cpu_i_wreq       ),
    .i_wbyte      (cpu_i_wbyte      ),
    .i_ok         (cpu_i_ok         ),
    
    .d_write_data (cpu_d_write_data ),
    .d_addr       (cpu_d_addr       ),
    .d_read_data  (cpu_d_read_data  ),
    .d_req        (cpu_d_req        ),
    .d_wreq       (cpu_d_wreq       ),
    .d_wbyte      (cpu_d_wbyte      ),
    .d_ok         (cpu_d_ok         ),
    
    .led          (led)
);

Icache icache(
    .clk    (cpu_clk  ),
    .rst    (~aresetn ),
    
    .insaddr (cpu_i_addr        ),
    .din     (cpu_i_write_data  ),
    .ins     (cpu_i_read_data   ),
    .req     (cpu_i_req         ),
    .wreq    (cpu_i_wreq        ),
    .wbyte   (cpu_i_wbyte       ),
    .miss    (cpu_i_miss        ),
    .ok      (cpu_i_ok          ),
    
    .wen     (icache_wen        ),
    .sen     (icache_en         ),
    .addr_ok (icache_addr_ok    ),
    .data_ok (icache_data_ok    ),
    .burst   (icache_burst_ok   ),
    .wdata   (icache_write_data ),
    .addr    (icache_addr       ),
    .sdata   (icache_read_data  )
);

cache_to_axi #(1'b1) icache_to_axi (
    .clk    (cpu_clk   ),
    .rstn   (aresetn),
    
    .en         (icache_en         ),
    .wen        (icache_wen        ),
    .addr       (icache_addr       ),
    .write_data (icache_write_data ),
    .read_data  (icache_read_data  ),
    .addr_ok    (icache_addr_ok    ),
    .data_ok    (icache_data_ok    ),
    .burst_ok   (icache_burst_ok   ),
    
    .arid       (i_arid   ),
    .araddr     (i_araddr ),
    .arlen      (i_arlen  ),
    .arsize     (i_arsize ),
    .arburst    (i_arburst),
    .arlock     (i_arlock ),
    .arcache    (i_arcache),
    .arprot     (i_arprot ),
    .arvalid    (i_arvalid),
    .arready    (i_arready),
    
    .rid        (i_rid    ),
    .rdata      (i_rdata  ),
    .rresp      (i_rresp  ),
    .rlast      (i_rlast  ),
    .rvalid     (i_rvalid ),
    .rready     (i_rready ),
    
    .awid       (i_awid   ),
    .awaddr     (i_awaddr ),
    .awlen      (i_awlen  ),
    .awsize     (i_awsize ),
    .awburst    (i_awburst),
    .awlock     (i_awlock ),
    .awcache    (i_awcache),
    .awprot     (i_awprot ),
    .awvalid    (i_awvalid),
    .awready    (i_awready),
    
    .wid        (i_wid    ),
    .wdata      (i_wdata  ),
    .wstrb      (i_wstrb  ),
    .wlast      (i_wlast  ),
    .wvalid     (i_wvalid ),
    .wready     (i_wready ),
    
    .bid        (i_bid    ),
    .bresp      (i_bresp  ),
    .bvalid     (i_bvalid ),
    .bready     (i_bready )
);

Dcache dcache(
    .clk    (cpu_clk  ),
    .rst    (~aresetn ),
    
    .insaddr (cpu_d_addr        ),
    .din     (cpu_d_write_data  ),
    .ins     (cpu_d_read_data   ),
    .req     (cpu_d_req         ),
    .wreq    (cpu_d_wreq        ),
    .wbyte   (cpu_d_wbyte       ),
    .miss    (cpu_d_miss        ),
    .ok      (cpu_d_ok          ),
    
    .wen     (dcache_wen        ),
    .sen     (dcache_en         ),
    .addr_ok (dcache_addr_ok    ),
    .data_ok (dcache_data_ok    ),
    .burst   (dcache_burst_ok   ),
    .wdata   (dcache_write_data ),
    .addr    (dcache_addr       ),
    .sdata   (dcache_read_data  )
);

cache_to_axi #(1'b0) dcache_to_axi (
    .clk    (cpu_clk   ),
    .rstn   (aresetn   ),
    
    .en         (dcache_en         ),
    .wen        (dcache_wen        ),
    .addr       (dcache_addr       ),
    .write_data (dcache_write_data ),
    .read_data  (dcache_read_data  ),
    .addr_ok    (dcache_addr_ok    ),
    .data_ok    (dcache_data_ok    ),
    .burst_ok   (dcache_burst_ok   ),
    
    .arid       (d_arid   ),
    .araddr     (d_araddr ),
    .arlen      (d_arlen  ),
    .arsize     (d_arsize ),
    .arburst    (d_arburst),
    .arlock     (d_arlock ),
    .arcache    (d_arcache),
    .arprot     (d_arprot ),
    .arvalid    (d_arvalid),
    .arready    (d_arready),
    
    .rid        (d_rid    ),
    .rdata      (d_rdata  ),
    .rresp      (d_rresp  ),
    .rlast      (d_rlast  ),
    .rvalid     (d_rvalid ),
    .rready     (d_rready ),
    
    .awid       (d_awid   ),
    .awaddr     (d_awaddr ),
    .awlen      (d_awlen  ),
    .awsize     (d_awsize ),
    .awburst    (d_awburst),
    .awlock     (d_awlock ),
    .awcache    (d_awcache),
    .awprot     (d_awprot ),
    .awvalid    (d_awvalid),
    .awready    (d_awready),
    
    .wid        (d_wid    ),
    .wdata      (d_wdata  ),
    .wstrb      (d_wstrb  ),
    .wlast      (d_wlast  ),
    .wvalid     (d_wvalid ),
    .wready     (d_wready ),
    
    .bid        (d_bid    ),
    .bresp      (d_bresp  ),
    .bvalid     (d_bvalid ),
    .bready     (d_bready )
);

axi_crossbar_2x1 u_axi_crossbar_2x1(
    .aclk       (cpu_clk   ),
    .aresetn    (aresetn   ),
    
    .s_axi_awid     ({i_awid,    d_awid    }),
    .s_axi_awaddr   ({i_awaddr,  d_awaddr  }),
    .s_axi_awlen    ({i_awlen,   d_awlen   }),
    .s_axi_awsize   ({i_awsize,  d_awsize  }),
    .s_axi_awburst  ({i_awburst, d_awburst }),
    .s_axi_awlock   ({i_awlock,  d_awlock  }),
    .s_axi_awcache  ({i_awcache, d_awcache }),
    .s_axi_awprot   ({i_awprot,  d_awprot  }),
    .s_axi_awqos    (8'd0                   ),
    .s_axi_awvalid  ({i_awvalid, d_awvalid }),
    .s_axi_awready  ({i_awready, d_awready }),
    .s_axi_wdata    ({i_wdata,   d_wdata   }),
    .s_axi_wstrb    ({i_wstrb,   d_wstrb   }),
    .s_axi_wlast    ({i_wlast,   d_wlast   }),
    .s_axi_wvalid   ({i_wvalid,  d_wvalid  }),
    .s_axi_wready   ({i_wready,  d_wready  }),
    .s_axi_bid      ({i_bid,     d_bid     }),
    .s_axi_bresp    ({i_bresp,   d_bresp   }),
    .s_axi_bvalid   ({i_bvalid,  d_bvalid  }),
    .s_axi_bready   ({i_bready,  d_bready  }),
    .s_axi_arid     ({i_arid,    d_arid    }),
    .s_axi_araddr   ({i_araddr,  d_araddr  }),
    .s_axi_arlen    ({i_arlen,   d_arlen   }),
    .s_axi_arsize   ({i_arsize,  d_arsize  }),
    .s_axi_arburst  ({i_arburst, d_arburst }),
    .s_axi_arlock   ({i_arlock,  d_arlock  }),
    .s_axi_arcache  ({i_arcache, d_arcache }),
    .s_axi_arprot   ({i_arprot,  d_arprot  }),
    .s_axi_arqos    (8'd0                   ),
    .s_axi_arvalid  ({i_arvalid, d_arvalid }),
    .s_axi_arready  ({i_arready, d_arready }),
    .s_axi_rid      ({i_rid,     d_rid     }),
    .s_axi_rdata    ({i_rdata,   d_rdata   }),
    .s_axi_rresp    ({i_rresp,   d_rresp   }),
    .s_axi_rlast    ({i_rlast,   d_rlast   }),
    .s_axi_rvalid   ({i_rvalid,  d_rvalid  }),
    .s_axi_rready   ({i_rready,  d_rready  }),
    
    .m_axi_awid     (cpu_awid    ),
    .m_axi_awaddr   (cpu_awaddr  ),
    .m_axi_awlen    (cpu_awlen   ),
    .m_axi_awsize   (cpu_awsize  ),
    .m_axi_awburst  (cpu_awburst ),
    .m_axi_awlock   (cpu_awlock  ),
    .m_axi_awcache  (cpu_awcache ),
    .m_axi_awprot   (cpu_awprot  ),
    .m_axi_awqos    (            ),
    .m_axi_awvalid  (cpu_awvalid ),
    .m_axi_awready  (cpu_awready ),
    .m_axi_wdata    (cpu_wdata   ),
    .m_axi_wstrb    (cpu_wstrb   ),
    .m_axi_wlast    (cpu_wlast   ),
    .m_axi_wvalid   (cpu_wvalid  ),
    .m_axi_wready   (cpu_wready  ),
    .m_axi_bid      (cpu_bid     ),
    .m_axi_bresp    (cpu_bresp   ),
    .m_axi_bvalid   (cpu_bvalid  ),
    .m_axi_bready   (cpu_bready  ),
    .m_axi_arid     (cpu_arid    ),
    .m_axi_araddr   (cpu_araddr  ),
    .m_axi_arlen    (cpu_arlen   ),
    .m_axi_arsize   (cpu_arsize  ),
    .m_axi_arburst  (cpu_arburst ),
    .m_axi_arlock   (cpu_arlock  ),
    .m_axi_arcache  (cpu_arcache ),
    .m_axi_arprot   (cpu_arprot  ),
    .m_axi_arqos    (            ),
    .m_axi_arvalid  (cpu_arvalid ),
    .m_axi_arready  (cpu_arready ),
    .m_axi_rid      (cpu_rid     ),
    .m_axi_rdata    (cpu_rdata   ),
    .m_axi_rresp    (cpu_rresp   ),
    .m_axi_rlast    (cpu_rlast   ),
    .m_axi_rvalid   (cpu_rvalid  ),
    .m_axi_rready   (cpu_rready  )
);

axi_clock_converter_0 conv_0(
    .s_axi_aclk     (cpu_clk     ),
    .s_axi_aresetn  (aresetn     ),

    .s_axi_awid     (cpu_awid    ),
    .s_axi_awaddr   (cpu_awaddr  ),
    .s_axi_awlen    (cpu_awlen   ),
    .s_axi_awsize   (cpu_awsize  ),
    .s_axi_awburst  (cpu_awburst ),
    .s_axi_awlock   (cpu_awlock  ),
    .s_axi_awcache  (cpu_awcache ),
    .s_axi_awprot   (cpu_awprot  ),
    .s_axi_awqos    (4'b0        ),
    .s_axi_awregion (4'b0        ),
    .s_axi_awvalid  (cpu_awvalid ),
    .s_axi_awready  (cpu_awready ),
    .s_axi_wdata    (cpu_wdata   ),
    .s_axi_wstrb    (cpu_wstrb   ),
    .s_axi_wlast    (cpu_wlast   ),
    .s_axi_wvalid   (cpu_wvalid  ),
    .s_axi_wready   (cpu_wready  ),
    .s_axi_bid      (cpu_bid     ),
    .s_axi_bresp    (cpu_bresp   ),
    .s_axi_bvalid   (cpu_bvalid  ),
    .s_axi_bready   (cpu_bready  ),
    .s_axi_arid     (cpu_arid    ),
    .s_axi_araddr   (cpu_araddr  ),
    .s_axi_arlen    (cpu_arlen   ),
    .s_axi_arsize   (cpu_arsize  ),
    .s_axi_arburst  (cpu_arburst ),
    .s_axi_arlock   (cpu_arlock  ),
    .s_axi_arcache  (cpu_arcache ),
    .s_axi_arprot   (cpu_arprot  ),
    .s_axi_arqos    (4'b0        ),
    .s_axi_arregion (4'b0        ),
    .s_axi_arvalid  (cpu_arvalid ),
    .s_axi_arready  (cpu_arready ),
    .s_axi_rid      (cpu_rid     ),
    .s_axi_rdata    (cpu_rdata   ),
    .s_axi_rresp    (cpu_rresp   ),
    .s_axi_rlast    (cpu_rlast   ),
    .s_axi_rvalid   (cpu_rvalid  ),
    .s_axi_rready   (cpu_rready  ),
    
    .m_axi_aclk     (sys_clk     ),
    .m_axi_aresetn  (aresetn     ),
    
    .m_axi_awid     (sys_awid    ),
    .m_axi_awaddr   (sys_awaddr  ),
    .m_axi_awlen    (sys_awlen   ),
    .m_axi_awsize   (sys_awsize  ),
    .m_axi_awburst  (sys_awburst ),
    .m_axi_awlock   (sys_awlock  ),
    .m_axi_awcache  (sys_awcache ),
    .m_axi_awprot   (sys_awprot  ),
    .m_axi_awqos    (            ),
    .m_axi_awvalid  (sys_awvalid ),
    .m_axi_awready  (sys_awready ),
    .m_axi_wdata    (sys_wdata   ),
    .m_axi_wstrb    (sys_wstrb   ),
    .m_axi_wlast    (sys_wlast   ),
    .m_axi_wvalid   (sys_wvalid  ),
    .m_axi_wready   (sys_wready  ),
    .m_axi_bid      (sys_bid     ),
    .m_axi_bresp    (sys_bresp   ),
    .m_axi_bvalid   (sys_bvalid  ),
    .m_axi_bready   (sys_bready  ),
    .m_axi_arid     (sys_arid    ),
    .m_axi_araddr   (sys_araddr  ),
    .m_axi_arlen    (sys_arlen   ),
    .m_axi_arsize   (sys_arsize  ),
    .m_axi_arburst  (sys_arburst ),
    .m_axi_arlock   (sys_arlock  ),
    .m_axi_arcache  (sys_arcache ),
    .m_axi_arprot   (sys_arprot  ),
    .m_axi_arqos    (            ),
    .m_axi_arvalid  (sys_arvalid ),
    .m_axi_arready  (sys_arready ),
    .m_axi_rid      (sys_rid     ),
    .m_axi_rdata    (sys_rdata   ),
    .m_axi_rresp    (sys_rresp   ),
    .m_axi_rlast    (sys_rlast   ),
    .m_axi_rvalid   (sys_rvalid  ),
    .m_axi_rready   (sys_rready  )
);

blk_mem_gen_0 blk_0(
    .s_aclk    (sys_clk  ),
    .s_aresetn (aresetn  ),
    
    .s_axi_araddr   (sys_araddr  ),
    .s_axi_arburst  (sys_arburst ),
    .s_axi_arid     (sys_arid    ),
    .s_axi_arlen    (sys_arlen   ),
    .s_axi_arready  (sys_arready ),
    .s_axi_arsize   (sys_arsize  ),
    .s_axi_arvalid  (sys_arvalid ),
    .s_axi_awaddr   (sys_awaddr  ),
    .s_axi_awburst  (sys_awburst ),
    .s_axi_awid     (sys_awid    ),
    .s_axi_awlen    (sys_awlen   ),
    .s_axi_awready  (sys_awready ),
    .s_axi_awsize   (sys_awsize  ),
    .s_axi_awvalid  (sys_awvalid ),
    .s_axi_bid      (sys_bid     ),
    .s_axi_bready   (sys_bready  ),
    .s_axi_bresp    (sys_bresp   ),
    .s_axi_bvalid   (sys_bvalid  ),
    .s_axi_rdata    (sys_rdata   ),
    .s_axi_rid      (sys_rid     ),
    .s_axi_rlast    (sys_rlast   ),
    .s_axi_rready   (sys_rready  ),
    .s_axi_rresp    (sys_rresp   ),
    .s_axi_rvalid   (sys_rvalid  ),
    .s_axi_wdata    (sys_wdata   ),
    .s_axi_wlast    (sys_wlast   ),
    .s_axi_wready   (sys_wready  ),
    .s_axi_wstrb    (sys_wstrb   ),
    .s_axi_wvalid   (sys_wvalid  )
);

endmodule