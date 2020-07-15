`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 16:26:40
// Design Name: 
// Module Name: Icache1
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


module Icache1
#(parameter tag_len    = 18,
  parameter suoyin_len = 8,
  parameter line_c     = 16,
  parameter line_len   = 4)
  (
    input clk,
    input rst,
    //对CPU
    input [31:0] insaddr,         //CPU访问地址
    input [31:0] din,             //CPU要写入的数据
    output reg [31:0] ins,       //读出的数据
    input req,                   //请求 无论读或写都要为1（1个周期）
    input wreq,                  //写请求（1个周期）
    input [3:0] wbyte,           //写字节使能，每一位对应1个字节，比如1000是要把din的高8位写入insaddr地址对应数据的高8位中
    output miss,                 //缺失信号
    output reg stall,            //stall为1时，应阻塞流水线
    output reg ok,               //读或写完成时，ok=1，持续一个周期
    //对总线
    output reg wen,              //写使能，写的时候一直为1
    output reg sen,              //使能，读和写的时候都为1
    input addr_ok,               
    input data_ok,
    input burst,
    output reg [31:0] wdata,    //向总线写的数据
    output [31:0] addr,         //读或写的地址
    input [31:0] sdata          //从总线读的数据
);

wire [suoyin_len - 1:0]    suoyin;
wire [tag_len - 1   :0]    tag   [3:0] ;
wire [1:0]                 lru   [3:0] ;
reg  [255:0]               v     [3:0] ;
reg  [255:0]               dir   [3:0] ;
reg  [3:0]                 wed   [15:0];
reg  [3:0]                 wet         ;
reg  [3:0]                 wel         ;
reg  [3:0]                 en          ;
wire [31            :0]    cdat  [3:0] [line_c-1      :0];
wire [line_len-1    :0]    linex       ;
wire [tag_len - 1   :0]    bj          ;
wire                       vg;
wire                       dirty;
wire [1:0]                 lruin [3:0] ;
reg  [3:0]                 lruc        ;
wire [31:0]                data        ;
reg                        wdx         ;
wire [31:0] addr0,addr1;
//数据通路
assign lruin[0]=lruc[0]?2'b00:(lru[0]+1);
assign lruin[1]=lruc[1]?2'b00:(lru[1]+1);
assign lruin[2]=lruc[2]?2'b00:(lru[2]+1);
assign lruin[3]=lruc[3]?2'b00:(lru[3]+1);

assign bj       = insaddr[31         : 32 - tag_len ];
assign suoyin   = insaddr[31-tag_len : 2  + line_len];
assign linex    = insaddr[1 +line_len: 2]            ;
assign data     = wdx?din:sdata;

assign vg=1;
assign dirty=1;
//way0
tag0 T0 (.addra(suoyin),
         .clka(clk),
         .dina(bj),
         .douta(tag[0]),
         .ena(1),
         .wea(wet[0]));

data D00 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][0]),
         .ena(en[0]),
         .wea(wed[0]));
data D01 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][1]),
         .ena(en[0]),
         .wea(wed[1]));
data D02 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][2]),
         .ena(en[0]),
         .wea(wed[2]));
data D03 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][3]),
         .ena(en[0]),
         .wea(wed[3]));
data D04 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][4]),
         .ena(en[0]),
         .wea(wed[4]));
data D05 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][5]),
         .ena(en[0]),
         .wea(wed[5]));
data D06 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][6]),
         .ena(en[0]),
         .wea(wed[6]));
data D07 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][7]),
         .ena(en[0]),
         .wea(wed[7]));
data D08 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][8]),
         .ena(en[0]),
         .wea(wed[8]));
data D09 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][9]),
         .ena(en[0]),
         .wea(wed[9]));
data D0a (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][10]),
         .ena(en[0]),
         .wea(wed[10]));
data D0b (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][11]),
         .ena(en[0]),
         .wea(wed[11]));
data D0c (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][12]),
         .ena(en[0]),
         .wea(wed[12]));
data D0d (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][13]),
         .ena(en[0]),
         .wea(wed[13]));
data D0e (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][14]),
         .ena(en[0]),
         .wea(wed[14]));
data D0f (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[0][15]),
         .ena(en[0]),
         .wea(wed[15]));
lru  L0 (.addra(suoyin),
         .clka(clk),
         .dina(lruin[0]),
         .douta(lru[0]),
         .ena(1),
         .wea(wel[0]));
//way1
tag0 T1 (.addra(suoyin),
         .clka(clk),
         .dina(bj),
         .douta(tag[1]),
         .ena(1),
         .wea(wet[1]));
data D10 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][0]),
         .ena(en[1]),
         .wea(wed[0]));
data D11 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][1]),
         .ena(en[1]),
         .wea(wed[1]));
data D12 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][2]),
         .ena(en[1]),
         .wea(wed[2]));
data D13 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][3]),
         .ena(en[1]),
         .wea(wed[3]));
data D14 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][4]),
         .ena(en[1]),
         .wea(wed[4]));
data D15 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][5]),
         .ena(en[1]),
         .wea(wed[5]));
data D16 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][6]),
         .ena(en[1]),
         .wea(wed[6]));
data D17 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][7]),
         .ena(en[1]),
         .wea(wed[7]));
data D18 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][8]),
         .ena(en[1]),
         .wea(wed[8]));
data D19 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][9]),
         .ena(en[1]),
         .wea(wed[9]));
data D1a (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][10]),
         .ena(en[1]),
         .wea(wed[10]));
data D1b (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][11]),
         .ena(en[1]),
         .wea(wed[11]));
data D1c (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][12]),
         .ena(en[1]),
         .wea(wed[12]));
data D1d (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][13]),
         .ena(en[1]),
         .wea(wed[13]));
data D1e (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][14]),
         .ena(en[1]),
         .wea(wed[14]));
data D1f (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[1][15]),
         .ena(en[1]),
         .wea(wed[15]));
lru  L1 (.addra(suoyin),
         .clka(clk),
         .dina(lruin[1]),
         .douta(lru[1]),
         .ena(1),
         .wea(wel[1]));
//way2        
tag0 T2 (.addra(suoyin),
         .clka(clk),
         .dina(bj),
         .douta(tag[2]),
         .ena(1),
         .wea(wet[2]));
data D20 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][0]),
         .ena(en[2]),
         .wea(wed[0]));
data D21 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][1]),
         .ena(en[2]),
         .wea(wed[1]));
data D22 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][2]),
         .ena(en[2]),
         .wea(wed[2]));
data D23 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][3]),
         .ena(en[2]),
         .wea(wed[3]));
data D24 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][4]),
         .ena(en[2]),
         .wea(wed[4]));
data D25 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][5]),
         .ena(en[2]),
         .wea(wed[5]));
data D26 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][6]),
         .ena(en[2]),
         .wea(wed[6]));
data D27 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][7]),
         .ena(en[2]),
         .wea(wed[7]));
data D28 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][8]),
         .ena(en[2]),
         .wea(wed[8]));
data D29 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][9]),
         .ena(en[2]),
         .wea(wed[9]));
data D2a (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][10]),
         .ena(en[2]),
         .wea(wed[10]));
data D2b (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][11]),
         .ena(en[2]),
         .wea(wed[11]));
data D2c (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][12]),
         .ena(en[2]),
         .wea(wed[12]));
data D2d (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][13]),
         .ena(en[2]),
         .wea(wed[13]));
data D2e (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][14]),
         .ena(en[2]),
         .wea(wed[14]));
data D2f (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[2][15]),
         .ena(en[2]),
         .wea(wed[15]));
lru  L2 (.addra(suoyin),
         .clka(clk),
         .dina(lruin[2]),
         .douta(lru[2]),
         .ena(1),
         .wea(wel[2]));
//way3
tag0 T3 (.addra(suoyin),
         .clka(clk),
         .dina(bj),
         .douta(tag[3]),
         .ena(1),
         .wea(wet[3]));
data D30 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][0]),
         .ena(en[3]),
         .wea(wed[0]));
data D31 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][1]),
         .ena(en[3]),
         .wea(wed[1]));
data D32 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][2]),
         .ena(en[3]),
         .wea(wed[2]));
data D33 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][3]),
         .ena(en[3]),
         .wea(wed[3]));
data D34 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][4]),
         .ena(en[3]),
         .wea(wed[4]));
data D35 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][5]),
         .ena(en[3]),
         .wea(wed[5]));
data D36 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][6]),
         .ena(en[3]),
         .wea(wed[6]));
data D37 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][7]),
         .ena(en[3]),
         .wea(wed[7]));
data D38 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][8]),
         .ena(en[3]),
         .wea(wed[8]));
data D39 (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][9]),
         .ena(en[3]),
         .wea(wed[9]));
data D3a (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][10]),
         .ena(en[3]),
         .wea(wed[10]));
data D3b (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][11]),
         .ena(en[3]),
         .wea(wed[11]));
data D3c (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][12]),
         .ena(en[3]),
         .wea(wed[12]));
data D3d (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][13]),
         .ena(en[3]),
         .wea(wed[13]));
data D3e (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][14]),
         .ena(en[3]),
         .wea(wed[14]));
data D3f (.addra(suoyin),
         .clka(clk),
         .dina(data),
         .douta(cdat[3][15]),
         .ena(en[3]),
         .wea(wed[15]));
lru  L3 (.addra(suoyin),
         .clka(clk),
         .dina(lruin[3]),
         .douta(lru[3]),
         .ena(1),
         .wea(wel[3]));
//control
wire [3:0] mz;
reg  [1:0] lux;
reg  [4:0] count;
//判断是否缺失
assign mz[0]=(bj==tag[0])&v[0][suoyin];
assign mz[1]=(bj==tag[1])&v[1][suoyin];
assign mz[2]=(bj==tag[2])&v[2][suoyin];
assign mz[3]=(bj==tag[3])&v[3][suoyin];
assign miss=~(mz[0]|mz[1]|mz[2]|mz[3]);
//选择那一路
always @ *
begin
  if(rst) lux=2'b00;
  else if(s==PD)
  begin
  if(mz[0]) lux=2'b00;
  else if(mz[1]) lux=2'b01;
  else if(mz[2]) lux=2'b10;
  else if(mz[3]) lux=2'b11;
  else
  begin
    if(~v[0][suoyin]) lux=2'b00;
    else if(~v[1][suoyin]) lux=2'b01;
    else if(~v[2][suoyin]) lux=2'b10;
    else if(~v[3][suoyin]) lux=2'b11;
    else
    begin
      lux=2'b00;
      if(lru[1]>lru[lux]) lux=2'b01;
      if(lru[2]>lru[lux]) lux=2'b10;
      if(lru[3]>lru[lux]) lux=2'b11;
    end
  end
  end
end
//地址选择
assign addr0    = {insaddr[31:2+line_len],6'b0};
assign addr1    = {tag[lux],suoyin,6'b0};
assign addr     = wen?addr1:addr0;
//使能控制
always @ *
begin
  en=4'b0;
  en[lux]=1;
end
//状态机
localparam FREE = 3'b000;
localparam PD   = 3'b001;
localparam WB   = 3'b010;
localparam RD   = 3'b011;
localparam FH   = 3'b100;
reg [2:0] s,ns;
reg we;

always @ (posedge clk or posedge rst)
if(rst) s<=FREE;
else    s<=ns;

always @ *
begin
  case(s)
  FREE: if(req) ns=PD;
        else    ns=FREE;
  PD:   if(miss&dir[lux][suoyin]) ns=WB;
        else if(miss&~dir[lux][suoyin]) ns=RD;
        else if(req) ns=PD;
        else ns=FREE;
  WB:   if(burst) ns=RD;
        else      ns=WB;
  RD:   if(burst) ns=FH;
        else      ns=RD;
  FH:   if(req) ns=PD;
        else    ns=FREE;
  default: ns=FREE;
  endcase
end

always @ (posedge data_ok or posedge addr_ok)
if(addr_ok) count<=0;
else        count<=count+1;

always @ *
begin
  wet=4'b0;wel=4'b0;lruc=4'b0;ok=0;sen=0;wen=0;wdx=0;stall=0;
  wed[0]=0;wed[1]=0;wed[2]=0;wed[3]=0;wed[4]=0;wed[5]=0;wed[6]=0;wed[7]=0;
  wed[8]=0;wed[9]=0;wed[10]=0;wed[11]=0;wed[12]=0;wed[13]=0;wed[14]=0;wed[15]=0;
  if(rst)  begin  wdata=0;we=0;ins=32'b0;v[0]=0;v[1]=0;v[2]=0;v[3]=0;dir[0]=0;dir[1]=0;dir[2]=0;dir[3]=0; end
  case(s)
  FREE:we=0;
  PD:  if(wreq&~miss) begin ins=din;wdx=1;ok=1;we=1;wed[linex]=wbyte;dir[lux][suoyin]=1; end
       else if(~wreq&~miss) begin ins=cdat[lux][linex];ok=1;we=0; end
       else if(wreq&miss) we=1;
       else we=0;
  WB:  begin stall=1;sen=1;wen=1;
             if(addr_ok) wdata=cdat[lux][0];
             else if(data_ok) wdata=cdat[lux][count[3:0]];
       end//写回
  RD:  begin stall=1;sen=1;
             if(data_ok) wed[count-1]=4'b1111;
       end//读取
  FH:  begin if(we) begin ins=din;wdx=1;ok=1;dir[lux][suoyin]=1;wed[linex]=wbyte; end
             else   begin ins=cdat[lux][linex];ok=1;dir[lux][suoyin]=0; end
             wet[lux]=1;v[lux][suoyin]=1;stall=1;
             if(lru[0]<=lru[lux]) wel[0]=1;
             if(lru[1]<=lru[lux]) wel[1]=1;
             if(lru[2]<=lru[lux]) wel[2]=1;
             if(lru[3]<=lru[lux]) wel[3]=1;
             wel[lux]=1;lruc[lux]=1;
       end     
  default:we=0;
  endcase
end
endmodule
