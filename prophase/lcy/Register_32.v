`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/30 17:46:53
// Design Name: 
// Module Name: register
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
module  Register_32
    #(parameter WIDTH = 32, 
    RST_VALUE = 0)
    (input  clk, rst, en,
    input  [WIDTH-1 : 0]  d,
    output reg  [WIDTH-1 : 0] q);

always @(posedge clk, posedge rst)
    if (rst) q <= RST_VALUE;
    else  if (en)
        q <= d;
endmodule