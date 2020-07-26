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
   output reg stall,
   input [WIDTH-1:0] a,b,		//两操作数
   input [3:0] m,				//操作类型
   input clk,
   input [1:0] div_begin
   );
wire [63:0] mult,umult,div,udiv;
reg [3:0] m1,m2,m3,m4,m5;
reg [5:0] counter;

initial counter=0;
initial stall=0;

always@(posedge clk)
begin
    if(div_begin==1) counter<=30;
    else if(div_begin==2) counter<=28;
    //else if(div_begin==3) counter<=24;
    else if(counter!=0) counter<=counter-1;
end

always@(*)
begin
    if(div_begin) stall=1;
    else if(counter) stall=1;
    else stall=0;
end

always @ (posedge clk)
begin
if(stall)
begin
    m1<=m1;
    m2<=m2;
    m3<=m3;
    m4<=m4;
    m5<=m5;
end
else
begin
m1<=m;
m2<=m1;
m3<=m2;
m4<=m3;
m5<=m4;
end
end
mult_gen_0 MM(.CLK(clk),
           .A(a),
           .B(b),
           .P(mult));
mult_gen_1 UMM(.CLK(clk),
           .A(a),
           .B(b),
           .P(umult));
div_gen_0 DV(.s_axis_divisor_tdata(b),
             .s_axis_divisor_tvalid(1),
             .s_axis_dividend_tdata(a),
             .s_axis_dividend_tvalid(1),
             .m_axis_dout_tdata(div),
             .aclk(clk));//dmu反掉了
div_gen_1 DV1(.s_axis_divisor_tdata(b),
             .s_axis_divisor_tvalid(1),
             .s_axis_dividend_tdata(a),
             .s_axis_dividend_tvalid(1),
             .m_axis_dout_tdata(udiv),
             .aclk(clk));//dmu反掉了
always @(*)
case (m5)
   4'b0101:begin        //乘
       hi=mult[63:32];lo=mult[31:0];
       end
   4'b1011:begin       //除
       lo=div[63:32];hi=div[31:0];
       end
   4'b0110:begin        //无符号乘
       hi=umult[63:32];lo=umult[31:0];
       end
   4'b0111:begin       //无符号除
       lo=udiv[63:32];hi=udiv[31:0];
       end
endcase

endmodule
