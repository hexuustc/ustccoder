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
//for instruction
wire        inst_sram_en   ;
wire [4 :0] inst_sram_wen  ;
wire [31:0] inst_sram_addr ;
wire [31:0] inst_sram_wdata;
wire [31:0] inst_sram_rdata;

//for data
wire        data_sram_en   ;
wire [4 :0] data_sram_wen  ;
wire [31:0] data_sram_addr ;
wire [31:0] data_sram_wdata;
wire [31:0] data_sram_rdata;

reg [2 :0] r_state, r_next_state;
localparam R_NO_TASK             = 3'b101;
localparam R_INST_ADDR_HANDSHAKE = 3'b000;
localparam R_INST_DATA_HANDSHAKE = 3'b001;
localparam R_DATA_ADDR_HANDSHAKE = 3'b010;
localparam R_DATA_DATA_HANDSHAKE = 3'b011;

//read channel
always @(posedge aclk)
begin
    r_state <= aresetn ? r_next_state : R_NO_TASK;        
end

always @(*)
begin
    case (r_state)
        R_NO_TASK: r_next_state = data_sram_en ? R_DATA_ADDR_HANDSHAKE :
                                  inst_sram_en ? R_INST_ADDR_HANDSHAKE : r_state;
        R_INST_ADDR_HANDSHAKE: r_next_state = arready      ? R_INST_DATA_HANDSHAKE : r_state;
        R_INST_DATA_HANDSHAKE: r_next_state = ~rvalid      ? r_state:
                                              data_sram_en ? R_DATA_ADDR_HANDSHAKE :
                                              inst_sram_en ? R_INST_ADDR_HANDSHAKE : R_NO_TASK;
        R_DATA_ADDR_HANDSHAKE: r_next_state = arready      ? R_DATA_DATA_HANDSHAKE : r_state;
        R_DATA_DATA_HANDSHAKE: r_next_state = ~rvalid      ? r_state:
                                              data_sram_en ? R_DATA_ADDR_HANDSHAKE :
                                              inst_sram_en ? R_INST_ADDR_HANDSHAKE : R_NO_TASK;
        default: r_next_state = R_NO_TASK;
    endcase
end

//read address channel
assign arid    = {3'b000, r_state[1]};    //1 means read data, 0 means read instruction
assign araddr  = arid ? {2'b00, data_sram_addr[31:2]}: {2'b00, inst_sram_addr[31:2]}; //address from byte to word
assign arsize  = 3'b010;        //4 bytes in transfer
assign arvalid = !r_state[2] & !r_state[0];    //r_state[0] = 0 means read addr handshake, 1 means read data handshake
                                               //r_state[2] = 1 means have no task, 0 means have task
assign arcache = 4'b0000;
assign arprot  = 3'b000;
assign arlock  = 2'b00;
assign arlen   = 4'b0000;
assign arburst = 2'b01;

//read data channel
assign inst_sram_rdata = rid ? 0 : rdata; //read instruction
assign data_sram_rdata = rid ? rdata : 0; //read data
assign rready = !r_state[2] & r_state[0];

reg [3 :0] w_state, w_next_state;
localparam W_NO_TASK         = 4'b1000;
localparam W_INST_NEITHER_OK = 4'b0000;
localparam W_INST_ADDR_OK    = 4'b0001;
localparam W_INST_DATA_OK    = 4'b0010;
localparam W_INST_RESP       = 4'b0011;
localparam W_DATA_NEITHER_OK = 4'b0100;
localparam W_DATA_ADDR_OK    = 4'b0101;
localparam W_DATA_DATA_OK    = 4'b0110;
localparam W_DATA_RESP       = 4'b0111;

always @(posedge aclk)
begin
    w_state <= aresetn ? w_next_state : W_NO_TASK;
end

always @(*)
begin
    case (w_state)
        W_NO_TASK: w_next_state = data_sram_wen ? W_DATA_NEITHER_OK :
                                  inst_sram_wen ? W_INST_NEITHER_OK : w_state;
        W_INST_NEITHER_OK: w_next_state = awready ?
                                              wready  ? W_INST_RESP : W_INST_ADDR_OK
                                          :
                                              wready  ? W_INST_DATA_OK : w_state;
        W_INST_ADDR_OK: w_next_state = wready  ? W_INST_RESP : w_state;
        W_INST_DATA_OK: w_next_state = awready ? W_INST_RESP : w_state;
        W_INST_RESP   : w_next_state = ~bvalid ? w_state     :
                                       data_sram_wen ? W_DATA_NEITHER_OK :
                                       inst_sram_wen ? W_INST_NEITHER_OK : W_NO_TASK;
        W_DATA_NEITHER_OK: w_next_state = awready ?
                                              wready  ? W_DATA_RESP : W_DATA_ADDR_OK
                                          :
                                              wready  ? W_DATA_DATA_OK : w_state;
        W_DATA_ADDR_OK: w_next_state = wready  ? W_DATA_RESP : w_state;
        W_DATA_DATA_OK: w_next_state = awready ? W_DATA_RESP : w_state;
        W_DATA_RESP   : w_next_state = ~bvalid ? w_state     :
                                       data_sram_wen ? W_DATA_NEITHER_OK :
                                       inst_sram_wen ? W_INST_NEITHER_OK : W_NO_TASK;
        default : w_next_state = W_NO_TASK;                               
    endcase
end

//write address channel
assign awid    = {3'b000, w_state[2]};
assign awaddr  = awid ? {2'b00, data_sram_addr[31:2]} : {2'b00, inst_sram_addr[31:2]};
assign awvalid = !w_state[3] & !w_state[0];
assign awlen   = 4'b0000;
assign awburst = 2'b01;
assign awcache = 4'b0000;
assign awprot  = 3'b000;
assign awlock  = 2'b00;
assign awsize  = 3'b010;

//write data channel
assign wid     = {3'b000, w_state[2]};
assign wdata   = wid ? data_sram_wdata : inst_sram_wdata;
assign wvalid  = !w_state[3] & !w_state[1];
assign wstrb   = 4'hf;
assign wlast   = !w_state[3] & !w_state[1];

//write response channel
assign bready  = w_state[1] & w_state[0];

endmodule