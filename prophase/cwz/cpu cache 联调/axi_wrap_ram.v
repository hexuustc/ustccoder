/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

module axi_wrap_ram(
  input         aclk,
  input         aresetn,
  //ar
  input  [3 :0] axi_arid   ,
  input  [31:0] axi_araddr ,
  input  [7 :0] axi_arlen  ,
  input  [2 :0] axi_arsize ,
  input  [1 :0] axi_arburst,
  input  [1 :0] axi_arlock ,
  input  [3 :0] axi_arcache,
  input  [2 :0] axi_arprot ,
  input         axi_arvalid,
  output        axi_arready,
  //r
  output [3 :0] axi_rid    ,
  output [31:0] axi_rdata  ,
  output [1 :0] axi_rresp  ,
  output        axi_rlast  ,
  output        axi_rvalid ,
  input         axi_rready ,
  //aw
  input  [3 :0] axi_awid   ,
  input  [31:0] axi_awaddr ,
  input  [7 :0] axi_awlen  ,
  input  [2 :0] axi_awsize ,
  input  [1 :0] axi_awburst,
  input  [1 :0] axi_awlock ,
  input  [3 :0] axi_awcache,
  input  [2 :0] axi_awprot ,
  input         axi_awvalid,
  output        axi_awready,
  //w
  input  [3 :0] axi_wid    ,
  input  [31:0] axi_wdata  ,
  input  [3 :0] axi_wstrb  ,
  input         axi_wlast  ,
  input         axi_wvalid ,
  output        axi_wready ,
  //b
  output [3 :0] axi_bid    ,
  output [1 :0] axi_bresp  ,
  output        axi_bvalid ,
  input         axi_bready 
);
//ram axi
//ar
wire [3 :0] ram_arid   ;
wire [31:0] ram_araddr ;
wire [7 :0] ram_arlen  ;
wire [2 :0] ram_arsize ;
wire [1 :0] ram_arburst;
wire [1 :0] ram_arlock ;
wire [3 :0] ram_arcache;
wire [2 :0] ram_arprot ;
wire        ram_arvalid;
wire        ram_arready;
//r
wire [3 :0] ram_rid    ;
wire [31:0] ram_rdata  ;
wire [1 :0] ram_rresp  ;
wire        ram_rlast  ;
wire        ram_rvalid ;
wire        ram_rready ;
//aw
wire [3 :0] ram_awid   ;
wire [31:0] ram_awaddr ;
wire [7 :0] ram_awlen  ;
wire [2 :0] ram_awsize ;
wire [1 :0] ram_awburst;
wire [1 :0] ram_awlock ;
wire [3 :0] ram_awcache;
wire [2 :0] ram_awprot ;
wire        ram_awvalid;
wire        ram_awready;
//w
wire [3 :0] ram_wid    ;
wire [31:0] ram_wdata  ;
wire [3 :0] ram_wstrb  ;
wire        ram_wlast  ;
wire        ram_wvalid ;
wire        ram_wready ;
//b
wire [3 :0] ram_bid    ;
wire [1 :0] ram_bresp  ;
wire        ram_bvalid ;
wire        ram_bready ;


// inst ram axi
blk_mem_gen_0 ram(
    .s_aclk         (aclk         ),
    .s_aresetn      (aresetn      ),

    //ar
    .s_axi_arid     (ram_arid     ),
    .s_axi_araddr   (ram_araddr   ),
    .s_axi_arlen    (ram_arlen    ),
    .s_axi_arsize   (ram_arsize   ),
    .s_axi_arburst  (ram_arburst  ),
    .s_axi_arvalid  (ram_arvalid  ),
    .s_axi_arready  (ram_arready  ),
    //r
    .s_axi_rid      (ram_rid      ),
    .s_axi_rdata    (ram_rdata    ),
    .s_axi_rresp    (ram_rresp    ),
    .s_axi_rlast    (ram_rlast    ),
    .s_axi_rvalid   (ram_rvalid   ),
    .s_axi_rready   (ram_rready   ),
    //aw
    .s_axi_awid     (ram_awid     ),
    .s_axi_awaddr   (ram_awaddr   ),
    .s_axi_awlen    (ram_awlen    ),
    .s_axi_awsize   (ram_awsize   ),
    .s_axi_awburst  (ram_awburst  ),
    .s_axi_awvalid  (ram_awvalid  ),
    .s_axi_awready  (ram_awready  ),
    //w
    .s_axi_wdata    (ram_wdata    ),
    .s_axi_wstrb    (ram_wstrb    ),
    .s_axi_wlast    (ram_wlast    ),
    .s_axi_wvalid   (ram_wvalid   ),
    .s_axi_wready   (ram_wready   ),
    //b
    .s_axi_bid      (ram_bid      ),
    .s_axi_bresp    (ram_bresp    ),
    .s_axi_bvalid   (ram_bvalid   ),
    .s_axi_bready   (ram_bready   )
);

//ar
assign ram_arid    = axi_arid   ;
assign ram_araddr  = axi_araddr ;
assign ram_arlen   = axi_arlen  ;
assign ram_arsize  = axi_arsize ;
assign ram_arburst = axi_arburst;
assign ram_arlock  = axi_arlock ;
assign ram_arcache = axi_arcache;
assign ram_arprot  = axi_arprot ;
assign ram_arvalid = axi_arvalid;
assign axi_arready = ram_arready;
//r
assign axi_rid    = axi_rvalid ? ram_rid   :  4'd0 ;
assign axi_rdata  = axi_rvalid ? ram_rdata : 32'd0 ;
assign axi_rresp  = axi_rvalid ? ram_rresp :  2'd0 ;
assign axi_rlast  = axi_rvalid ? ram_rlast :  1'd0 ;
assign axi_rvalid = ram_rvalid;
assign ram_rready = axi_rready;
//aw
assign ram_awid    = axi_awid   ;
assign ram_awaddr  = axi_awaddr ;
assign ram_awlen   = axi_awlen  ;
assign ram_awsize  = axi_awsize ;
assign ram_awburst = axi_awburst;
assign ram_awlock  = axi_awlock ;
assign ram_awcache = axi_awcache;
assign ram_awprot  = axi_awprot ;
assign ram_awvalid = axi_awvalid;
assign axi_awready = ram_awready;
//w
assign ram_wid    = axi_wid    ;
assign ram_wdata  = axi_wdata  ;
assign ram_wstrb  = axi_wstrb  ;
assign ram_wlast  = axi_wlast  ;
assign ram_wvalid = axi_wvalid;
assign axi_wready = ram_wready ;
//b
assign axi_bid    = axi_bvalid ? ram_bid   : 4'd0 ;
assign axi_bresp  = axi_bvalid ? ram_bresp : 2'd0 ;
assign axi_bvalid = ram_bvalid ;
assign ram_bready = axi_bready;
endmodule
