`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/05 14:34:39
// Design Name: 
// Module Name: xaddr
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


module xaddr(
//cpu
input [31:0] cpu_addr,
input [31:0] cpu_din,
output [31:0] cpu_data,
input cpu_req,
input cpu_wreq,
input [3:0] cpu_wbyte,
output cpu_ok,
//cache
output [31:0] cache_addr,
output [31:0] cache_din,
input [31:0] cache_data,
output cache_req,
output cache_wreq,
output [3:0] cache_wbyte,
input cache_ok,
//uncache
output [31:0] uncache_addr,
output [31:0] uncache_din,
input [31:0] uncache_data,
output uncache_req,
output uncache_wreq,
output [3:0] uncache_wbyte,
input uncache_ok
    );

wire zhuan;

assign zhuan=(cpu_addr[31:16]==16'h1faf);

assign cache_addr  =zhuan?  32'b0  :  cpu_addr ;
assign cache_din   =zhuan?  32'b0  :  cpu_din  ;
assign cache_req   =zhuan?      0  :  cpu_req  ;
assign cache_wreq  =zhuan?      0  :  cpu_wreq ;
assign cache_wbyte =zhuan?      0  :  cpu_wbyte;
assign uncache_addr  =(~zhuan)?  32'b0  :  cpu_addr ;
assign uncache_din   =(~zhuan)?  32'b0  :  cpu_din  ;
assign uncache_req   =(~zhuan)?      0  :  cpu_req  ;
assign uncache_wreq  =(~zhuan)?      0  :  cpu_wreq ;
assign uncache_wbyte =(~zhuan)?      0  :  cpu_wbyte;

assign cpu_ok=cache_ok|uncache_ok;
assign cpu_data=zhuan?uncache_data:cache_data;

endmodule
