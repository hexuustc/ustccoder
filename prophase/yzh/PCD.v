`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/27 19:25:18
// Design Name: 
// Module Name: PCD
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


module PCD(
input clk,
input rst,
input pcwe,
input [31:0] in,
output reg [31:0] out
    );
always @ (posedge clk or posedge rst)
if(rst) out<=32'b0;
else if(pcwe) out<=in;
else out<=out;
endmodule
