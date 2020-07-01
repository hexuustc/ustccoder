`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/14 17:02:45
// Design Name: 
// Module Name: 5L
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


module LSX(
input clk,
input rst1
    );
integer i=0;
wire [31:0] jra,wd,wd1,wd2,wd3,a1x,b1x,ja,ja1,pcin,pcin1,pcin2,pcin3,pcin4,tz0,tz1,cpa,cp0,cp1,hi,lo,hi1,lo1,hic,loc,hic1,loc1,dat,dat1,y,y1,y2,a,ax,bx,b,b1,addr,ins,ins1,ins2,npc,npc1,npc2,npc3,npc4,d1,d1n,d2,d2n,tz,imm;
wire [4:0] wa,wa0,wa1,wax,wax1,wax2,ra1,ra2,ex,ex1,ashu,ashu1;
wire [3:0] aluc;
reg [1:0] fu1,fu2;
reg idf,pcwe,ifwe,liwai,pcsrc;
reg [31:0] mdat;
wire [2:0] wdx,wdx1,wdx2,wdx3,lsc,lsc1,lsc2,zhx,zhx1,zhx2,wb,wb1,wb2,wb3,m,m1,m2;
wire [3:0] aluop,aluop1;
wire [5:0] ft;
wire ff,dmh,dml,mh,ml,rst,jr,zf,zf1,iff,dm,v,mtw,mtr,alrc,tzx,ert,of,j,zd,blzl,blzlop,blzlf,rst3;
reg [31:0] CP0[15:0];
//数据通路
assign rst=rst3|ff;//rst为IF/ID,ID/EX用，跳转和乘法都会将其置1。
assign rst3=rst1|iff;//3种rst信号，rst3为EX/MEM用，只有跳转会将其置1，rst1为MEM/WB用，不会置一。
assign iff=pcsrc|m2[0]|liwai|m2[1];
PC PC1 (clk,rst1,pcin,addr);
insmem mem1 (.a(addr[31:2]),.spo(ins));
assign npc=addr+32'b100;
//IF/ID
Rn #(32) IR(clk,rst,ins,ins1);
Rn #(32) NPC(clk,rst,npc,npc1);
//ID
register_file1 #(32) RF1 (clk,ins1[25:21],d1,ins1[20:16],d2,wax2,wb3[1],wd.alrc,npc1);
tuozhan T1 (ins1[15:0],tz0);
assign tz1={16'b0,ins1[15:0]};
assign tz=tzx?tz1:tz0;
CT1 CON(.insop(ins1[31:26]),
        .funct(ins1[5:0]),
        .bc(ins1[20:16]),
        .mc(ins1[25:21]),
        .memtoreg(wb[0]),
        .j(m[0]),
        .jr(m[1]),
        .alr(alrc),
        .tzx(tzx),
        .regwrite(wb[1]),
        .blzlop(blzlop),
        .alusrc(ex[0]),
        .regdst(ex[1]),
        .ert(ert),
        .memwrite(m[2]),
        .mtr(wb[2]),
        .mtw(ex[2]),
        .lui(ex[3]),
        .bgl(ex[4]),
        .zhx(zhx),
        .lsc(lsc),
        .op(aluop));
//ID/EX
Rn #(32) A(clk,rst1,d1,d1n);
Rn #(32) B(clk,rst1,d2,d2n);
Rn #(32) IMM(clk,rst1,tz,imm);
Rn #(32) NPC1(clk,rst1,npc1,npc2);
Rn #(5) WA0(clk,rst1,ins1[20:16],wa0);
Rn #(5) WA1(clk,rst1,ins1[15:11],wa1);
Rn #(5) EX(clk,rst,ex,ex1);
Rn #(3) M(clk,rst,m,m1);
Rn #(3) WB(clk,rst,wb,wb1);
Rn #(6) FT(clk,rst1,ins1[5:0],ft);
Rn #(5) RA1(clk,rst1,ins1[25:21],ra1);
Rn #(5) RA2(clk,rst1,ins1[20:16],ra2);
Rn #(32) IR1(clk,rst1,ins1,ins2);
Rn #(3) ZHX(clk,rst,zhx,zhx1);
Rn #(3) LSC(clk,rst,lsc,lsc1);
Rn #(4) ALUOP(clk,rst,aluop,aluop1);
//EX
assign npc3=npc2+(imm<<2);
assign a=v?{27'b0,ins2[10:6]}:a1x;
assign ax=fu1[1]?(fu1[0]?32'h00000010:wd):(fu1[0]?y1:d1n);
assign bx=fu2[1]?(fu2[0]?0:wd):(fu2[0]?y1:d2n);
assign b=ex1[0]?imm:b1x;
assign a1x=ex1[3]?32'h00000010:ax;
assign b1x=ex1[4]?0:bx;
assign wax=ex1[1]?wa1:wa0;
alut #(32) ALU (y,zf,,of,a,b,aluc);
dmu #(32) DMU (hi,lo,ff,d1n,d2n,aluc,dm,clk);//修改DMU
ALUC AC (ft,aluop,aluc,dm,dmh,dml,v,blzlf,mh,ml);
assign cp0=CP0[wa1];
assign ja={npc2[31:28],ins2[25:0],2'b00};
assign blzl=blzlop|blzlf;
//EX/MEM
Rn #(32) NPC2(clk,rst,npc3,npc4);
Rn #(1) ZF(clk,rst3,zf,zf1);
Rn #(32) Y(clk,rst,y,y1);
Rn #(32) B1(clk,rst,d2n,b1);
Rn #(5) WAX(clk,rst,wax,wax1);
Rn #(3) M1(clk,rst3,m1,m2);
Rn #(3) WB1(clk,rst3,wb1,wb2);
Rn #(32) HI(clk,rst,hi,hi1);
Rn #(32) LO(clk,rst,lo,lo1);
Rn #(32) CP1(clk,rst,cp0,cpa);
Rn #(32) JA(clk,rst,ja,ja1);
Rn #(5) ASHU(clk,rst3,{dm,dmh,dml,mh,ml},ashu);
Rn #(3) ZHX1(clk,rst3,zhx1,zhx2);
Rn #(3) LSC1(clk,rst3,lsc1,lsc2);
//MEM
always @ *
case(zhx2)
  3'b000:pcsrc=0;
  3'b001:pcsrc=zf;
  3'b010:pcsrc=~zf;
  3'b011:pcsrc=y[0];
  3'b100:pcsrc=~y[0];
  default:pcsrc=0;
endcase
assign pcin4=m2[1]?y1:npc;
assign pcin3=m2[0]?ja1:pcin4;
assign pcin2=pcsrc?npc4:pcin3;
assign pcin1=ert?CP0[14]:pcin2;
assign pcin=liwai?32'hbfc00380:pcin1;
datamem DT (.a(y1[31:2]),.d(mdat),.clk(clk),.we(m2[2]),.spo(dat));
always @ *
case(lsc2)
  3'b000:begin
         case(y1[1:0])
           2'b00:mdat={dat[7]?24'hffffff:24'h000000,dat[7:0]};
           2'b01:mdat={dat[15]?24'hffffff:24'h000000,dat[15:8]};
           2'b10:mdat={dat[23]?24'hffffff:24'h000000,dat[23:16]};
           2'b11:mdat={dat[31]?24'hffffff:24'h000000,dat[31:24]};
           default:mdat=0;
         endcase
         end
  3'b001:begin
         case(y1[1:0])
           2'b00:mdat={24'h000000,dat[7:0]};
           2'b01:mdat={24'h000000,dat[15:8]};
           2'b10:mdat={24'h000000,dat[23:16]};
           2'b11:mdat={24'h000000,dat[31:24]};
           default:mdat=0;
         endcase
         end
  3'b010:if(y1[1]) mdat={dat[31]?16'hffff:16'h0000,dat[31:16]};
         else mdat={dat[15]?16'hffff:16'h0000,dat[15:0]};
  3'b011:if(y1[1]) mdat={16'h0000,dat[31:16]};
         else mdat={16'h0000,dat[15:0]};
  3'b100:mdat=dat;
  3'b101:begin
         case(y1[1:0])
           2'b00:mdat={dat[31:8],b1[7:0]};
           2'b01:mdat={dat[31:16],b1[7:0],dat[7:0]};
           2'b10:mdat={dat[31:24],b1[7:0],dat[15:0]};
           2'b11:mdat={b1[7:0],dat[23:0]};
           default:mdat=0;
         endcase
         end
  3'b110:if(y1[1]) mdat={b1[15:0],dat[15:0]};
         else mdat={dat[31:16],b1[15:0]};
  3'b111:mdat=dat;
  default:mdat=0;
endcase
PCD HI1 (clk,rst1,ashu[4]|ashu[3],hi1,hic);
PCD LO1 (clk,rst1,ashu[4]|ashu[2],lo1,loc);
//MEM/WB
Rn #(32) MDR(clk,rst1,mdat,dat1);
Rn #(32) Y1(clk,rst1,y1,y2);
Rn #(5) WAX1(clk,rst1,wax1,wax2);
Rn #(3) WB2(clk,rst1,wb2,wb3);
Rn #(32) HIC(clk,rst1,hic,hic1);
Rn #(32) LOC(clk,rst1,loc,loc1);
Rn #(32) CP2(clk,rst1,cpa,cp1);
Rn #(5) ASHU1(clk,rst,ashu,ashu1);
//WB
assign wd3=wb3[0]?dat1:y2;
assign wd2=wb3[2]?cp1:wd3;
assign wd1=ashu1[1]?hic1:wd2;
assign wd=ashu1[0]?loc1:wd1;
//Forwarding unit
always @ *
begin
  fu1=2'b00;fu2=2'b00;
  if(wb3[0])
     if(ra1==wax2) fu1=2'b10;
     if(ra2==wax2) fu2=2'b10;
  if(wb2[0])
     if(ra1==wax1) fu1=2'b01;
     if(ra2==wax1) fu2=2'b01;
end
//CP0
assign zd=0;
always @ (posedge clk or posedge rst1)
begin
if(rst1) begin
        for(i=0;i<16;i=i+1) CP0[i]<=32'b0;
        CP0[12][22]=1;CP0[12][0]=1;
        end
CP0[9]<=CP0[9]+1;
if(zd&CP0[12][0]&~CP0[12][1]) begin                          //中断
                    CP0[14]<=npc2;
                    CP0[12][1]<=1;
                    liwai<=1;
                    if(zhx!=3'b000) CP0[13][31]<=1;
                    CP0[13][8]<=1;
                    end
else if(pcin[1:0]!=2'b00) begin       //取指错误
                          liwai<=1;
                          if(~CP0[12][1]) begin
                            if(zhx!=3'b000) begin
                                            CP0[13][31]<=1;
                                            CP0[14]<=npc2-4'b1000;
                                            end
                            else CP0[14]<=npc2-3'b100;
                          end
                          CP0[12][1]<=1;
                          CP0[13][6:2]<=5'h04;
                          CP0[8]<=pcin;
                          end
else if(blzl) begin   //保留指令例外
              liwai<=1;
              if(~CP0[12][1]) begin
                if(zhx!=3'b000) begin
                              CP0[13][31]<=1;
                              CP0[14]<=npc2-4'b1000;
                              end
                else CP0[14]<=npc2-3'b100;
              end
              CP0[12][1]<=1;
              CP0[13][6:2]<=5'h0a;  
              end  
else if(of)  begin   //整形溢出例外
              liwai<=1;
              if(~CP0[12][1]) begin
                if(zhx!=3'b000) begin
                              CP0[13][31]<=1;
                              CP0[14]<=npc2-4'b1000;
                              end
                else CP0[14]<=npc2-3'b100;
              end
              CP0[12][1]<=1; 
              CP0[13][6:2]<=5'h0c;  
              end
else if(aluc==4'b1100)   begin    //系统调用
              liwai<=1;
              if(~CP0[12][1]) begin
                if(zhx!=3'b000) begin
                              CP0[13][31]<=1;
                              CP0[14]<=npc2-4'b1000;
                              end
                else CP0[14]<=npc2-3'b100;
              end
              CP0[12][1]<=1; 
              CP0[13][6:2]<=5'h08;  
              end     
else if(aluc==4'b1101) begin  //断点例外
              liwai<=1;
              if(~CP0[12][1]) begin
                if(zhx!=3'b000) begin
                              CP0[13][31]<=1;
                              CP0[14]<=npc2-4'b1000;
                              end
                else CP0[14]<=npc2-3'b100;
              end
              CP0[12][1]<=1; 
              CP0[13][6:2]<=5'h09;  
              end
else if((zhx==3'b010||zhx==3'b011)&&y1[0]==1||zhx==3'b100&&y1[1:0]!=0)
              begin
              liwai<=1;
              if(~CP0[12][1]) begin
                if(zhx!=3'b000) begin
                              CP0[13][31]<=1;
                              CP0[14]<=npc2-4'b1000;
                              end
                else CP0[14]<=npc2-3'b100;
              end
              CP0[12][1]<=1; 
              CP0[13][6:2]<=5'h04;
              CP0[8]<=y1;  
              end
else if(zhx==3'b110&&y1[0]==1||zhx==3'b111&&y1[1:0]!=0)
              begin
              liwai<=1;
              if(~CP0[12][1]) begin
                if(zhx!=3'b000) begin
                              CP0[13][31]<=1;
                              CP0[14]<=npc2-4'b1000;
                              end
                else CP0[14]<=npc2-3'b100;
              end
              CP0[12][1]<=1; 
              CP0[13][6:2]<=5'h05;
              CP0[8]<=y1;  
              end
if(ex1[2]==1&&wa1!=5'b01000) CP0[wa1]=d2n;
end
endmodule