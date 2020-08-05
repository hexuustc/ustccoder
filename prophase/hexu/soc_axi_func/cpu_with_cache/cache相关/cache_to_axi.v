`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 09:15:46
// Design Name: 
// Module Name: cache_to_axi
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


module icache_to_axi
#(parameter ID = 1'b0, BURST_BYTES = 64)
//ID = 1 means instruction, ID = 0 means data)
(
    input         clk,
    input         rstn,
    
    //cache interface
    input         en,
    input  [31:0] addr,
    output [31:0] read_data,
    output        addr_ok,
    output        data_ok,
    output        burst_ok,
    
    //axi interface
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
    output        bready
);

localparam R_NO_TASK = 2'b11;
localparam R_ADDR_HANDSHAKE = 2'b01;
localparam R_DATA_HANDSHAKE = 2'b10;

reg [1 :0] r_state, r_next_state;

always @(posedge clk)
begin
    r_state <= rstn ? r_next_state : R_NO_TASK;
end

reg rburst_ok;

always @(posedge clk)
begin
    rburst_ok <= rstn ? (r_state[1] & ~r_state[0] & rvalid & rready & rlast) : 0;
end

always @(*)
begin
    case (r_state)
        R_NO_TASK: r_next_state = en ? R_ADDR_HANDSHAKE : r_state;
        R_ADDR_HANDSHAKE: r_next_state = arready ? R_DATA_HANDSHAKE : r_state;
        R_DATA_HANDSHAKE: r_next_state = rburst_ok ? R_NO_TASK : r_state;
        default : r_next_state = R_NO_TASK;
    endcase
end

//read address channel
assign arid     = {3'b000, ID};
assign araddr   = ~r_state[1] & r_state[0] ? addr : 32'b0;
assign arlen    = (BURST_BYTES >> 2) - 1;
assign arsize   = 3'b010;
assign arburst  = 2'b10;
assign arlock   = 1'b00;
assign arcache  = 4'b1111;
assign arprot   = {2'b00, ID};
assign arvalid  = ~r_state[1] & r_state[0];

//read data channel
assign rready    = r_state[1] & ~r_state[0];
assign read_data = r_state[1] & ~r_state[0] ? rdata : 0;

//write address channel
assign awid     = {3'b000, ID};
assign awaddr   = 32'b0;
assign awlen    = (BURST_BYTES >> 2) - 1;
assign awsize   = 3'b010;
assign awburst  = 2'b10;
assign awlock   = 1'b00;
assign awcache  = 4'b1111;
assign awprot   = {2'b00, ID};
assign awvalid  = 1'b0;

//write data channel
assign wid    = {3'b000, ID};
assign wdata  = 32'b0;
assign wstrb  = 4'b0;
assign wlast  = 1'b0;
assign wvalid = 1'b0;

//write response channel
assign bready = 1'b0;

//cache ok signals
assign addr_ok  = ~r_state[1] & r_state[0] & arvalid & arready;
assign data_ok  = r_state[1] & ~r_state[0] & rvalid & rready;
assign burst_ok =  rburst_ok;
endmodule


module dcache_to_axi
#(parameter ID = 1'b0, BURST_BYTES = 64)
//ID = 1 means instruction, ID = 0 means data)
(
    input         clk,
    input         rstn,
    
    //cache interface
    input         en,
    input         wen,
    input  [31:0] write_addr,
    input  [31:0] read_addr,
    input  [31:0] write_data,
    output [31:0] read_data,
    output        waddr_ok,
    output        wdata_ok,
    output        wburst_ok,
    output        raddr_ok,
    output        rdata_ok,
    output reg    rburst_ok,
    
    //axi interface
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
    output        bready
);

localparam R_NO_TASK = 2'b11;
localparam R_ADDR_HANDSHAKE = 2'b01;
localparam R_DATA_HANDSHAKE = 2'b10;

reg [1 :0] r_state, r_next_state;

always @(posedge clk)
begin
    r_state <= rstn ? r_next_state : R_NO_TASK;
end

always @(*)
begin
    case (r_state)
        R_NO_TASK: r_next_state = en & ~wen ? R_ADDR_HANDSHAKE : r_state;
        R_ADDR_HANDSHAKE: r_next_state = arready ? R_DATA_HANDSHAKE : r_state;
        R_DATA_HANDSHAKE: r_next_state = rburst_ok ? R_NO_TASK : r_state;
        default : r_next_state = R_NO_TASK;
    endcase
end

//read address channel
assign arid     = {3'b000, ID};
assign araddr   = ~r_state[1] & r_state[0] ? read_addr : 32'b0;
assign arlen    = (BURST_BYTES >> 2) - 1;
assign arsize   = 3'b010;
assign arburst  = 2'b10;
assign arlock   = 1'b00;
assign arcache  = 4'b1111;
assign arprot   = {2'b00, ID};
assign arvalid  = ~r_state[1] & r_state[0];

//read data channel
assign rready    = r_state[1] & ~r_state[0];
assign read_data = r_state[1] & ~r_state[0] ? rdata : 0;

localparam W_NO_TASK =        2'b11;
localparam W_ADDR_HANDSHAKE = 2'b01;
localparam W_DATA_HANDSHAKE = 2'b10;
localparam W_RESP_HANDSHAKE = 2'b00;

reg [1 :0] w_state, w_next_state;
reg [3 :0] num; 
wire [3 :0] next_num;

always @(posedge clk)
begin
    w_state <= rstn ? w_next_state : W_NO_TASK;
    num <= rstn ? next_num : 0;
    rburst_ok <= rstn ? (r_state[1] & ~r_state[0] & rvalid & rready & rlast) : 0;
end

always @(*)
begin
    case (w_state)
        W_NO_TASK: w_next_state = en & wen ? W_ADDR_HANDSHAKE : w_state;
        W_ADDR_HANDSHAKE: w_next_state = awready ? W_DATA_HANDSHAKE : w_state;
        W_DATA_HANDSHAKE: w_next_state = (num == (BURST_BYTES >> 2) - 1) ? W_RESP_HANDSHAKE
                                                   : w_state;
        W_RESP_HANDSHAKE: w_next_state = bvalid ? W_NO_TASK : w_state;
    endcase
end

assign next_num = (w_state == W_DATA_HANDSHAKE) ? 
                wready ? num + 1 : num
                : 0;

//write address channel
assign awid     = {3'b000, ID};
assign awaddr   = ~w_state[1] & w_state[0] ? write_addr : 0;
assign awlen    = (BURST_BYTES >> 2) - 1;
assign awsize   = 3'b010;
assign awburst  = 2'b10;
assign awlock   = 1'b00;
assign awcache  = 4'b1111;
assign awprot   = {2'b00, ID};
assign awvalid  = ~w_state[1] & w_state[0];

//write data channel
assign wid    = {3'b000, ID};
assign wdata  = ~w_state[1] & w_state[0] ? write_data : 0;
assign wstrb  = 4'b1111;
assign wlast  = (num == (BURST_BYTES >> 2) - 1);
assign wvalid = w_state[1] & ~w_state[0];

//write response channel
assign bready = ~w_state[1] & ~w_state[0];

//cache ok signals
assign raddr_ok = ~r_state[1] & r_state[0] & arvalid & arready;
assign rdata_ok = r_state[1] & ~r_state[0] & rvalid & rready;

assign waddr_ok = ~w_state[1] & w_state[0] & awvalid & awready;
assign wdata_ok = w_state[1] & ~w_state[0] & wvalid & wready;
assign wburst_ok = ~w_state[1] & ~w_state[0] & bvalid & bready;

endmodule
