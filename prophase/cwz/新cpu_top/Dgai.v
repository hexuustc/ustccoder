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


module Dcache3
#(parameter tag_len    = 22,
  parameter suoyin_len = 4,
  parameter line_c     = 16,
  parameter line_len   = 4)
  (
    input clk,
    input rst,
    //ï¿½ï¿½CPU
    input [31:0] insaddr,         //CPUï¿½ï¿½ï¿½Êµï¿½Ö·
    input [31:0] din,             //CPUÒªÐ´ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿?
    output reg [31:0] ins,       //ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
    input req,                   //ï¿½ï¿½ï¿½ï¿½ ï¿½ï¿½ï¿½Û¶ï¿½ï¿½ï¿½Ð´ï¿½ï¿½ÒªÎª1ï¿½ï¿½1ï¿½ï¿½ï¿½ï¿½ï¿½Ú£ï¿½
    input wreq,                  //Ð´ï¿½ï¿½ï¿½ï¿½1ï¿½ï¿½ï¿½ï¿½ï¿½Ú£ï¿½
    input [3:0] wbyte,           //Ð´ï¿½Ö½ï¿½Ê¹ï¿½Ü£ï¿½Ã¿Ò»Î»ï¿½ï¿½Ó¦1ï¿½ï¿½ï¿½Ö½Ú£ï¿½ï¿½ï¿½ï¿½ï¿½1000ï¿½ï¿½Òªï¿½ï¿½dinï¿½Ä¸ï¿½8Î»Ð´ï¿½ï¿½insaddrï¿½ï¿½Ö·ï¿½ï¿½Ó¦ï¿½ï¿½ï¿½ÝµÄ¸ï¿½8Î»ï¿½ï¿½
    output miss,                 //È±Ê§ï¿½Åºï¿½            //stallÎª1Ê±ï¿½ï¿½Ó¦ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ë®ï¿½ï¿½
    output reg ok,               //ï¿½ï¿½ï¿½ï¿½Ð´ï¿½ï¿½ï¿½Ê±ï¿½ï¿½ok=1ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
    //ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
    output reg wen,              //Ð´Ê¹ÄÜ£¬Ð´Ê±Îª1
    output reg sen,              //¶ÁÊ¹ÄÜ£¬¶ÁÊ±Îª1
    input waddr_ok,               
    input wdata_ok,
    input wburst,
    output reg [31:0] wdata,    //Ð´Êý¾Ý
    output [31:0] waddr,         //Ð´µØÖ·  //Ð´Îª´Ó0¿ªÊ¼Ð´16¸ö
    input raddr_ok,               
    input rdata_ok,
    input rburst,
    output [31:0] raddr,         //¶ÁµØÖ·
    input [31:0] sdata,          //¶ÁÊý¾Ý  //¶ÁÎª´Ó¶ÁµØÖ·¿ªÊ¼Ñ­»·¶Á16¸ö
    //debug
    output [31:0] adn,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,
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
reg  [15:0]               dir   [3:0] ;
reg  [3:0]                 wea   [15:0];
reg  [3:0]                 web   [15:0];
reg  [3:0]                 wet         ;
reg  [3:0]                 wel         ;
reg  [3:0]                 ena,enb     ;
wire [31            :0]    cdat  [3:0] [line_c-1      :0];
wire [31            :0]    dwb   [3:0] [line_c-1      :0];
reg  [31            :0]    dwb1  [line_c-1      :0];
wire [line_len-1    :0]    linex1,linex2;
wire [tag_len - 1   :0]    bj1,bj2      ;
reg [line_len-1    :0]    linex          ;
reg [tag_len - 1   :0]    bj       ;
reg [suoyin_len - 1:0]    suoyin;
reg [31:0] dw;
wire [1:0]                 lruin [3:0] ;
reg  [3:0]                 lruc        ;
reg  [31:0] dr [15:0];
wire [31:0] addr0,addr1;
reg we;
wire [3:0] mz;
reg  [1:0] lux,mlux;
reg  [2:0] s,ns;
reg  [5:0] ms,nms;
reg  firsth;
reg [31:0] insaddr1;
reg [3:0] wbyte1;
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

assign b0=dwb[lux][0];
assign b1=dwb[lux][1];
assign b2=dwb[lux][2];
assign b3=dwb[lux][3];
assign b4=dwb[lux][4];
assign b5=dwb[lux][5];
assign b6=dwb[lux][6];
assign b7=dwb[lux][7];
assign b8=dwb[lux][8];
assign b9=dwb[lux][9];
assign b10=dwb[lux][10];
assign b11=dwb[lux][11];
assign b12=dwb[lux][12];
assign b13=dwb[lux][13];
assign b14=dwb[lux][14];
assign b15=dwb[lux][15];

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

assign addr0    = insaddr1;
assign addr1    = {insaddr1[31:6],6'b0};
assign raddr    = addr0;
assign waddr    = addr1;

always @ *
begin
  ena=4'b0;enb=4'b0;
  ena[lux]=1;enb[mlux]=1;
end

//Õý³£Ì¬
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
   3'b011:if(j|~miss) ns=3'b111;
         else  ns=3'b11;
   3'b100:ns=3'b110;
   3'b111:ns=3'b10;
   3'b110:if(miss&~j&deng&(ms!=0))    ns=3'b11;
         else if(miss&~j&deng&(ms==0))    ns=3'b0;
         else if(miss&~j&~deng&(ms==0))     ns=3'b00;
         else if(miss&~j&~deng&(ms!=0))     ns=3'b101; 
         else         ns=3'b10;
   3'b101:if(ms==0)       ns=3'b00;
          else            ns=3'b101;
   default:ns=3'b10;
endcase

always @ *
begin
  wel=4'b0;lruc=4'b0;ok=0;
  wea[0]=0;wea[1]=0;wea[2]=0;wea[3]=0;wea[4]=0;wea[5]=0;wea[6]=0;wea[7]=0;
  wea[8]=0;wea[9]=0;wea[10]=0;wea[11]=0;wea[12]=0;wea[13]=0;wea[14]=0;wea[15]=0;
  if(rst) begin dir[0]=0;dir[1]=0;dir[2]=0;dir[3]=0;suoyin=suoyin1;bj=0;linex=0;insaddr1=insaddr;dw=0;we=0;wbyte1=0;mlux=0;ins=0;
                dwb1[0]=0;dwb1[1]=0;dwb1[2]=0;dwb1[3]=0;dwb1[4]=0;dwb1[5]=0;dwb1[6]=0;dwb1[7]=0;
                dwb1[8]=0;dwb1[9]=0;dwb1[10]=0;dwb1[11]=0;dwb1[12]=0;dwb1[13]=0;dwb1[14]=0;dwb1[15]=0;
                end
  else if(s==3'b10)
  begin
    if(req)
    begin
      bj=bj1;linex=linex1;
      if(wreq&(~miss)&(suoyin==suoyin1)) 
      begin
        we=1;wea[linex]=wbyte;dir[lux][suoyin]=1;dw=din;ins=dw;ok=1;
        if(lru[0]<=lru[lux]) wel[0]=1;
        if(lru[1]<=lru[lux]) wel[1]=1;
        if(lru[2]<=lru[lux]) wel[2]=1;
        if(lru[3]<=lru[lux]) wel[3]=1;
        wel[lux]=1;lruc[lux]=1;
      end
      else if(wreq&miss&(suoyin==suoyin1)) 
      begin 
        we=1;dw=din;
        if(j)
        begin
          wea[linex]=wbyte;dir[lux][suoyin]=1;ins=dw;ok=1;
          if(lru[0]<=lru[lux]) wel[0]=1;
          if(lru[1]<=lru[lux]) wel[1]=1;
          if(lru[2]<=lru[lux]) wel[2]=1;
          if(lru[3]<=lru[lux]) wel[3]=1;
          wel[lux]=1;lruc[lux]=1;
        end
        else if(ms==0) begin wbyte1=wbyte;insaddr1=insaddr;mlux=lux;
                             dwb1[0]=dwb[lux][0];dwb1[1]=dwb[lux][1];dwb1[2]=dwb[lux][2];dwb1[3]=dwb[lux][3];
                             dwb1[4]=dwb[lux][4];dwb1[5]=dwb[lux][5];dwb1[6]=dwb[lux][6];dwb1[7]=dwb[lux][7];
                             dwb1[8]=dwb[lux][8];dwb1[9]=dwb[lux][9];dwb1[10]=dwb[lux][10];dwb1[11]=dwb[lux][11];
                             dwb1[12]=dwb[lux][12];dwb1[13]=dwb[lux][13];dwb1[14]=dwb[lux][14];dwb1[15]=dwb[lux][15];
                             end
        else begin wbyte1=wbyte; end 
      end
      else if(~wreq&~miss&(suoyin==suoyin1)) 
      begin
        ok=1;ins=cdat[lux][linex];we=0;
        if(lru[0]<=lru[lux]) wel[0]=1;
        if(lru[1]<=lru[lux]) wel[1]=1;
        if(lru[2]<=lru[lux]) wel[2]=1;
        if(lru[3]<=lru[lux]) wel[3]=1;
        wel[lux]=1;lruc[lux]=1;
      end
      else if(~wreq&miss&(suoyin==suoyin1))
      begin
        we=0;
        if(j)
        begin
          ins=(ms==0)?cdat[lux][linex]:dr[linex];ok=1;
          if(lru[0]<=lru[lux]) wel[0]=1;
          if(lru[1]<=lru[lux]) wel[1]=1;
          if(lru[2]<=lru[lux]) wel[2]=1;
          if(lru[3]<=lru[lux]) wel[3]=1;
          wel[lux]=1;lruc[lux]=1;
        end
        else if(ms==0) begin insaddr1=insaddr;mlux=lux;
                             dwb1[0]=dwb[lux][0];dwb1[1]=dwb[lux][1];dwb1[2]=dwb[lux][2];dwb1[3]=dwb[lux][3];
                             dwb1[4]=dwb[lux][4];dwb1[5]=dwb[lux][5];dwb1[6]=dwb[lux][6];dwb1[7]=dwb[lux][7];
                             dwb1[8]=dwb[lux][8];dwb1[9]=dwb[lux][9];dwb1[10]=dwb[lux][10];dwb1[11]=dwb[lux][11];
                             dwb1[12]=dwb[lux][12];dwb1[13]=dwb[lux][13];dwb1[14]=dwb[lux][14];dwb1[15]=dwb[lux][15];
                             end
      end
    end
  end
  else if(s==3'b111)
  begin
    if(we)
    begin
      wea[linex]=wbyte1;dir[lux][suoyin]=1;ins=dw;ok=1;
      if(lru[0]<=lru[lux]) wel[0]=1;
      if(lru[1]<=lru[lux]) wel[1]=1;
      if(lru[2]<=lru[lux]) wel[2]=1;
      if(lru[3]<=lru[lux]) wel[3]=1;
      wel[lux]=1;lruc[lux]=1;  
    end
    else
    begin
      ins=(ms==0)?cdat[lux][linex]:dr[linex];ok=1;
      if(lru[0]<=lru[lux]) wel[0]=1;
      if(lru[1]<=lru[lux]) wel[1]=1;
      if(lru[2]<=lru[lux]) wel[2]=1;
      if(lru[3]<=lru[lux]) wel[3]=1;
      wel[lux]=1;lruc[lux]=1;
    end
  end
  else if(s==3'b110)
  begin
      bj=bj1;linex=linex1;
      if(wreq&(~miss)&(suoyin==suoyin1)) 
      begin
        we=1;wea[linex]=wbyte;dir[lux][suoyin]=1;dw=din;ins=dw;ok=1;
        if(lru[0]<=lru[lux]) wel[0]=1;
        if(lru[1]<=lru[lux]) wel[1]=1;
        if(lru[2]<=lru[lux]) wel[2]=1;
        if(lru[3]<=lru[lux]) wel[3]=1;
        wel[lux]=1;lruc[lux]=1;
      end
      else if(wreq&miss&(suoyin==suoyin1)) 
      begin 
        we=1;dw=din;
        if(j)
        begin
          wea[linex]=wbyte;dir[lux][suoyin]=1;ins=dw;ok=1;
          if(lru[0]<=lru[lux]) wel[0]=1;
          if(lru[1]<=lru[lux]) wel[1]=1;
          if(lru[2]<=lru[lux]) wel[2]=1;
          if(lru[3]<=lru[lux]) wel[3]=1;
          wel[lux]=1;lruc[lux]=1;
        end
        else if(ms==0) begin wbyte1=wbyte;insaddr1=insaddr;mlux=lux;
                             dwb1[0]=dwb[lux][0];dwb1[1]=dwb[lux][1];dwb1[2]=dwb[lux][2];dwb1[3]=dwb[lux][3];
                             dwb1[4]=dwb[lux][4];dwb1[5]=dwb[lux][5];dwb1[6]=dwb[lux][6];dwb1[7]=dwb[lux][7];
                             dwb1[8]=dwb[lux][8];dwb1[9]=dwb[lux][9];dwb1[10]=dwb[lux][10];dwb1[11]=dwb[lux][11];
                             dwb1[12]=dwb[lux][12];dwb1[13]=dwb[lux][13];dwb1[14]=dwb[lux][14];dwb1[15]=dwb[lux][15];
                             end
        else begin wbyte1=wbyte; end 
      end
      else if(~wreq&~miss&(suoyin==suoyin1)) 
      begin
        ok=1;ins=cdat[lux][linex];we=0;
        if(lru[0]<=lru[lux]) wel[0]=1;
        if(lru[1]<=lru[lux]) wel[1]=1;
        if(lru[2]<=lru[lux]) wel[2]=1;
        if(lru[3]<=lru[lux]) wel[3]=1;
        wel[lux]=1;lruc[lux]=1;
      end
      else if(~wreq&miss&(suoyin==suoyin1))
      begin
        we=0;
        if(j)
        begin
          ins=(ms==0)?cdat[lux][linex]:dr[linex];ok=1;
          if(lru[0]<=lru[lux]) wel[0]=1;
          if(lru[1]<=lru[lux]) wel[1]=1;
          if(lru[2]<=lru[lux]) wel[2]=1;
          if(lru[3]<=lru[lux]) wel[3]=1;
          wel[lux]=1;lruc[lux]=1;
        end
        else if(ms==0) begin insaddr1=insaddr;mlux=lux;
                             dwb1[0]=dwb[lux][0];dwb1[1]=dwb[lux][1];dwb1[2]=dwb[lux][2];dwb1[3]=dwb[lux][3];
                             dwb1[4]=dwb[lux][4];dwb1[5]=dwb[lux][5];dwb1[6]=dwb[lux][6];dwb1[7]=dwb[lux][7];
                             dwb1[8]=dwb[lux][8];dwb1[9]=dwb[lux][9];dwb1[10]=dwb[lux][10];dwb1[11]=dwb[lux][11];
                             dwb1[12]=dwb[lux][12];dwb1[13]=dwb[lux][13];dwb1[14]=dwb[lux][14];dwb1[15]=dwb[lux][15];
                             end
      end
  end
  else if(s==3'b01)
  begin
    if(we)
    begin
      wea[linex]=wbyte1;dir[lux][suoyin]=1;ins=dw;ok=1;
      if(lru[0]<=lru[lux]) wel[0]=1;
      if(lru[1]<=lru[lux]) wel[1]=1;
      if(lru[2]<=lru[lux]) wel[2]=1;
      if(lru[3]<=lru[lux]) wel[3]=1;
      wel[lux]=1;lruc[lux]=1;  
    end
    else
    begin
      ins=firstd;ok=1;dir[lux][suoyin]=0;
      if(lru[0]<=lru[lux]) wel[0]=1;
      if(lru[1]<=lru[lux]) wel[1]=1;
      if(lru[2]<=lru[lux]) wel[2]=1;
      if(lru[3]<=lru[lux]) wel[3]=1;
      wel[lux]=1;lruc[lux]=1;
    end
  end
  else if(s==3'b100) begin suoyin=suoyin1; end
  else if(s==3'b101) begin 
    if(ms==0) begin insaddr1=insaddr;mlux=lux;
                    dwb1[0]=dwb[lux][0];dwb1[1]=dwb[lux][1];dwb1[2]=dwb[lux][2];dwb1[3]=dwb[lux][3];
                    dwb1[4]=dwb[lux][4];dwb1[5]=dwb[lux][5];dwb1[6]=dwb[lux][6];dwb1[7]=dwb[lux][7];
                    dwb1[8]=dwb[lux][8];dwb1[9]=dwb[lux][9];dwb1[10]=dwb[lux][10];dwb1[11]=dwb[lux][11];
                    dwb1[12]=dwb[lux][12];dwb1[13]=dwb[lux][13];dwb1[14]=dwb[lux][14];dwb1[15]=dwb[lux][15];
                    end
    end
end

//È±Ê§Ì¬ read
reg [4:0] ws,nws;

always @ (posedge clk or posedge rst)
if(rst) ms<=0;
else    ms<=nms;

always @ *
begin
  if(ms==6'b000000)
    if(ns==2'b00)      nms=6'b110000;
    else               nms=6'b0;
  else if(ms==6'b110000)
    if(rdata_ok) nms=6'b010000;
    else         nms=6'b110000;
  else if(ms[5:4]==2'b01&&ms!=6'b011111)
    if(rdata_ok) nms=ms+1;
    else        nms=ms;
  else if(ms==6'b011111) nms=6'b111111;
  else if(ms==6'b111111) 
    if(nws==5'b0)   nms=6'b001111;
    else            nms=6'b111111;
  else nms=6'b0;
end

always @ *
begin
  sen=0;firsth=0;wet=4'b0;zd=0;zd1=0;
  if(rst)
  begin
    firsth=0;firstd=0;v[0]=0;v[1]=0;v[2]=0;v[3]=0;
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

//È±Ê§Ì¬ write
always @ (posedge clk or posedge rst)
if(rst) ws<=0;
else    ws<=nws;

always @ *
begin
  if(ws==0)
    if(dir[mlux][suoyin]==1&&ns==2'b00) nws=5'b10000;
    else                                nws=5'b00000;
  else if(ws[4]==1)
    if(wdata_ok)                        nws=ws+1;
    else                                nws=ws;
  else                                  nws=0;
end

always @ *
begin
  if(rst) 
  begin
    wdata=0;wen=0;
  end
  if(ws[4]==1)
  begin
    wdata=dwb1[ws[3:0]];
    wen=1;
  end
  else wen=0;
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
data2 D00 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][0]),
.ena(ena[0]),
.wea(wea[0]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[0]),
.doutb(dwb[0][0]),
.enb(enb[0]),
.web(web[0]));
data2 D01 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][1]),
.ena(ena[0]),
.wea(wea[1]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[1]),
.doutb(dwb[0][1]),
.enb(enb[0]),
.web(web[1]));
data2 D02 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][2]),
.ena(ena[0]),
.wea(wea[2]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[2]),
.doutb(dwb[0][2]),
.enb(enb[0]),
.web(web[2]));
data2 D03 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][3]),
.ena(ena[0]),
.wea(wea[3]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[3]),
.doutb(dwb[0][3]),
.enb(enb[0]),
.web(web[3]));
data2 D04 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][4]),
.ena(ena[0]),
.wea(wea[4]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[4]),
.doutb(dwb[0][4]),
.enb(enb[0]),
.web(web[4]));
data2 D05 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][5]),
.ena(ena[0]),
.wea(wea[5]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[5]),
.doutb(dwb[0][5]),
.enb(enb[0]),
.web(web[5]));
data2 D06 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][6]),
.ena(ena[0]),
.wea(wea[6]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[6]),
.doutb(dwb[0][6]),
.enb(enb[0]),
.web(web[6]));
data2 D07 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][7]),
.ena(ena[0]),
.wea(wea[7]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[7]),
.doutb(dwb[0][7]),
.enb(enb[0]),
.web(web[7]));
data2 D08 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][8]),
.ena(ena[0]),
.wea(wea[8]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[8]),
.doutb(dwb[0][8]),
.enb(enb[0]),
.web(web[8]));
data2 D09 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][9]),
.ena(ena[0]),
.wea(wea[9]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[9]),
.doutb(dwb[0][9]),
.enb(enb[0]),
.web(web[9]));
data2 D010 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][10]),
.ena(ena[0]),
.wea(wea[10]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[10]),
.doutb(dwb[0][10]),
.enb(enb[0]),
.web(web[10]));
data2 D011 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][11]),
.ena(ena[0]),
.wea(wea[11]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[11]),
.doutb(dwb[0][11]),
.enb(enb[0]),
.web(web[11]));
data2 D012 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][12]),
.ena(ena[0]),
.wea(wea[12]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[12]),
.doutb(dwb[0][12]),
.enb(enb[0]),
.web(web[12]));
data2 D013 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][13]),
.ena(ena[0]),
.wea(wea[13]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[13]),
.doutb(dwb[0][13]),
.enb(enb[0]),
.web(web[13]));
data2 D014 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][14]),
.ena(ena[0]),
.wea(wea[14]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[14]),
.doutb(dwb[0][14]),
.enb(enb[0]),
.web(web[14]));
data2 D015 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[0][15]),
.ena(ena[0]),
.wea(wea[15]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[15]),
.doutb(dwb[0][15]),
.enb(enb[0]),
.web(web[15]));
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
data2 D10 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][0]),
.ena(ena[1]),
.wea(wea[0]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[0]),
.doutb(dwb[1][0]),
.enb(enb[1]),
.web(web[0]));
data2 D11 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][1]),
.ena(ena[1]),
.wea(wea[1]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[1]),
.doutb(dwb[1][1]),
.enb(enb[1]),
.web(web[1]));
data2 D12 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][2]),
.ena(ena[1]),
.wea(wea[2]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[2]),
.doutb(dwb[1][2]),
.enb(enb[1]),
.web(web[2]));
data2 D13 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][3]),
.ena(ena[1]),
.wea(wea[3]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[3]),
.doutb(dwb[1][3]),
.enb(enb[1]),
.web(web[3]));
data2 D14 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][4]),
.ena(ena[1]),
.wea(wea[4]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[4]),
.doutb(dwb[1][4]),
.enb(enb[1]),
.web(web[4]));
data2 D15 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][5]),
.ena(ena[1]),
.wea(wea[5]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[5]),
.doutb(dwb[1][5]),
.enb(enb[1]),
.web(web[5]));
data2 D16 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][6]),
.ena(ena[1]),
.wea(wea[6]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[6]),
.doutb(dwb[1][6]),
.enb(enb[1]),
.web(web[6]));
data2 D17 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][7]),
.ena(ena[1]),
.wea(wea[7]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[7]),
.doutb(dwb[1][7]),
.enb(enb[1]),
.web(web[7]));
data2 D18 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][8]),
.ena(ena[1]),
.wea(wea[8]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[8]),
.doutb(dwb[1][8]),
.enb(enb[1]),
.web(web[8]));
data2 D19 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][9]),
.ena(ena[1]),
.wea(wea[9]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[9]),
.doutb(dwb[1][9]),
.enb(enb[1]),
.web(web[9]));
data2 D110 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][10]),
.ena(ena[1]),
.wea(wea[10]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[10]),
.doutb(dwb[1][10]),
.enb(enb[1]),
.web(web[10]));
data2 D111 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][11]),
.ena(ena[1]),
.wea(wea[11]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[11]),
.doutb(dwb[1][11]),
.enb(enb[1]),
.web(web[11]));
data2 D112 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][12]),
.ena(ena[1]),
.wea(wea[12]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[12]),
.doutb(dwb[1][12]),
.enb(enb[1]),
.web(web[12]));
data2 D113 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][13]),
.ena(ena[1]),
.wea(wea[13]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[13]),
.doutb(dwb[1][13]),
.enb(enb[1]),
.web(web[13]));
data2 D114 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][14]),
.ena(ena[1]),
.wea(wea[14]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[14]),
.doutb(dwb[1][14]),
.enb(enb[1]),
.web(web[14]));
data2 D115 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[1][15]),
.ena(ena[1]),
.wea(wea[15]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[15]),
.doutb(dwb[1][15]),
.enb(enb[1]),
.web(web[15]));
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
data2 D20 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][0]),
.ena(ena[2]),
.wea(wea[0]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[0]),
.doutb(dwb[2][0]),
.enb(enb[2]),
.web(web[0]));
data2 D21 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][1]),
.ena(ena[2]),
.wea(wea[1]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[1]),
.doutb(dwb[2][1]),
.enb(enb[2]),
.web(web[1]));
data2 D22 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][2]),
.ena(ena[2]),
.wea(wea[2]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[2]),
.doutb(dwb[2][2]),
.enb(enb[2]),
.web(web[2]));
data2 D23 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][3]),
.ena(ena[2]),
.wea(wea[3]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[3]),
.doutb(dwb[2][3]),
.enb(enb[2]),
.web(web[3]));
data2 D24 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][4]),
.ena(ena[2]),
.wea(wea[4]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[4]),
.doutb(dwb[2][4]),
.enb(enb[2]),
.web(web[4]));
data2 D25 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][5]),
.ena(ena[2]),
.wea(wea[5]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[5]),
.doutb(dwb[2][5]),
.enb(enb[2]),
.web(web[5]));
data2 D26 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][6]),
.ena(ena[2]),
.wea(wea[6]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[6]),
.doutb(dwb[2][6]),
.enb(enb[2]),
.web(web[6]));
data2 D27 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][7]),
.ena(ena[2]),
.wea(wea[7]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[7]),
.doutb(dwb[2][7]),
.enb(enb[2]),
.web(web[7]));
data2 D28 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][8]),
.ena(ena[2]),
.wea(wea[8]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[8]),
.doutb(dwb[2][8]),
.enb(enb[2]),
.web(web[8]));
data2 D29 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][9]),
.ena(ena[2]),
.wea(wea[9]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[9]),
.doutb(dwb[2][9]),
.enb(enb[2]),
.web(web[9]));
data2 D210 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][10]),
.ena(ena[2]),
.wea(wea[10]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[10]),
.doutb(dwb[2][10]),
.enb(enb[2]),
.web(web[10]));
data2 D211 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][11]),
.ena(ena[2]),
.wea(wea[11]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[11]),
.doutb(dwb[2][11]),
.enb(enb[2]),
.web(web[11]));
data2 D212 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][12]),
.ena(ena[2]),
.wea(wea[12]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[12]),
.doutb(dwb[2][12]),
.enb(enb[2]),
.web(web[12]));
data2 D213 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][13]),
.ena(ena[2]),
.wea(wea[13]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[13]),
.doutb(dwb[2][13]),
.enb(enb[2]),
.web(web[13]));
data2 D214 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][14]),
.ena(ena[2]),
.wea(wea[14]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[14]),
.doutb(dwb[2][14]),
.enb(enb[2]),
.web(web[14]));
data2 D215 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[2][15]),
.ena(ena[2]),
.wea(wea[15]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[15]),
.doutb(dwb[2][15]),
.enb(enb[2]),
.web(web[15]));
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
data2 D30 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][0]),
.ena(ena[3]),
.wea(wea[0]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[0]),
.doutb(dwb[3][0]),
.enb(enb[3]),
.web(web[0]));
data2 D31 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][1]),
.ena(ena[3]),
.wea(wea[1]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[1]),
.doutb(dwb[3][1]),
.enb(enb[3]),
.web(web[1]));
data2 D32 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][2]),
.ena(ena[3]),
.wea(wea[2]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[2]),
.doutb(dwb[3][2]),
.enb(enb[3]),
.web(web[2]));
data2 D33 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][3]),
.ena(ena[3]),
.wea(wea[3]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[3]),
.doutb(dwb[3][3]),
.enb(enb[3]),
.web(web[3]));
data2 D34 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][4]),
.ena(ena[3]),
.wea(wea[4]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[4]),
.doutb(dwb[3][4]),
.enb(enb[3]),
.web(web[4]));
data2 D35 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][5]),
.ena(ena[3]),
.wea(wea[5]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[5]),
.doutb(dwb[3][5]),
.enb(enb[3]),
.web(web[5]));
data2 D36 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][6]),
.ena(ena[3]),
.wea(wea[6]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[6]),
.doutb(dwb[3][6]),
.enb(enb[3]),
.web(web[6]));
data2 D37 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][7]),
.ena(ena[3]),
.wea(wea[7]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[7]),
.doutb(dwb[3][7]),
.enb(enb[3]),
.web(web[7]));
data2 D38 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][8]),
.ena(ena[3]),
.wea(wea[8]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[8]),
.doutb(dwb[3][8]),
.enb(enb[3]),
.web(web[8]));
data2 D39 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][9]),
.ena(ena[3]),
.wea(wea[9]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[9]),
.doutb(dwb[3][9]),
.enb(enb[3]),
.web(web[9]));
data2 D310 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][10]),
.ena(ena[3]),
.wea(wea[10]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[10]),
.doutb(dwb[3][10]),
.enb(enb[3]),
.web(web[10]));
data2 D311 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][11]),
.ena(ena[3]),
.wea(wea[11]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[11]),
.doutb(dwb[3][11]),
.enb(enb[3]),
.web(web[11]));
data2 D312 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][12]),
.ena(ena[3]),
.wea(wea[12]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[12]),
.doutb(dwb[3][12]),
.enb(enb[3]),
.web(web[12]));
data2 D313 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][13]),
.ena(ena[3]),
.wea(wea[13]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[13]),
.doutb(dwb[3][13]),
.enb(enb[3]),
.web(web[13]));
data2 D314 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][14]),
.ena(ena[3]),
.wea(wea[14]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[14]),
.doutb(dwb[3][14]),
.enb(enb[3]),
.web(web[14]));
data2 D315 (.addra(suoyin),
.clka(clk),
.dina(dw),
.douta(cdat[3][15]),
.ena(ena[3]),
.wea(wea[15]),
.addrb(suoyin2),
.clkb(clk),
.dinb(dr[15]),
.doutb(dwb[3][15]),
.enb(enb[3]),
.web(web[15]));
lru  L3 (.addra(suoyin),
.clka(clk),
.dina(lruin[3]),
.douta(lru[3]),
.ena(1),
.wea(wel[3]));
endmodule
