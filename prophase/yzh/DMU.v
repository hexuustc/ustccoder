`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/14 18:05:54
// Design Name: 
// Module Name: DMU
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


module dmu
   #(parameter WIDTH = 32) 	//数据宽度
   (output reg [WIDTH-1:0] hi, 		//运算结果
   output reg [WIDTH-1:0] lo,
   input [WIDTH-1:0] a,b,		//两操作数
   input [3:0] m,				//操作类型
   input en
   );

always @(*)
if(en)
case (m)
   4'b0000:begin        //乘
       {hi,lo}=a*b;
       end
   4'b0001:begin       //除
       lo=a/b;
       hi=a-b*lo;
       end
   4'b1000:begin        //无符号乘
       {hi,lo}=a*b;
       end
   4'b1001:begin       //无符号除
       lo=a/b;
       hi=a-b*lo;
       end
   default:begin hi=0;lo=0;end  //其他
endcase
endmodule
