`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/16 10:05:32
// Design Name: 
// Module Name: sign_extender
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


module sign_extender
#(parameter WIDTH = 32)
(input [WIDTH/2-1:0] in,
output [WIDTH-1:0] out
    );
assign out = {{16{in[WIDTH/2-1]}}, in};
endmodule
