`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/08 11:57:13
// Design Name: 
// Module Name: register_file
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
module Registerfile				//32 x WIDTH寄存器堆
    #(parameter WIDTH = 32) 	//数据宽度
    (input clk,						//时钟（上升沿有效）
    input [4:0] ra0,				//读端口0地址
    output [WIDTH-1:0] rd0, 	//读端口0数据
    input [4:0] ra1, 				//读端口1地址
    output [WIDTH-1:0] rd1, 	//读端口1数据
    input [4:0] ra_debug,       //调试读端口地址
    output [WIDTH-1:0] rd_debug,     //调试读端口数据
    input [4:0] wa, 				//写端口地址
    input we,					//写使能，高电平有效
    input [WIDTH-1:0] wd 		//写端口数据
    );
    
    reg [WIDTH-1:0]REG_Files[0:31];
    
    always@(posedge clk )
	begin
		if(we && wa!=0)
		    REG_Files[wa] <= wd;
		else
		    REG_Files[wa] <= REG_Files[wa];
	end
	
	assign  rd0= (ra0 == 0) ? 0 :REG_Files[ra0];
    assign  rd1= (ra1 == 0) ? 0 :REG_Files[ra1];
    assign  rd_debug= (ra_debug == 0) ? 0 :REG_Files[ra_debug];
endmodule

