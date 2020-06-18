`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/14 17:35:00
// Design Name: 
// Module Name: ALUT
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


module alut
   #(parameter WIDTH = 32) 	//数据宽度
   (output reg [WIDTH-1:0] y, 		//运算结果
   output reg zf, 					//零标志
   output reg cf, 					//进位/借位标志
   output reg of, 					//溢出标志
   input [WIDTH-1:0] a,b,		//两操作数
   input [3:0] m				//操作类型
   );

always @(*)
case (m)
   4'b0000:begin        //加
       {cf,y}=a+b;
       of = (~a[WIDTH-1] & ~b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & b[WIDTH-1] & ~y[WIDTH-1]);
       zf = ~| y;
       end
   4'b0001:begin       //减
       {cf,y}=a-b;
       of = (~a[WIDTH-1] & b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & ~b[WIDTH-1] & ~y[WIDTH-1]) ;
       zf = ~| y;
       end
   4'b0010:begin y=a&b;cf=0;zf=0;of=0;end //与
   4'b0011:begin y=a|b;cf=0;zf=0;of=0;end //或
   4'b0100:begin y=a^b;cf=0;zf=0;of=0;end //异或
   4'b0101:begin y=~(a|b);cf=0;zf=0;of=0;end //或非
   4'b0110:begin y=b<<a;cf=0;zf=0;of=0;end //左移
   4'b0111:begin y=b>>a;cf=0;zf=0;of=0;end //右移
   4'b1010:begin y=(a<b)?1:0;cf=0;zf=0;of=0;end  //小于则置一
   4'b1110:begin y=(a>b)?1:0;cf=0;zf=0;of=0;end  //大于则置一
   4'b1011:begin y=(a<b)?1:0;cf=0;zf=0;of=0;end  //无符号小于则置一
   4'b1000:begin        //无符号加
       {cf,y}=a+b;
       of = 0;
       zf = 0;
       end
   4'b1001:begin       //无符号减
       {cf,y}=a-b;
       of = 0;
       zf = ~| y;
       end
   default:begin y=0;cf=0;zf=0;of=0;end  //其他
endcase
endmodule
