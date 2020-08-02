`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/16 15:07:19
// Design Name: 
// Module Name: mux
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


module mux
#(parameter WIDTH = 32)(
    input [WIDTH-1:0]in_0,in_1,
    input choose,
    output [WIDTH-1:0]out
    );
    
assign out = choose ? in_1 : in_0;
endmodule

//module mux_3
//#(parameter WIDTH = 32)(
//    input [WIDTH-1:0]in_0,in_1,in_2,
//    input [1:0] choose,
//    output [WIDTH-1:0]out
//    );
    
//assign out = choose[1]?in_2:(choose[0]?in_1:in_0);
//endmodule

module mux_4
#(parameter WIDTH = 32)(
    input [WIDTH-1:0]in_0,in_1,in_2,in_3,
    input [1:0] choose,
    output [WIDTH-1:0]out
    );
    
assign out = choose[1]?(choose[0]?in_3:in_2):(choose[0]?in_1:in_0);
endmodule