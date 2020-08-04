`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/05 11:04:16
// Design Name: 
// Module Name: Dcache
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


module Icache3
#(parameter tag_len    = 22,
  parameter suoyin_len = 4,
  parameter line_c     = 16,
  parameter line_len   = 4)
  (
    input clk,
    input rst,
    //??CPU
    input [31:0] insaddr,         //CPU??????
    output reg [31:0] ins,       //??????????
    input req,                   //???? ???????§Õ????1??1???????
    output miss,                 //?????            //stall?1?????????????
    output reg ok,               //????§Õ??????ok=1?????????????
    //??????
    output reg sen,              //????????§Õ??????1
    input addr_ok,               
    input data_ok,
    input burst,
    output [31:0] addr,         //????§Õ????
    input [31:0] sdata,          //?????????????
    //debug
    output [31:0] adn,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,
    output [2:0] s1,ns1,
    output [1:0] luxn,
    output [5:0] ms1,nms1,
    output [3:0] zdn,zdn1,dfn,wetn,
    output [suoyin_len - 1:0] sy,sy1,sy2,
    output [tag_len - 1   :0] tag0,tag1,tag2,tag3,
    output j1,deng1,vn0,vn1,vn2,vn3
);


wire [suoyin_len - 1:0]    suoyin1,suoyin2;
wire [tag_len - 1   :0]    tag   [3:0] ;
wire [1:0]                 lru   [3:0] ;
reg  [15:0]               v     [3:0] ;
reg  [3:0]                 web   [15:0];
reg  [3:0]                 wet         ;
reg  [3:0]                 wel         ;
reg  [3:0]                 ena,enb     ;
wire [31            :0]    cdat  [3:0] [line_c-1      :0];
wire [line_len-1    :0]    linex1,linex2;
wire [tag_len - 1   :0]    bj1,bj2      ;
reg [line_len-1    :0]    linex          ;
reg [tag_len - 1   :0]    bj       ;
reg [suoyin_len - 1:0]    suoyin;
wire [1:0]                 lruin [3:0] ;
reg  [3:0]                 lruc        ;
reg  [31:0] dr [15:0];
wire [31:0] addr0,addr1;
wire [3:0] mz;
reg  [1:0] lux,mlux;
reg  [2:0] s,ns;
reg  [5:0] ms,nms;
reg  firsth;
reg [31:0] insaddr1;
reg [31:0] firstd;
wire  j,deng;
reg [3:0] zd,zd1;
wire [3:0] df;

assign dfn=df;
assign zdn=zd;
assign zdn1=zd1;
assign luxn=lux;
assign j1=j;
assign deng1=deng;
assign adn=insaddr1;
assign sy=suoyin;
assign sy1=suoyin1;
assign sy2=suoyin2;
assign wetn=wet;
assign tag0=tag[0];
assign tag1=tag[1];
assign tag2=tag[2];
assign tag3=tag[3];
assign vn0=v[0][suoyin];
assign vn1=v[1][suoyin];
assign vn2=v[2][suoyin];
assign vn3=v[3][suoyin];
assign s1=s;
assign ns1=ns;
assign ms1=ms;
assign nms1=nms;

assign c0=cdat[lux][0];
assign c1=cdat[lux][1];
assign c2=cdat[lux][2];
assign c3=cdat[lux][3];
assign c4=cdat[lux][4];
assign c5=cdat[lux][5];
assign c6=cdat[lux][6];
assign c7=cdat[lux][7];
assign c8=cdat[lux][8];
assign c9=cdat[lux][9];
assign c10=cdat[lux][10];
assign c11=cdat[lux][11];
assign c12=cdat[lux][12];
assign c13=cdat[lux][13];
assign c14=cdat[lux][14];
assign c15=cdat[lux][15];

assign d0=dr[0];
assign d1=dr[1];
assign d2=dr[2];
assign d3=dr[3];
assign d4=dr[4];
assign d5=dr[5];
assign d6=dr[6];
assign d7=dr[7];
assign d8=dr[8];
assign d9=dr[9];
assign d10=dr[10];
assign d11=dr[11];
assign d12=dr[12];
assign d13=dr[13];
assign d14=dr[14];
assign d15=dr[15];

assign lruin[0]=lruc[0]?2'b00:(lru[0]+1);
assign lruin[1]=lruc[1]?2'b00:(lru[1]+1);
assign lruin[2]=lruc[2]?2'b00:(lru[2]+1);
assign lruin[3]=lruc[3]?2'b00:(lru[3]+1);

assign bj1       = insaddr[31         : 32 - tag_len ];
assign suoyin1   = insaddr[31-tag_len : 2  + line_len];
assign linex1    = insaddr[1 +line_len: 2]            ;
assign linex2    = insaddr1[1 +line_len: 2]           ;
assign bj2       = insaddr1[31         : 32 - tag_len ];
assign suoyin2   = insaddr1[31-tag_len : 2  + line_len];

assign mz[0]=(bj==tag[0])&v[0][suoyin];
assign mz[1]=(bj==tag[1])&v[1][suoyin];
assign mz[2]=(bj==tag[2])&v[2][suoyin];
assign mz[3]=(bj==tag[3])&v[3][suoyin];
assign miss=~(mz[0]|mz[1]|mz[2]|mz[3]);

assign df=linex1-linex2;
assign j=(insaddr[31:2+line_len]==insaddr1[31:2+line_len])&(df<ms[3:0]);
assign deng=(insaddr[31:2+line_len]==insaddr1[31:2+line_len])?1:0;



always @ *
begin
  if(rst) lux=2'b00;
  else if(s==3'b100||s==3'b010)
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

assign addr    = insaddr1;

always @ *
begin
  ena=4'b0;enb=4'b0;
  ena[lux]=1;enb[mlux]=1;
end

//?????
always @ (posedge clk or posedge rst)
if(rst) s<=3'b10;
else    s<=ns;

always @ *
case(s)
   3'b010:if(req&(suoyin!=suoyin1))  ns=3'b100; 
         else if(miss&req&~j&deng&(ms!=0))    ns=3'b11;
         else if(miss&req&~j&deng&(ms==0))    ns=3'b0;
         else if(miss&req&~j&~deng&(ms==0))     ns=3'b00;
         else if(miss&req&~j&~deng&(ms!=0))     ns=3'b101; 
         else         ns=3'b10;
   3'b000:if(firsth)   ns=3'b01;
         else         ns=3'b00;
   3'b001:if(req&(suoyin!=suoyin1))  ns=3'b100; 
         else         ns=3'b10;
   3'b011:if(j|~miss) ns=3'b10;
         else  ns=3'b11;
   3'b100:ns=3'b10;
   3'b101:if(ms==0)       ns=3'b00;
          else            ns=3'b101;
   default:ns=3'b10;
endcase

always @ *
begin
  wel=4'b0;lruc=4'b0;
  if(rst) begin ok=0;suoyin=suoyin1;bj=0;linex=0;insaddr1=insaddr;mlux=0;ins=0; end
  else if(s==3'b10)
  begin
    if(req)
    begin
      bj=bj1;linex=linex1;
      if(~miss&(suoyin==suoyin1)) 
      begin
        ok=1;ins=cdat[lux][linex];
        if(lru[0]<=lru[lux]) wel[0]=1;
        if(lru[1]<=lru[lux]) wel[1]=1;
        if(lru[2]<=lru[lux]) wel[2]=1;
        if(lru[3]<=lru[lux]) wel[3]=1;
        wel[lux]=1;lruc[lux]=1;
      end
      else if(miss&(suoyin==suoyin1))
      begin
        if(j)
        begin
          ins=(ms==0||ms==6'b001111)?cdat[lux][linex]:dr[linex];ok=1;
          if(lru[0]<=lru[lux]) wel[0]=1;
          if(lru[1]<=lru[lux]) wel[1]=1;
          if(lru[2]<=lru[lux]) wel[2]=1;
          if(lru[3]<=lru[lux]) wel[3]=1;
          wel[lux]=1;lruc[lux]=1;
        end
        else if(ms==0) begin ok=0;insaddr1=insaddr;mlux=lux;end
        else  ok=0;
      end
      else ok=0;
    end
    else ok=0;
  end
  else if(s==3'b01)
  begin
      ins=firstd;ok=1;
      if(lru[0]<=lru[lux]) wel[0]=1;
      if(lru[1]<=lru[lux]) wel[1]=1;
      if(lru[2]<=lru[lux]) wel[2]=1;
      if(lru[3]<=lru[lux]) wel[3]=1;
      wel[lux]=1;lruc[lux]=1;
  end
  else if(s==3'b100) begin suoyin=suoyin1;ok=0; end
  else if(s==3'b101) begin ok=0;
    if(ms==0) begin insaddr1=insaddr;mlux=lux;end
    end
  else ok=0;
end

//???

always @ (posedge clk or posedge rst)
if(rst) ms<=0;
else    ms<=nms;

always @ *
begin
  if(ms==6'b000000)
    if(ns==2'b00) nms=6'b110000;
    else nms=6'b0;
  else if(ms==6'b110000)
    if(data_ok) nms=6'b010000;
    else        nms=6'b110000;
  else if(ms[5:4]==2'b01&&ms!=6'b011111)
    if(data_ok) nms=ms+1;
    else        nms=ms;
  else if(ms==6'b011111) nms=6'b111111;
  else if(ms==6'b111111) nms=6'b001111;
  else nms=6'b0;
end

always @ *
begin
  sen=0;firsth=0;wet=4'b0;
  if(rst)
  begin
    firsth=0;firstd=0;v[0]=0;v[1]=0;v[2]=0;v[3]=0;zd=0;zd1=0;
  end
  else if(ms==6'b000000)
  begin
    firsth=0;firstd=0;zd=0;
  end
  else if(ms==6'b110000)
  begin
    sen=1;zd=linex2+ms[3:0];
  end
  else if(ms[5:4]==2'b01)
  begin
    sen=1;zd=linex2+ms[3:0];
    if(ms[3:0]==4'b1111) zd1=zd;
    else                 zd1=zd+1;
    if(ms[3:0]==0) begin firsth=1;firstd=dr[linex2]; end
  end
  else if(ms==6'b111111)
  begin
    v[mlux][suoyin2]=1;wet[mlux]=1;
  end
end

always @ (posedge clk or posedge rst)
begin
  if(rst)
  begin
    dr[0]<=0;dr[1]<=0;dr[2]<=0;dr[3]<=0;dr[4]<=0;dr[5]<=0;dr[6]<=0;dr[7]<=0;
    dr[8]<=0;dr[9]<=0;dr[10]<=0;dr[11]<=0;dr[12]<=0;dr[13]<=0;dr[14]<=0;dr[15]<=0;
    web[0]<=0;web[1]<=0;web[2]<=0;web[3]<=0;web[4]<=0;web[5]<=0;web[6]<=0;web[7]<=0;
    web[8]<=0;web[9]<=0;web[10]<=0;web[11]<=0;web[12]<=0;web[13]<=0;web[14]<=0;web[15]<=0;
  end
  else if(ms==6'b110000)  begin dr[zd]<=sdata;web[zd]<=4'b1111; end
  else if(ms[5:4]==2'b01) begin dr[zd1]<=sdata;web[zd1]<=4'b1111;web[zd]<=0; end
  else if(ms==0)
  begin 
    dr[0]<=0;dr[1]<=0;dr[2]<=0;dr[3]<=0;dr[4]<=0;dr[5]<=0;dr[6]<=0;dr[7]<=0;
    dr[8]<=0;dr[9]<=0;dr[10]<=0;dr[11]<=0;dr[12]<=0;dr[13]<=0;dr[14]<=0;dr[15]<=0;
    web[0]<=0;web[1]<=0;web[2]<=0;web[3]<=0;web[4]<=0;web[5]<=0;web[6]<=0;web[7]<=0;
    web[8]<=0;web[9]<=0;web[10]<=0;web[11]<=0;web[12]<=0;web[13]<=0;web[14]<=0;web[15]<=0;
  end
end

tag0 T0 (.addra(suoyin2),
.clka(clk),
.dina(bj2),
.ena(1),
.wea(wet[0]),
.doutb(tag[0]),
.addrb(suoyin),
.clkb(clk),
.enb(1));
idat D00 (.addra(suoyin2),
.clka(clk),
.dina(dr[0]),
.ena(enb[0]),
.wea(web[0]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][0]),
.enb(ena[0]) );
idat D01 (.addra(suoyin2),
.clka(clk),
.dina(dr[1]),
.ena(enb[0]),
.wea(web[1]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][1]),
.enb(ena[0]) );
idat D02 (.addra(suoyin2),
.clka(clk),
.dina(dr[2]),
.ena(enb[0]),
.wea(web[2]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][2]),
.enb(ena[0]) );
idat D03 (.addra(suoyin2),
.clka(clk),
.dina(dr[3]),
.ena(enb[0]),
.wea(web[3]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][3]),
.enb(ena[0]) );
idat D04 (.addra(suoyin2),
.clka(clk),
.dina(dr[4]),
.ena(enb[0]),
.wea(web[4]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][4]),
.enb(ena[0]) );
idat D05 (.addra(suoyin2),
.clka(clk),
.dina(dr[5]),
.ena(enb[0]),
.wea(web[5]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][5]),
.enb(ena[0]) );
idat D06 (.addra(suoyin2),
.clka(clk),
.dina(dr[6]),
.ena(enb[0]),
.wea(web[6]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][6]),
.enb(ena[0]) );
idat D07 (.addra(suoyin2),
.clka(clk),
.dina(dr[7]),
.ena(enb[0]),
.wea(web[7]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][7]),
.enb(ena[0]) );
idat D08 (.addra(suoyin2),
.clka(clk),
.dina(dr[8]),
.ena(enb[0]),
.wea(web[8]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][8]),
.enb(ena[0]) );
idat D09 (.addra(suoyin2),
.clka(clk),
.dina(dr[9]),
.ena(enb[0]),
.wea(web[9]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][9]),
.enb(ena[0]) );
idat D010 (.addra(suoyin2),
.clka(clk),
.dina(dr[10]),
.ena(enb[0]),
.wea(web[10]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][10]),
.enb(ena[0]) );
idat D011 (.addra(suoyin2),
.clka(clk),
.dina(dr[11]),
.ena(enb[0]),
.wea(web[11]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][11]),
.enb(ena[0]) );
idat D012 (.addra(suoyin2),
.clka(clk),
.dina(dr[12]),
.ena(enb[0]),
.wea(web[12]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][12]),
.enb(ena[0]) );
idat D013 (.addra(suoyin2),
.clka(clk),
.dina(dr[13]),
.ena(enb[0]),
.wea(web[13]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][13]),
.enb(ena[0]) );
idat D014 (.addra(suoyin2),
.clka(clk),
.dina(dr[14]),
.ena(enb[0]),
.wea(web[14]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][14]),
.enb(ena[0]) );
idat D015 (.addra(suoyin2),
.clka(clk),
.dina(dr[15]),
.ena(enb[0]),
.wea(web[15]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[0][15]),
.enb(ena[0]) );
lru  L0 (.addra(suoyin),
.clka(clk),
.dina(lruin[0]),
.douta(lru[0]),
.ena(1),
.wea(wel[0]));

tag0 T1 (.addra(suoyin2),
.clka(clk),
.dina(bj2),
.ena(1),
.wea(wet[1]),
.doutb(tag[1]),
.addrb(suoyin),
.clkb(clk),
.enb(1));
idat D10 (.addra(suoyin2),
.clka(clk),
.dina(dr[0]),
.ena(enb[1]),
.wea(web[0]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][0]),
.enb(ena[1]) );
idat D11 (.addra(suoyin2),
.clka(clk),
.dina(dr[1]),
.ena(enb[1]),
.wea(web[1]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][1]),
.enb(ena[1]) );
idat D12 (.addra(suoyin2),
.clka(clk),
.dina(dr[2]),
.ena(enb[1]),
.wea(web[2]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][2]),
.enb(ena[1]) );
idat D13 (.addra(suoyin2),
.clka(clk),
.dina(dr[3]),
.ena(enb[1]),
.wea(web[3]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][3]),
.enb(ena[1]) );
idat D14 (.addra(suoyin2),
.clka(clk),
.dina(dr[4]),
.ena(enb[1]),
.wea(web[4]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][4]),
.enb(ena[1]) );
idat D15 (.addra(suoyin2),
.clka(clk),
.dina(dr[5]),
.ena(enb[1]),
.wea(web[5]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][5]),
.enb(ena[1]) );
idat D16 (.addra(suoyin2),
.clka(clk),
.dina(dr[6]),
.ena(enb[1]),
.wea(web[6]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][6]),
.enb(ena[1]) );
idat D17 (.addra(suoyin2),
.clka(clk),
.dina(dr[7]),
.ena(enb[1]),
.wea(web[7]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][7]),
.enb(ena[1]) );
idat D18 (.addra(suoyin2),
.clka(clk),
.dina(dr[8]),
.ena(enb[1]),
.wea(web[8]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][8]),
.enb(ena[1]) );
idat D19 (.addra(suoyin2),
.clka(clk),
.dina(dr[9]),
.ena(enb[1]),
.wea(web[9]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][9]),
.enb(ena[1]) );
idat D110 (.addra(suoyin2),
.clka(clk),
.dina(dr[10]),
.ena(enb[1]),
.wea(web[10]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][10]),
.enb(ena[1]) );
idat D111 (.addra(suoyin2),
.clka(clk),
.dina(dr[11]),
.ena(enb[1]),
.wea(web[11]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][11]),
.enb(ena[1]) );
idat D112 (.addra(suoyin2),
.clka(clk),
.dina(dr[12]),
.ena(enb[1]),
.wea(web[12]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][12]),
.enb(ena[1]) );
idat D113 (.addra(suoyin2),
.clka(clk),
.dina(dr[13]),
.ena(enb[1]),
.wea(web[13]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][13]),
.enb(ena[1]) );
idat D114 (.addra(suoyin2),
.clka(clk),
.dina(dr[14]),
.ena(enb[1]),
.wea(web[14]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][14]),
.enb(ena[1]) );
idat D115 (.addra(suoyin2),
.clka(clk),
.dina(dr[15]),
.ena(enb[1]),
.wea(web[15]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[1][15]),
.enb(ena[1]) );
lru  L1 (.addra(suoyin),
.clka(clk),
.dina(lruin[1]),
.douta(lru[1]),
.ena(1),
.wea(wel[1]));

tag0 T2 (.addra(suoyin2),
.clka(clk),
.dina(bj2),
.ena(1),
.wea(wet[2]),
.doutb(tag[2]),
.addrb(suoyin),
.clkb(clk),
.enb(1));
idat D20 (.addra(suoyin2),
.clka(clk),
.dina(dr[0]),
.ena(enb[2]),
.wea(web[0]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][0]),
.enb(ena[2]) );
idat D21 (.addra(suoyin2),
.clka(clk),
.dina(dr[1]),
.ena(enb[2]),
.wea(web[1]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][1]),
.enb(ena[2]) );
idat D22 (.addra(suoyin2),
.clka(clk),
.dina(dr[2]),
.ena(enb[2]),
.wea(web[2]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][2]),
.enb(ena[2]) );
idat D23 (.addra(suoyin2),
.clka(clk),
.dina(dr[3]),
.ena(enb[2]),
.wea(web[3]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][3]),
.enb(ena[2]) );
idat D24 (.addra(suoyin2),
.clka(clk),
.dina(dr[4]),
.ena(enb[2]),
.wea(web[4]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][4]),
.enb(ena[2]) );
idat D25 (.addra(suoyin2),
.clka(clk),
.dina(dr[5]),
.ena(enb[2]),
.wea(web[5]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][5]),
.enb(ena[2]) );
idat D26 (.addra(suoyin2),
.clka(clk),
.dina(dr[6]),
.ena(enb[2]),
.wea(web[6]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][6]),
.enb(ena[2]) );
idat D27 (.addra(suoyin2),
.clka(clk),
.dina(dr[7]),
.ena(enb[2]),
.wea(web[7]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][7]),
.enb(ena[2]) );
idat D28 (.addra(suoyin2),
.clka(clk),
.dina(dr[8]),
.ena(enb[2]),
.wea(web[8]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][8]),
.enb(ena[2]) );
idat D29 (.addra(suoyin2),
.clka(clk),
.dina(dr[9]),
.ena(enb[2]),
.wea(web[9]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][9]),
.enb(ena[2]) );
idat D210 (.addra(suoyin2),
.clka(clk),
.dina(dr[10]),
.ena(enb[2]),
.wea(web[10]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][10]),
.enb(ena[2]) );
idat D211 (.addra(suoyin2),
.clka(clk),
.dina(dr[11]),
.ena(enb[2]),
.wea(web[11]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][11]),
.enb(ena[2]) );
idat D212 (.addra(suoyin2),
.clka(clk),
.dina(dr[12]),
.ena(enb[2]),
.wea(web[12]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][12]),
.enb(ena[2]) );
idat D213 (.addra(suoyin2),
.clka(clk),
.dina(dr[13]),
.ena(enb[2]),
.wea(web[13]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][13]),
.enb(ena[2]) );
idat D214 (.addra(suoyin2),
.clka(clk),
.dina(dr[14]),
.ena(enb[2]),
.wea(web[14]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][14]),
.enb(ena[2]) );
idat D215 (.addra(suoyin2),
.clka(clk),
.dina(dr[15]),
.ena(enb[2]),
.wea(web[15]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[2][15]),
.enb(ena[2]) );
lru  L2 (.addra(suoyin),
.clka(clk),
.dina(lruin[2]),
.douta(lru[2]),
.ena(1),
.wea(wel[2]));

tag0 T3 (.addra(suoyin2),
.clka(clk),
.dina(bj2),
.ena(1),
.wea(wet[3]),
.doutb(tag[3]),
.addrb(suoyin),
.clkb(clk),
.enb(1));
idat D30 (.addra(suoyin2),
.clka(clk),
.dina(dr[0]),
.ena(enb[3]),
.wea(web[0]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][0]),
.enb(ena[3]) );
idat D31 (.addra(suoyin2),
.clka(clk),
.dina(dr[1]),
.ena(enb[3]),
.wea(web[1]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][1]),
.enb(ena[3]) );
idat D32 (.addra(suoyin2),
.clka(clk),
.dina(dr[2]),
.ena(enb[3]),
.wea(web[2]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][2]),
.enb(ena[3]) );
idat D33 (.addra(suoyin2),
.clka(clk),
.dina(dr[3]),
.ena(enb[3]),
.wea(web[3]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][3]),
.enb(ena[3]) );
idat D34 (.addra(suoyin2),
.clka(clk),
.dina(dr[4]),
.ena(enb[3]),
.wea(web[4]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][4]),
.enb(ena[3]) );
idat D35 (.addra(suoyin2),
.clka(clk),
.dina(dr[5]),
.ena(enb[3]),
.wea(web[5]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][5]),
.enb(ena[3]) );
idat D36 (.addra(suoyin2),
.clka(clk),
.dina(dr[6]),
.ena(enb[3]),
.wea(web[6]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][6]),
.enb(ena[3]) );
idat D37 (.addra(suoyin2),
.clka(clk),
.dina(dr[7]),
.ena(enb[3]),
.wea(web[7]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][7]),
.enb(ena[3]) );
idat D38 (.addra(suoyin2),
.clka(clk),
.dina(dr[8]),
.ena(enb[3]),
.wea(web[8]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][8]),
.enb(ena[3]) );
idat D39 (.addra(suoyin2),
.clka(clk),
.dina(dr[9]),
.ena(enb[3]),
.wea(web[9]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][9]),
.enb(ena[3]) );
idat D310 (.addra(suoyin2),
.clka(clk),
.dina(dr[10]),
.ena(enb[3]),
.wea(web[10]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][10]),
.enb(ena[3]) );
idat D311 (.addra(suoyin2),
.clka(clk),
.dina(dr[11]),
.ena(enb[3]),
.wea(web[11]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][11]),
.enb(ena[3]) );
idat D312 (.addra(suoyin2),
.clka(clk),
.dina(dr[12]),
.ena(enb[3]),
.wea(web[12]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][12]),
.enb(ena[3]) );
idat D313 (.addra(suoyin2),
.clka(clk),
.dina(dr[13]),
.ena(enb[3]),
.wea(web[13]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][13]),
.enb(ena[3]) );
idat D314 (.addra(suoyin2),
.clka(clk),
.dina(dr[14]),
.ena(enb[3]),
.wea(web[14]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][14]),
.enb(ena[3]) );
idat D315 (.addra(suoyin2),
.clka(clk),
.dina(dr[15]),
.ena(enb[3]),
.wea(web[15]),
.addrb(suoyin),
.clkb(clk),
.doutb(cdat[3][15]),
.enb(ena[3]) );
lru  L3 (.addra(suoyin),
.clka(clk),
.dina(lruin[3]),
.douta(lru[3]),
.ena(1),
.wea(wel[3]));
endmodule
