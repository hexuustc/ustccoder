`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/16 15:08:39
// Design Name: 
// Module Name: RF1
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


module register_file1				//32 x WIDTH寄存器堆
#(parameter WIDTH = 32) 	//数据宽度
(input clk,						//时钟（上升沿有效）
input [4:0] ra0,				//读端口0地址
output [WIDTH-1:0] rd0, 	//读端口0数据
input [4:0] ra1, 				//读端口1地址
output [WIDTH-1:0] rd1, 	//读端口1数据
input [4:0] wa, 				//写端口地址
input we,					//写使能，高电平有效
input [WIDTH-1:0] wd, 		//写端口数据
input alr,
input [WIDTH-1:0] pc
);
reg [WIDTH-1:0] r [31:0];
integer i=0;

  initial
  for(i=0;i<32;i=i+1)
  r[i]=0;//初始设置寄存器中所有数据都为0
  always @(posedge clk)
  begin
  if(we==1&&wa!=0) r[wa]<=wd;//同步写入
  if(alr) r[31]<=pc+4;
  end
  //如果写入地址不为0且写使能，则写入数据，
  //从而保证0地址的数据始终为0不被改变
  assign rd1=(ra1==wa)?wd:r[ra1];
  assign rd0=(ra0==wa)?wd:r[ra0];//异步输出
endmodule
