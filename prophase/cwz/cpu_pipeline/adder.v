`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/16 10:53:51
// Design Name: 
// Module Name: adder
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


module four_adder
#(parameter WIDTH = 32)(
    input [WIDTH-1:0]in,
    output [WIDTH-1:0]out
    );

assign out = in + 4;
endmodule

module adder
#(parameter WIDTH = 32)(
    input [WIDTH-1:0]in_0, in_1,
    output [WIDTH-1:0]out
    );

assign out = in_0 + in_1;
endmodule
