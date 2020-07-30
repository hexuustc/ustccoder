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
wire [63:0] umult,udiv;
reg [63:0] mult,div;
reg [WIDTH-1:0] a_abs,b_abs;
reg [31:0] r_hi,r_lo;
reg [3:0] m1,m2,m3,m4,m5;
reg [5:0] counter;
reg [1:0] oppo,oppo1,oppo2,oppo3,oppo4,oppo5;
reg oppo_h,oppo_l;

initial counter=0;
initial stall=0;

always@(posedge clk)
begin
    if(div_begin==1) counter<=28;
    else if(counter!=0) counter<=counter-1;
    else counter <= counter;
end

always@(*)
begin
    if(div_begin) stall=1;
    else if(counter) stall=1;
    else stall=0;
end

always@(*)
begin
    if((m==11)||(m==5))
    begin
        if(a[WIDTH-1]) a_abs=-a; else a_abs=a;
        if(b[WIDTH-1]) b_abs=-b; else b_abs=b;
    end
    else
    begin
        a_abs=a;
        b_abs=b;
    end
end

always@(*)
begin
    if((m==11)&&a[WIDTH-1]) oppo_h=1;//除法余数反转
    else oppo_h=0;
    
    if((m==11)&&(a[WIDTH-1]!=b[WIDTH-1])) oppo_l=1;//乘法结果，除法商反转
    else if((m==5)&&(a[WIDTH-1]!=b[WIDTH-1])) oppo_l=1;
    else oppo_l=0;
    
    if(~oppo_h&&~oppo_l) oppo=0;//总判断
    else if(oppo_h&&~oppo_l) oppo=1;
    else if(~oppo_h&&oppo_l) oppo=2;
    else if(oppo_h&&oppo_l) oppo=3;
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

always @ (posedge clk)
begin
    if(stall)
    begin
        oppo1<=oppo1;
        oppo2<=oppo2;
        oppo3<=oppo3;
        oppo4<=oppo4;
        oppo5<=oppo5;
    end
    else
    begin
        oppo1<=oppo;
        oppo2<=oppo1;
        oppo3<=oppo2;
        oppo4<=oppo3;
        oppo5<=oppo4;
    end
end

mult_gen_1 UMM(.CLK(clk),
           .A(a_abs),
           .B(b_abs),
           .P(umult));
div_gen_1 DV1(.s_axis_divisor_tdata(b_abs),
             .s_axis_divisor_tvalid(1),
             .s_axis_dividend_tdata(a_abs),
             .s_axis_dividend_tvalid(1),
             .m_axis_dout_tdata(udiv),
             .aclk(clk));//dmu反掉了

always @(*)
case (m5)
   4'b0101:begin        //乘
       if((oppo5==2)||(oppo5==3)) mult=-umult; else mult=umult;
       hi=mult[63:32];lo=mult[31:0];
       end
   4'b1011:begin       //除
       if((oppo5==2)||(oppo5==3)) div[63:32]=-udiv[63:32]; else div[63:32]=udiv[63:32];
       if((oppo5==1)||(oppo5==3)) div[31:0]=-udiv[31:0]; else div[31:0]=udiv[31:0];
       lo=div[63:32];hi=div[31:0];
       end
   4'b0110:begin        //无符号乘
       mult=umult; div=udiv;
       hi=umult[63:32];lo=umult[31:0];
       end
   4'b0111:begin       //无符号除
       mult=umult; div=udiv;
       lo=udiv[63:32];hi=udiv[31:0];
       end
    default: begin hi=r_hi; lo=r_lo; mult=0; div=0; end
endcase

always@(posedge clk)
begin
    r_hi<=hi;
    r_lo<=lo;
end

endmodule
