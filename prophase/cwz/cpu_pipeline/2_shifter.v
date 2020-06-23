`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/16 10:22:17
// Design Name: 
// Module Name: 2_shifter
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


module shifter_0
#(parameter WIDTH = 32)(
input [WIDTH-1:0] in,
output [WIDTH-1:0] out
    );
    
    assign out = {in[WIDTH-3:0],2'b00};
endmodule

module shifter_1
#(parameter WIDTH = 26)(
input [WIDTH-1:0] in,
output [WIDTH+1:0] out
    );
    
    assign out = {in[WIDTH-1:0],2'b00};
endmodule 
