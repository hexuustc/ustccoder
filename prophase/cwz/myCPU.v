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
wire        inst_req  ;
wire        inst_wr   ;
wire [31:0] inst_addr ;
wire [1 :0] inst_size ;
wire [31:0] inst_wdata;
wire [31:0] inst_rdata;
wire        inst_data_ok;
wire        inst_addr_ok;
//for data
wire        data_req  ;
wire        data_wr   ;
wire [31:0] data_addr ;
wire [1 :0] data_size ;
wire [31:0] data_wdata;
wire [31:0] data_rdata;
wire        data_data_ok;
wire        data_addr_ok;

wire [1 :0] do_size_r;
wire [31:0] do_addr_r;
wire [3 :0] rstrb;
wire        inst_en ;
wire        inst_wen;
wire        data_en ;
wire        data_wen;

assign inst_en = inst_req & ~inst_wr; //read instuction request
assign inst_wen = inst_req & inst_wr; //write instruction request
assign data_en = data_req & ~inst_wr; //read data request
assign data_wen = data_req & data_wr; //write data request

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
        R_NO_TASK: r_next_state = data_en ? R_DATA_ADDR_HANDSHAKE :
                                  inst_en ? R_INST_ADDR_HANDSHAKE : r_state;
        R_INST_ADDR_HANDSHAKE: r_next_state = arready      ? R_INST_DATA_HANDSHAKE : r_state;
        R_INST_DATA_HANDSHAKE: r_next_state = ~rvalid      ? r_state:
                                              data_en ? R_DATA_ADDR_HANDSHAKE :
                                              inst_en ? R_INST_ADDR_HANDSHAKE : R_NO_TASK;
        R_DATA_ADDR_HANDSHAKE: r_next_state = arready      ? R_DATA_DATA_HANDSHAKE : r_state;
        R_DATA_DATA_HANDSHAKE: r_next_state = ~rvalid      ? r_state:
                                              data_en ? R_DATA_ADDR_HANDSHAKE :
                                              inst_en ? R_INST_ADDR_HANDSHAKE : R_NO_TASK;
        default: r_next_state = R_NO_TASK;
    endcase
end

//read address channel
assign arid    = {3'b000, r_state[1]};    //1 means read data, 0 means read instruction
assign araddr  = arid[0] ? data_addr: inst_addr; //address from byte to word
assign arsize  = 3'b010;        //4 bytes in transfer
assign arvalid = !r_state[2] & !r_state[0];    //r_state[0] = 0 means read addr handshake, 1 means read data handshake
                                               //r_state[2] = 1 means have no task, 0 means have task
assign arcache = 4'b0000;
assign arprot  = 3'b000;
assign arlock  = 2'b00;
assign arlen   = 4'b0000;
assign arburst = 2'b01;

//read data channel
assign rstrb   = do_size_r==2'd0 ? 4'b0001<<do_addr_r[1:0] :
                do_size_r==2'd1 ? 4'b0011<<do_addr_r[1:0] : 4'b1111;
assign inst_rdata[31:24] = rid[0] ? 0 : rstrb[3] ? rdata[31:24] : 0; //read instruction
assign inst_rdata[23:16] = rid[0] ? 0 : rstrb[2] ? rdata[23:16] : 0;
assign inst_rdata[15: 8] = rid[0] ? 0 : rstrb[1] ? rdata[15: 8] : 0;
assign inst_rdata[7 : 0] = rid[0] ? 0 : rstrb[0] ? rdata[7 : 0] : 0;
assign data_rdata = rid[0] ? rdata : 0; //read data
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
        W_NO_TASK: w_next_state = data_wen ? W_DATA_NEITHER_OK :
                                  inst_wen ? W_INST_NEITHER_OK : w_state;
        W_INST_NEITHER_OK: w_next_state = awready ?
                                              wready  ? W_INST_RESP : W_INST_ADDR_OK
                                          :
                                              wready  ? W_INST_DATA_OK : w_state;
        W_INST_ADDR_OK: w_next_state = wready  ? W_INST_RESP : w_state;
        W_INST_DATA_OK: w_next_state = awready ? W_INST_RESP : w_state;
        W_INST_RESP   : w_next_state = ~bvalid ? w_state     :
                                       data_wen ? W_DATA_NEITHER_OK :
                                       inst_wen ? W_INST_NEITHER_OK : W_NO_TASK;
        W_DATA_NEITHER_OK: w_next_state = awready ?
                                              wready  ? W_DATA_RESP : W_DATA_ADDR_OK
                                          :
                                              wready  ? W_DATA_DATA_OK : w_state;
        W_DATA_ADDR_OK: w_next_state = wready  ? W_DATA_RESP : w_state;
        W_DATA_DATA_OK: w_next_state = awready ? W_DATA_RESP : w_state;
        W_DATA_RESP   : w_next_state = ~bvalid ? w_state     :
                                       data_wen ? W_DATA_NEITHER_OK :
                                       inst_wen ? W_INST_NEITHER_OK : W_NO_TASK;
        default : w_next_state = W_NO_TASK;                               
    endcase
end

//write address channel
assign awid    = {3'b000, w_state[2]}; //1 means write data, 0 means write instruction
assign awaddr  = awid[0] ? data_addr : inst_addr;
assign awvalid = !w_state[3] & !w_state[0]; // address handshake has not finished
assign awlen   = 4'b0000;
assign awburst = 2'b01;
assign awcache = 4'b0000;
assign awprot  = 3'b000;
assign awlock  = 2'b00;
assign awsize  = 3'b010;

//write data channel
assign wid     = {3'b000, w_state[2]};
assign wdata   = wid[0] ? data_wdata : inst_wdata;
assign wvalid  = !w_state[3] & !w_state[1]; //data handshake has not finnished
assign wstrb   = do_size_r==2'd0 ? 4'b0001<<do_addr_r[1:0] :
                do_size_r==2'd1 ? 4'b0011<<do_addr_r[1:0] : 4'b1111;
assign wlast   = !w_state[3] & !w_state[1]; // Temporarily, all write burst's length is 1.

//write response channel
assign bready  = w_state[1] & w_state[0];

assign do_size_r = wid[0] ? data_size :inst_size;
assign do_addr_r = wid[0] ? data_addr :inst_addr;
assign inst_data_ok = (r_state == R_INST_DATA_HANDSHAKE & rvalid) | (w_state == W_INST_RESP & bvalid);
assign inst_addr_ok = (r_state == R_INST_ADDR_HANDSHAKE & arready) | 
                            ((w_state == W_INST_NEITHER_OK & awready & wready) | (w_state == W_INST_ADDR_OK & wready) | (w_state == W_INST_DATA_OK & awready));
assign data_data_ok = (r_state == R_DATA_DATA_HANDSHAKE & rvalid) | (w_state == W_DATA_RESP & bvalid);
assign data_addr_ok = (r_state == R_DATA_ADDR_HANDSHAKE & arready) | 
                           ((w_state == W_DATA_NEITHER_OK & awready & wready) | (w_state == W_DATA_ADDR_OK & wready) | (w_state == W_DATA_DATA_OK & awready));

//assign inst_req = 1;
//assign inst_wr = ~inst_addr_ok;
//assign inst_addr = 32'b0;
//assign inst_size = 2'b10;
//assign inst_wdata = 32'b0;

//assign data_req = 0;
//assign data_wr = 0;
//assign data_addr = 32'b10000;
//assign data_size = 2'b10;
//assign data_wdata = 32'b0;

cpu mycpu(
    .int    (ext_int ),
    
    .clk    (aclk    ),
    .resetn (aresetn ),
    
    .inst_req     (inst_req    ),
    .inst_wr      (inst_wr     ),
    .inst_addr    (inst_addr   ),
    .inst_size    (inst_size   ),
    .inst_wdata   (inst_wdata  ),
    .inst_rdata   (inst_rdata  ),
    .inst_data_ok (inst_data_ok),
    .inst_addr_ok (inst_addr_ok),
    
    .data_req     (data_req    ),
    .data_wr      (data_wr     ),
    .data_addr    (data_addr   ),
    .data_size    (data_size   ),
    .data_wdata   (data_wdata  ),
    .data_rdata   (data_rdata  ),
    .data_data_ok (data_data_ok),
    .data_addr_ok (data_addr_ok),
    
    .debug_wb_pc       (debug_wb_pc        ),
    .debug_wb_rf_wen   (debug_wb_pcrf_wen  ),
    .debug_wb_rf_wnum  (debug_wb_pcrf_wnum ),
    .debug_wb_rf_wdata (debug_wb_pcrf_wdata)
);

endmodule
