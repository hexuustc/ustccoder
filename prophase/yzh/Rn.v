`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/13 18:45:17
// Design Name: 
// Module Name: Rn
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


module Rn
#(parameter WIDTH = 32)
(clk,rst,in,out);
input clk,rst;
input [WIDTH-1:0] in;
output reg [WIDTH-1:0] out;

always @ (posedge clk or posedge rst)
if(rst) out<=0;
else out<=in;

endmodule
