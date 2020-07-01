`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/14 09:47:53
// Design Name: 
// Module Name: pipCPU
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


module pipCPU
    (input clk,
    input resetn,
    input [5:0] ext_int//硬件中断信号
    );
reg [31:0] a,b,wd,d1,cp0_data,aimdata,aimdata1,aimdata2,aimdata3,pc,r_pc,r_spo,r_bpo,r_bpo0,r_b2po,r_b2po0,HI,LO,r_a,r_b,r_a1,r_b1,r_a2,r_b2,r_ar,r_br,r_a1r,r_b1r,r_a2r,r_b2r,ir,ir1,ir2,ir3,ir4,r_y,r_y1,r_addr32;//ir太多.........................
reg [15:0] r_imm,b2value;
reg [7:0] ad0,ad1,dpra,bvalue;
reg [5:0] inscode,inscode1,inscode2,inscode3,inscode4;//指令码
reg [4:0] ra0,ra1,wa,aimaddr,aimaddr1,aimaddr2,aimaddr3,cp0_num;
reg [3:0] m;
reg [2:0] c_pc,sel;
reg [1:0] jump;
reg zero,pd,reins,reins1,reins2,pd1,we,we1,va,va1,va2,va3,va4,zf1,cf1,of1,zf2,cf2,of2,c_inscode1,c_inscode2,c_inscode3,c_inscode4,c_ir1,c_ir2,c_ir3,c_ir4;//c_ir太多...................
wire [31:0] y,pc_8,rd0,rd1,spo0,spo1,addr32,addr0,addr_0,shamt32,BadVAddr,Count,Status,Cause,EPC;
wire [15:0] addr,addr1,addr2,addr3,addr4;//可以优化。。。。。。。。。。。。。。。
wire [7:0] pc1;
wire [5:0] op,funct,op1,funct1,op2,funct2,op3,funct3,op4,funct4;//可以优化................................
wire [4:0] rs,rt,rd,shamt,rs1,rt1,rd01,shamt1,rs2,rt2,rd02,shamt2,rs3,rt3,rd03,shamt3,rs4,rt4,rd04,shamt4;//可以优化。。。。。。。。。。。。。。。。。
wire zf,cf,of,q1,exc,back,rst;


alu alu1(y,zf,cf,of,a,b,m);
register_file register_file(clk,ra0,rd0,ra1,rd1,wa,we,wd,rst);
dist_mem_gen_0 dist_mem_gen_0(ad0,spo0);//指令存储器256深度
dist_mem_gen_1 dist_mem_gen_1(dpra,d1,ad1,clk,we1,spo1);//数据存储器256深度,双端口
CP0 CP0(pc,y,cp0_data,inscode2,inscode3,ext_int,cp0_num,sel,clk,rst,of,va2,va3,reins2,exc,back,BadVAddr,Count,Status,Cause,EPC);

assign pc1=pc[9:2];//截断操作

assign op=ir[31:26];
assign rs=ir[25:21];
assign rt=ir[20:16];
assign rd=ir[15:11];
assign shamt=ir[10:6];
assign funct=ir[5:0];
assign addr=ir[15:0];

assign op1=ir1[31:26];//也许可以简化
assign rs1=ir1[25:21];
assign rt1=ir1[20:16];
assign rd01=ir1[15:11];
assign shamt1=ir1[10:6];
assign funct1=ir1[5:0];
assign addr1=ir1[15:0];

assign op2=ir2[31:26];//也许可以简化
assign rs2=ir2[25:21];
assign rt2=ir2[20:16];
assign rd02=ir2[15:11];
assign shamt2=ir2[10:6];
assign funct2=ir2[5:0];
assign addr2=ir2[15:0];

assign op3=ir3[31:26];//也许可以简化
assign rs3=ir3[25:21];
assign rt3=ir3[20:16];
assign rd03=ir3[15:11];
assign shamt3=ir3[10:6];
assign funct3=ir3[5:0];
assign addr3=ir3[15:0];

assign op4=ir4[31:26];//也许可以简化
assign rs4=ir4[25:21];
assign rt4=ir4[20:16];
assign rd04=ir4[15:11];
assign shamt4=ir4[10:6];
assign funct4=ir4[5:0];
assign addr4=ir4[15:0];

assign q1=r_imm[15];//符号位
assign addr32={q1,q1,q1,q1,q1,q1,q1,q1,q1,q1,q1,q1,q1,q1,q1,q1,r_imm};//位拓展
assign addr0={zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,r_imm};
assign addr_0={r_imm,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero};
assign shamt32={zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,shamt2};
assign pc_8=pc-8;
assign rst=resetn;//sram接口信号

initial zero=0;
initial va=1;
initial pc=0;

always@(posedge clk)//寄存器直接传递
begin
    inscode1<=inscode;//取指
    ir1<=ir;
    reins1<=reins;

    r_a<=rd0;//译码
    r_b<=rd1;
    r_imm<=addr1;
    inscode2<=inscode1;
    ir2<=ir1;
    reins2<=reins1;
    
    r_y<=y;//执行
    zf1<=zf;
    of1<=of;
    cf1<=cf;
    r_addr32<=addr32;    
    r_a1<=r_a;
    r_b1<=r_b;
    aimaddr1<=aimaddr;
    ir3<=ir2;
    
    r_y1<=r_y;//存储器访问
    zf2<=zf1;
    of2<=of1;
    cf2<=cf1;
    va4<=va3;
    r_a2<=r_a1;
    r_b2<=r_b1;
    r_pc<=pc-8;
    r_bpo<={{24{bvalue[7]}},bvalue};
    r_bpo0<={{24{zero}},bvalue};
    r_b2po<={{16{b2value[15]}},b2value};
    r_b2po0<={{16{zero}},b2value};
    if(r_y[0]==0) pd<=1; else pd<=0;
    if(r_y%4==0) pd1<=1; else pd1<=0;
    r_spo<=spo1;
    aimaddr2<=aimaddr1;
    aimdata2<=aimdata1;
    ir4<=ir3;
    
    aimaddr3<=aimaddr2;
    aimdata3<=aimdata2;
end

always@(posedge clk,posedge jump,posedge back,posedge exc)//有效位
begin
    if (jump||back||exc) va1<=0;
    else va1<=va;
    
    if (jump||back||exc) va2<=0;
    else va2<=va1;
    
    if(back||exc) va3<=0;
    else va3<=va2;    
end

always@(posedge clk)//多项选择器
begin
     case(c_pc)//pc取指
        0:;
        1:pc<=pc+4;
        2:pc<=pc-8+4*r_addr32;//跳转时pc加过了12
        3:pc<={pc_8[31:28],4*ir3[25:0]};
        4:pc<=r_a1;
        5:pc<=32'hbfc00380;
        6:pc<=EPC;
     endcase
     
     case(c_inscode3)//指令码继承
        0:;
        1:inscode3<=inscode2;
     endcase 
     
     case(c_inscode4)//指令码继承
        0:;
        1:inscode4<=inscode3;
     endcase
     
end

always@(*)//取指             系统调用接口待定
begin
    if(rst) ;
    else 
        begin
            reins=0;//保留指令
            ad0=pc1;ir=spo0;
            if(back) begin va=0; c_pc=6; end
            else if(exc) begin va=0; c_pc=5; end
            else if(jump==1) begin va=0; c_pc=2; end//若jump则无效
            else if(jump==2) begin va=0; c_pc=3; end
            else if(jump==3) begin va=0; c_pc=4; end
            else begin va=1; c_pc=1; end
            if (op==6'b000000) //指令码生成，此处省略不必要的零值，增加新指令或伪指令会冲突
                begin//inscode==0表示空指令
                    if(funct==6'b100000) inscode=1;//组合逻辑过长，有待优化
                    else if(funct==6'b100001) inscode=3;
                    else if(funct==6'b100010) inscode=5;
                    else if(funct==6'b100011) inscode=6;
                    else if(funct==6'b101010) inscode=7;
                    else if(funct==6'b101011) inscode=9;
                    else if(funct==6'b011010) inscode=11;
                    else if(funct==6'b011011) inscode=12;
                    else if(funct==6'b011000) inscode=13;
                    else if(funct==6'b011001) inscode=14;
                    else if(funct==6'b100100) inscode=15;
                    else if(funct==6'b100111) inscode=18; 
                    else if(funct==6'b100101) inscode=19;
                    else if(funct==6'b100110) inscode=21;
                    else if(funct==6'b000000) inscode=23;
                    else if(funct==6'b000100) inscode=24;
                    else if(funct==6'b000011) inscode=25;
                    else if(funct==6'b000111) inscode=26;
                    else if(funct==6'b000010) inscode=27;
                    else if(funct==6'b000110) inscode=28;
                    else if(funct==6'b001000) inscode=39;
                    else if(funct==6'b001001) inscode=40;
                    else if(funct==6'b010000) inscode=41;
                    else if(funct==6'b010010) inscode=42;
                    else if(funct==6'b010001) inscode=43;
                    else if(funct==6'b010011) inscode=44;
                    else if(funct==6'b001101) inscode=45;
                    else if(funct==6'b001100) inscode=46;
                end
            else if(op==6'b001000) inscode=2;
            else if(op==6'b001001) inscode=4;
            else if(op==6'b001010) inscode=8;
            else if(op==6'b001011) inscode=10;
            else if(op==6'b001100) inscode=16;
            else if(op==6'b001111) inscode=17;
            else if(op==6'b001101) inscode=20;
            else if(op==6'b001110) inscode=22;
            else if(op==6'b000100) inscode=29;
            else if(op==6'b000101) inscode=30;
            else if(op==6'b000001)
                begin
                     if(rt==5'b00001) inscode=31;
                     else if(rt==5'b00000) inscode=34;
                     else if(rt==5'b10001) inscode=36;
                      else if(rt==5'b10000) inscode=35;
                end
            else if(op==6'b000111) inscode=32;
            else if(op==6'b000110) inscode=33;
            else if(op==6'b000010) inscode=37;
            else if(op==6'b000011) inscode=38;
            else if(op==6'b100000) inscode=47;
            else if(op==6'b100100) inscode=48;
            else if(op==6'b100001) inscode=49;
            else if(op==6'b100101) inscode=50;
            else if(op==6'b100011) inscode=51;
            else if(op==6'b101000) inscode=52;
            else if(op==6'b101001) inscode=53;
            else if(op==6'b101011) inscode=54;
            else if(op==6'b010000)
                begin
                    if((rs==5'b10000)&&(funct==6'b011000)) inscode=55;
                    else if(rs==5'b00000) inscode=56;
                    else if(rs==5'b00100) inscode=57;
                end
            else reins=1;
        end
end

always@(*)//译码...之后化繁为简，需用到inscode,rs,rt,addr   rd,shamt
begin
    ra0<=rs1;ra1<=rt1;
end

always@(*)//执行...之后化繁为简，需用到inscode,shamt     rt,rd
begin
    
    c_ir2=1;//可以优化。。。。。。。。。。。。。。。。
    if(rs2==0) r_ar=0;
    else if(rs2==aimaddr1) r_ar=aimdata1;
    else if(rs2==aimaddr2) r_ar=aimdata2;
    else if(rs2==aimaddr3) r_ar=aimdata3;
    else r_ar=r_a;
    if(rt2==0) r_br=0;
    else if(rt2==aimaddr1) r_br=aimdata1;
    else if(rt2==aimaddr2) r_br=aimdata2;
    else if(rt2==aimaddr3) r_br=aimdata3;
    else r_br=r_b;
    if(va2==0) aimaddr=0;
    else if(inscode2==1) begin a=r_ar; b=r_br; m=0; aimaddr=rd02;  end
    else if(inscode2==2) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if(inscode2==3) begin a=r_ar; b=r_br; m=0; aimaddr=rd02; end
    else if(inscode2==4) begin a=r_ar; b=addr32; m=0; aimaddr=rt2;end
    else if(inscode2==5) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end
    else if(inscode2==6) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end
    else if(inscode2==7) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end//不是要存值
    else if(inscode2==8) begin a=r_ar; b=addr32; m=1; aimaddr=rt2; end//不是要存值
    else if(inscode2==9) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end//不是要存值
    else if(inscode2==10) begin a=r_ar; b=addr32; m=1; aimaddr=rt2; end//不是要存值
    else if(inscode2==11) begin a=r_ar; b=r_br; m=7; end//除法待优化。。。。。。。。。。。。。。。。
    else if(inscode2==12) begin a=r_ar; b=r_br; m=7; end//未区分，除法待优化。。。。。。。。。。。。。。。。
    else if(inscode2==13) begin a=r_ar; b=r_br; m=5; end//乘法算法待优化
    else if(inscode2==14) begin a=r_ar; b=r_br; m=6; end//乘法算法待优化
    else if(inscode2==15) begin a=r_ar; b=r_br; m=2; aimaddr=rd02; end
    else if(inscode2==16) begin a=r_ar; b=addr0; m=2; aimaddr=rt2; end
    else if(inscode2==17) begin a=0; b=addr_0; m=0; aimaddr=rt2; end
    else if(inscode2==18) begin a=r_ar; b=r_br; m=3; aimaddr=rd02; end
    else if(inscode2==19) begin a=r_ar; b=r_br; m=3; aimaddr=rd02; end
    else if(inscode2==20) begin a=r_ar; b=addr0; m=3; aimaddr=rt2; end
    else if(inscode2==21) begin a=r_ar; b=r_br; m=4; aimaddr=rd02; end
    else if(inscode2==22) begin a=r_ar; b=addr0; m=4; aimaddr=rt2; end
    else if(inscode2==23) begin a=shamt32; b=r_br; m=8; aimaddr=rd02; end
    else if(inscode2==24) begin a=r_ar; b=r_br; m=8; aimaddr=rd02; end
    else if(inscode2==25) begin a=shamt32; b=r_br; m=10; aimaddr=rd02; end
    else if(inscode2==26) begin a=r_ar; b=r_br; m=10; aimaddr=rd02; end
    else if(inscode2==27) begin a=shamt32; b=r_br; m=9; aimaddr=rd02; end
    else if(inscode2==28) begin a=r_ar; b=r_br; m=9; aimaddr=rd02; end
    else if(inscode2==29) begin a=r_ar; b=r_br; m=1; aimaddr=0; end//另一个alu暂未加上，可加。。。。。。。。。。。。
    else if(inscode2==30) begin a=r_ar; b=r_br; m=1; aimaddr=0; end
    else if((inscode2==47)||(inscode2==48)) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if((inscode2==49)||(inscode2==50)) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if((inscode2==51)||(inscode2==52)) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if((inscode2==53)||(inscode2==54)) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if((inscode2==35)||(inscode2==36)||(inscode2==38)) aimaddr=31;
    else if((inscode2==40)||(inscode2==41)||(inscode2==42)) aimaddr=rd02;
    else if(inscode2==56) aimaddr=rt2;
    else if(inscode2==57) begin a=0; b=r_br; m=0; aimaddr=0; end
end

always@(*)//存储器访问...之后化繁为简，需用到inscode       rt,rd     此处实现跳转
begin
    c_inscode3=1;
    c_ir3=1;//可以优化。。。。。。。。。。。。。。。。。。。。  
    if (rs3==0) r_a1r=0;
    else if(rs3==aimaddr2) r_a1r=aimdata2;
    else if(rs3==aimaddr3) r_a1r=aimdata3;
    else r_a1r=r_a1;   
    if (rt3==0) r_b1r=0;
    else if(rt3==aimaddr2) r_b1r=aimdata2;
    else if(rt3==aimaddr3) r_b1r=aimdata3;
    else r_b1r=r_b1;
    if(va3==0) jump=0;  
    else if(inscode3==29) begin if(zf1==1) jump=1; else jump=0; we1=0; end
    else if(inscode3==30) begin if(zf1==0) jump=1; else jump=0; we1=0; end
    else if(inscode3==31) begin if(r_a1r[31]==0) jump=1; else jump=0; we1=0; end//默认rs为有符号数
    else if(inscode3==32) begin if((r_a1r[31]==0)&&(r_a1r!=0)) jump=1; else jump=0; we1=0; end//默认rs为有符号数
    else if(inscode3==33) begin if((r_a1r[31]==1)||(r_a1r==0)) jump=1; else jump=0; we1=0; end//默认rs为有符号数
    else if(inscode3==34) begin if(r_a1r[31]==1) jump=1; else jump=0; we1=0; end//默认rs为有符号数
    else if(inscode3==35) begin if(r_a1r[31]==1) jump=1; else jump=0; we1=0; aimdata1=pc-8; end//默认rs为有符号数
    else if(inscode3==36) begin if(r_a1r[31]==0) jump=1; else jump=0; we1=0; aimdata1=pc-8; end//默认rs为有符号数
    else if(inscode3==37) begin jump=2; we1=0; end//默认rs为有符号数
    else if(inscode3==38) begin jump=2; we1=0; aimdata1=pc-8; end//默认rs为有符号数
    else if(inscode3==39) begin jump=3; we1=0; end//默认rs为有符号数
    else if(inscode3==40) begin jump=3; we1=0; aimdata1=pc-8; end//默认rs为有符号数
    else if((inscode3==47)||(inscode3==48)) begin jump=0; ad1=r_y/4; we1=0;
                                case(r_y%4)
                                    0:bvalue=spo1[31:24];
                                    1:bvalue=spo1[23:16];
                                    2:bvalue=spo1[15:8];
                                    3:bvalue=spo1[7:0];
                                endcase 
                                if(inscode3==47) aimdata1={{24{bvalue[7]}},bvalue}; else aimdata1={{24{zero}},bvalue};
                          end
    else if((inscode3==49)||(inscode3==50)) begin jump=0; we1=0; ad1=r_y/4; 
                                case(r_y%4)
                                    0:b2value=spo1[31:16];
                                    2:b2value=spo1[15:0];
                                endcase
                                if(inscode3==49) aimdata1={{16{b2value[15]}},b2value}; else aimdata1={{16{zero}},b2value};                                
                          end
    else if(inscode3==51) begin jump=0; we1=0; ad1=r_y/4;aimdata1=spo1; end
    else if(inscode3==52) begin jump=0; we1=1; ad1=r_y/4; dpra=r_y/4;
                                case(r_y%4)
                                    0:d1={r_b1r[7:0],spo1[23:0]};
                                    1:d1={spo1[31:24],r_b1r[7:0],spo1[15:0]};
                                    2:d1={spo1[31:16],r_b1r[7:0],spo1[7:0]};
                                    3:d1={spo1[31:8],r_b1r[7:0]};
                                endcase
                          end
    else if(inscode3==53) begin jump=0; ad1=r_y/4; dpra=r_y/4; if(r_y[0]==0) we1=1; else we1=0;
                                case(r_y%4)
                                    0:d1={r_b1r[15:0],spo1[15:0]};
                                    2:d1={spo1[31:16],r_b1r[15:0]};
                                endcase
                          end
    else if(inscode3==54) begin jump=0; ad1=r_y/4; dpra=r_y/4; if(r_y%4==0) we1=1; else we1=0; d1=r_b1r; end
    else if(inscode3==7) begin jump=0; we1=0; if((~of1&r_y[31]&~zf1)|(of1&~r_y[31]&~zf1))aimdata1=1;else aimdata1=0;  end
    else if(inscode3==8) begin jump=0; we1=0; if((~of1&r_y[31]&~zf1)|(of1&~r_y[31]&~zf1))aimdata1=1;else aimdata1=0;end
    else if(inscode3==9) begin jump=0; we1=0; if(cf1&~zf1) aimdata1=1;else aimdata1=0; end
    else if(inscode3==10) begin jump=0; we1=0; if(cf1&~zf1) aimdata1=1;else aimdata1=0;end
    else if(inscode3==41) begin jump=0; we1=0; aimdata1=HI; end
    else if(inscode3==42) begin jump=0; we1=0; aimdata1=LO; end
    else if(inscode3==56) begin jump=0; we1=0; 
                            if(funct3[2:0]==0)
                            begin
                                case(rd03)
                                    8:aimdata1=BadVAddr;
                                    9:aimdata1=Count;
                                    12:aimdata1=Status;
                                    13:aimdata1=Cause;
                                    14:aimdata1=EPC;
                                default: aimdata1=0;//默认其他为0；暂未考虑地址错误例外...........
                                endcase
                            end
                            else aimdata1=0;
                          end
    else if(inscode3==57) 
        begin
            jump=0; 
            we1=0;
            sel=funct3[2:0];
            cp0_num=rd03;
            cp0_data=r_y;
        end
    else begin jump=0; we1=0; aimdata1=r_y; end

end

always@(*)//寄存器写回...之后化繁为简，需用到inscode,rt,rd
begin
    if(rs4==0) r_a2r=0;
    else if(rs4==aimaddr3) r_a2r=aimdata3;
    else r_a2r=r_a2; 
    if(rt4==0) r_b2r=0;  
    else if(rt4==aimaddr3) r_b2r=aimdata3;
    else r_b2r=r_b2;
    c_inscode4=1;
    c_ir4=1;//可以优化。。。。。。。。。。。。。。。。
    if(va4==0) begin we=0; end
    else if(inscode4==1) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==2) begin we=1; wa=rt4; wd=r_y1; end
    else if(inscode4==3) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==4) begin we=1; wa=rt4; wd=r_y1; end
    else if(inscode4==5) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==6) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==7) begin we=1;if((~of2&r_y1[31]&~zf2)|(of2&~r_y1[31]&~zf2))wd=1;else wd=0; wa=rd04; end
    else if(inscode4==8) begin we=1;if((~of2&r_y1[31]&~zf2)|(of2&~r_y1[31]&~zf2))wd=1;else wd=0; wa=rt4; end
    else if(inscode4==9) begin we=1;if(cf2&~zf2) wd=1;else wd=0; wa=rd04; end
    else if(inscode4==10) begin we=1;if(cf2&~zf2) wd=1;else wd=0; wa=rt4; end
    else if(inscode4==11) begin we=0; LO=r_y1; HI=r_a2r%r_b2r; end//这个寄存器可以在前面写回，省去传递
    else if(inscode4==12) begin we=0; LO=r_y1; HI=r_a2r%r_b2r; end//这个寄存器可以在前面写回，省去传递
    else if(inscode4==13) begin we=0; HI=r_y1; LO=r_a2r*r_b2r; end//这个寄存器可以在前面写回，省去传递
    else if(inscode4==14) begin we=0; HI=r_y1; LO=r_a2r*r_b2r; end//这个寄存器可以在前面写回，省去传递
    else if(inscode4==15) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==16) begin we=1; wa=rt4; wd=r_y1; end
    else if(inscode4==17) begin we=1; wa=rt4; wd=r_y1; end
    else if(inscode4==18) begin we=1; wa=rd04; wd=~r_y1; end
    else if(inscode4==19) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==20) begin we=1; wa=rt4; wd=r_y1; end
    else if(inscode4==21) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==22) begin we=1; wa=rt4; wd=r_y1; end
    else if(inscode4==23) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==24) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==25) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==26) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==27) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==28) begin we=1; wa=rd04; wd=r_y1; end
    else if(inscode4==35) begin we=1; wa=31; wd=r_pc; end//此存
    else if(inscode4==36) begin we=1; wa=31; wd=r_pc; end//此存
    else if(inscode4==38) begin we=1; wa=31; wd=r_pc; end//此存
    else if(inscode4==40) begin we=1; wa=rd04; wd=r_pc; end//此存
    else if(inscode4==41) begin we=1; wa=rd04; wd=HI; end//此存
    else if(inscode4==42) begin we=1; wa=rd04; wd=LO; end//此存
    else if(inscode4==43) begin we=0; HI=r_a2r; end
    else if(inscode4==44) begin we=0; LO=r_a2r; end
    else if(inscode4==47) begin we=1; wa=rt4; wd=r_bpo; end//此存
    else if(inscode4==48) begin we=1; wa=rt4; wd=r_bpo0; end//此存
    else if(inscode4==49) begin if (pd) we=1; else we=0; wa=rt4; wd=r_b2po; end//此存
    else if(inscode4==50) begin if (pd) we=1; else we=0; wa=rt4; wd=r_b2po0; end//此存
    else if(inscode4==51) begin if (pd1) we=1; else we=0; wa=rt4; wd=r_spo; end//此存
    else if(inscode4==56) begin we=1; wa=rt4; wd=aimdata2;end
    else we=0;
end

endmodule
