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


module mycpu_top
(
    //interrupt
    input  [5 :0] ext_int,
    //clock and reset
    input         aclk,
    input         aresetn,
    //ar
    output [3 :0] arid,
    output [31:0] araddr,
    output [3 :0] arlen,
    output [2 :0] arsize,
    output [1 :0] arburst,
    output [1 :0] arlock,
    output [3 :0] arcache,
    output [2 :0] arprot,
    output        arvalid,
    input         arready,
    //r
    input  [3 :0] rid,
    input  [31:0] rdata,
    input  [1 :0] rresp,
    input         rlast,
    input         rvalid,
    output        rready,
    //aw
    output [3 :0] awid,
    output [31:0] awaddr,
    output [3 :0] awlen,
    output [2 :0] awsize,
    output [1 :0] awburst,
    output [1 :0] awlock,
    output [3 :0] awcache,
    output [2 :0] awprot,
    output        awvalid,
    input         awready,
    //w
    output [3 :0] wid,
    output [31:0] wdata,
    output [3 :0] wstrb,
    output        wlast,
    output        wvalid,
    input         wready,
    //b
    input  [3 :0] bid,
    input  [1 :0] bresp,
    input         bvalid,
    output        bready,
    //debug
    output [31:0] debug_wb_pc,
    output [3 :0] debug_wb_rf_wen,
    output [4 :0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);
//cpu inst
wire cpu_i_req;
wire [31:0] cpu_i_addr;
wire [31:0] cpu_i_read_data;
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
wire [3 :0] i_arlen;
wire [2 :0] i_arsize;
wire [1 :0] i_arburst;
wire [1 :0] i_arlock;
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
wire [3 :0] i_awlen;
wire [2 :0] i_awsize;
wire [1 :0] i_awburst;
wire [1 :0] i_awlock;
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
wire [31:0] cpu_d_write_data;
wire [31:0] cpu_d_addr;
wire [31:0] cpu_d_read_data;
wire [3:0] cpu_d_wbyte;
wire cpu_d_miss;
//dcache
wire dcache_en, dcache_wen;
wire [31:0] dcache_read_data;
wire [31:0] dcache_write_data;
wire [31:0] dcache_read_addr;
wire [31:0] dcache_write_addr;
wire dcache_rburst_ok, dcache_raddr_ok, dcache_rdata_ok;
wire dcache_wburst_ok, dcache_waddr_ok, dcache_wdata_ok;
//ar
wire [3 :0] d_arid;
wire [31:0] d_araddr;
wire [3 :0] d_arlen;
wire [2 :0] d_arsize;
wire [1 :0] d_arburst;
wire [1 :0] d_arlock;
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
wire [3 :0] d_awlen;
wire [2 :0] d_awsize;
wire [1 :0] d_awburst;
wire [1 :0] d_awlock;
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

cpu_hexu cpu_0(
    .clk        (cpu_clk  ),
    .rst        (~aresetn  ),
    
    .i_addr       (cpu_i_addr       ),
    .i_read_data  (cpu_i_read_data  ),
    .i_req        (cpu_i_req        ),
    .i_ok         (cpu_i_ok         ),
    
    .d_write_data (cpu_d_write_data ),
    .d_addr       (cpu_d_addr       ),
    .d_read_data  (cpu_d_read_data  ),
    .d_req        (cpu_d_req        ),
    .d_wreq       (cpu_d_wreq       ),
    .d_wbyte      (cpu_d_wbyte      ),
    .d_ok         (cpu_d_ok         )
);

Icache icache(
    .clk    (cpu_clk  ),
    .rst    (~aresetn ),
    
    .insaddr (cpu_i_addr        ),
    .ins     (cpu_i_read_data   ),
    .req     (cpu_i_req         ),
    .miss    (cpu_i_miss        ),
    .ok      (cpu_i_ok          ),
    
    .sen     (icache_en         ),
    .addr_ok (icache_addr_ok    ),
    .data_ok (icache_data_ok    ),
    .burst   (icache_burst_ok   ),
    .addr    (icache_addr       ),
    .sdata   (icache_read_data  )
);

icache_to_axi #(1'b1) icache_to_axi_0 (
    .clk    (cpu_clk   ),
    .rstn   (aresetn),
    
    .en         (icache_en         ),
    .addr       (icache_addr       ),
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
    
    .wen      (dcache_wen         ),
    .sen      (dcache_en          ),
    .waddr_ok (dcache_waddr_ok    ),
    .wdata_ok (dcache_wdata_ok    ),
    .wburst   (dcache_wburst_ok   ),
    .wdata    (dcache_write_data  ),
    .waddr    (dcache_write_addr  ),
    .raddr_ok (dcache_raddr_ok    ),
    .rdata_ok (dcache_rdata_ok    ),
    .rburst   (dcache_rburst_ok   ),
    .raddr    (dcache_read_addr   ),
    .sdata    (dcache_read_data   )
);

dcache_to_axi #(1'b0) dcache_to_axi_0 (
    .clk    (cpu_clk   ),
    .rstn   (aresetn   ),
    
    .en         (dcache_en         ),
    .wen        (dcache_wen        ),
    .write_addr (dcache_write_addr ),
    .write_data (dcache_write_data ),
    .read_addr  (dcache_read_addr  ),
    .read_data  (dcache_read_data  ),
    .waddr_ok   (dcache_waddr_ok   ),
    .wdata_ok   (dcache_wdata_ok   ),
    .wburst_ok  (dcache_wburst_ok  ),
    .raddr_ok   (dcache_raddr_ok   ),
    .rdata_ok   (dcache_rdata_ok   ),
    .rburst_ok  (dcache_rburst_ok  ),
    
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
    .s_axi_wid      ({i_wid,     d_wid     }),
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
    
    .m_axi_awid     (awid    ),
    .m_axi_awaddr   (awaddr  ),
    .m_axi_awlen    (awlen   ),
    .m_axi_awsize   (awsize  ),
    .m_axi_awburst  (awburst ),
    .m_axi_awlock   (awlock  ),
    .m_axi_awcache  (awcache ),
    .m_axi_awprot   (awprot  ),
    .m_axi_awqos    (        ),
    .m_axi_awvalid  (awvalid ),
    .m_axi_awready  (awready ),
    .m_axi_wid      (wid     ),
    .m_axi_wdata    (wdata   ),
    .m_axi_wstrb    (wstrb   ),
    .m_axi_wlast    (wlast   ),
    .m_axi_wvalid   (wvalid  ),
    .m_axi_wready   (wready  ),
    .m_axi_bid      (bid     ),
    .m_axi_bresp    (bresp   ),
    .m_axi_bvalid   (bvalid  ),
    .m_axi_bready   (bready  ),
    .m_axi_arid     (arid    ),
    .m_axi_araddr   (araddr  ),
    .m_axi_arlen    (arlen   ),
    .m_axi_arsize   (arsize  ),
    .m_axi_arburst  (arburst ),
    .m_axi_arlock   (arlock  ),
    .m_axi_arcache  (arcache ),
    .m_axi_arprot   (arprot  ),
    .m_axi_arqos    (        ),
    .m_axi_arvalid  (arvalid ),
    .m_axi_arready  (arready ),
    .m_axi_rid      (rid     ),
    .m_axi_rdata    (rdata   ),
    .m_axi_rresp    (rresp   ),
    .m_axi_rlast    (rlast   ),
    .m_axi_rvalid   (rvalid  ),
    .m_axi_rready   (rready  )
);

endmodule