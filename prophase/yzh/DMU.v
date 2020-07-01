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
   output reg ff,
   input [WIDTH-1:0] a,b,		//两操作数
   input [3:0] m,				//操作类型
   input en,
   input clk
   );
wire [63:0] mult,umult,div,udiv;
reg [2:0] count;
reg len;
always @ (posedge clk)
begin
if(en & ~len) begin count<=0;ff<=1; end
count<=count+1;
len<=en;
if(count==3'b100) ff<=0;
end
mult_gen_0 MM(.CLK(clk),
           .A(a),
           .B(b),
           .P(mult));
mult_gen_1 UMM(.CLK(clk),
           .A(a),
           .B(b),
           .P(umult));
div_gen_0 DV(.s_axis_divisor_tdata(a),
             .s_axis_divisor_tvalid(1),
             .s_axis_dividend_tdata(b),
             .s_axis_dividend_tvalid(1),
             .m_axis_dout_tdata(div),
             .aclk(clk));
div_gen_1 DV1(.s_axis_divisor_tdata(a),
             .s_axis_divisor_tvalid(1),
             .s_axis_dividend_tdata(b),
             .s_axis_dividend_tvalid(1),
             .m_axis_dout_tdata(udiv),
             .aclk(clk));
always @(*)
if(en)
case (m)
   4'b0000:begin        //乘
       hi=mult[63:32];lo=mult[31:0];
       end
   4'b0001:begin       //除
       lo=div[63:32];hi=div[31:0];
       end
   4'b1000:begin        //无符号乘
       hi=umult[63:32];lo=umult[31:0];
       end
   4'b1001:begin       //无符号除
       lo=udiv[63:32];hi=udiv[31:0];
       end
   default:begin hi=0;lo=0;end  //其他
endcase
endmodule
