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
    input rst
    );
reg [31:0] a,b,wd,d1,pc,HI,LO,r_a,r_b,r_a1,r_b1,r_a2,r_b2,ir,ir1,ir2,ir3,ir4,r_y,r_y1,r_addr32;//ir太多.........................
reg [15:0] r_imm;
reg [7:0] ad0,ad1;
reg [5:0] inscode,inscode1,inscode2,inscode3,inscode4;//指令码
reg [4:0] ra0,ra1,wa;
reg [3:0] m;
reg [1:0] c_pc;
reg zero,we,we1,jump,va,va1,va2,va3,va4,zf1,cf1,of1,zf2,cf2,of2,c_inscode1,c_inscode2,c_inscode3,c_inscode4,c_ir1,c_ir2,c_ir3,c_ir4;//c_ir太多...................
wire [31:0] y,rd0,rd1,spo0,spo1,addr32,addr0,addr_0,shamt32;
wire [15:0] addr,addr1,addr2,addr3,addr4;//可以优化。。。。。。。。。。。。。。。
wire [7:0] pc1;
wire [5:0] op,funct,op1,funct1,op2,funct2,op3,funct3,op4,funct4;//可以优化................................
wire [4:0] rs,rt,rd,shamt,rs1,rt1,rd01,shamt1,rs2,rt2,rd02,shamt2,rs3,rt3,rd03,shamt3,rs4,rt4,rd04,shamt4;//可以优化。。。。。。。。。。。。。。。。。
wire zf,cf,of,q1;


alu alu1(y,zf,cf,of,a,b,m);
register_file register_file(clk,ra0,rd0,ra1,rd1,wa,we,wd,rst);
dist_mem_gen_0 dist_mem_gen_0(ad0,spo0);//指令存储器256深度
dist_mem_gen_1 dist_mem_gen_1(ad1,d1,clk,we1,spo1);//数据存储器256深度

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

initial zero=0;
initial va=1;

always@(posedge clk)//寄存器直接传递
begin

    r_a<=rd0;//译码
    r_b<=rd1;
    r_imm<=addr1;
    
    r_y<=y;//执行
    zf1<=zf;
    of1<=of;
    cf1<=cf;
    r_addr32<=addr32;
    va3<=va2;
    r_a1<=r_a;
    r_b1<=r_b;
    
    r_y1<=r_y;//存储器访问
    zf2<=zf1;
    of2<=of1;
    cf2<=cf1;
    va4<=va3;
    r_a2<=r_a1;
    r_b2<=r_b1;
end

always@(posedge clk,posedge jump)//有效位
begin
    if (jump) va1<=0;
    else va1<=va;
    
    if (jump) va2<=0;
    else va2<=va;
end

always@(posedge clk)//多项选择器
begin
     case(c_pc)//pc取指，跳转增加新数，待完成。。。。。。。。。。。。。。。。
        0:;
        1:pc<=pc+4;
        2:pc<=pc-8+4*r_addr32;//跳转时pc加过了12
     endcase
     
     case(c_inscode1)//指令码继承
        0:;
        1:inscode1<=inscode;
     endcase 
     
     case(c_inscode2)//指令码继承
        0:;
        1:inscode2<=inscode1;
     endcase 
     
     case(c_inscode3)//指令码继承
        0:;
        1:inscode3<=inscode2;
     endcase 
     
     case(c_inscode4)//指令码继承
        0:;
        1:inscode4<=inscode3;
     endcase
     
     case(c_ir1)//指令继承
        0:;
        1:ir1<=ir;
     endcase
     
end

always@(*)//取指
begin
    if(rst) ;
    else 
        begin
            ad0=pc1;ir=spo0;
            if(jump) begin va=0; c_pc=2; end//若jump则无效
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
        end
end

always@(*)//译码...之后化繁为简，需用到inscode,rs,rt,addr   rd,shamt
begin
    c_inscode1=1;//指令码继承
    c_ir1=1;//指令继承
    ra0=rs1;ra1=rt1;
end

always@(*)//执行...之后化繁为简，需用到inscode,shamt     rt,rd
begin
    c_inscode2=1;
    c_ir2=1;//可以优化。。。。。。。。。。。。。。。。
    if(inscode2==1) begin a=r_a; b=r_b; m=0; end
    else if(inscode2==2) begin a=r_a; b=addr32; m=0; end
    else if(inscode2==3) begin a=r_a; b=r_b; m=0; end
    else if(inscode2==4) begin a=r_a; b=addr32; m=0; end
    else if(inscode2==5) begin a=r_a; b=r_b; m=1; end
    else if(inscode2==6) begin a=r_a; b=r_b; m=1; end
    else if(inscode2==7) begin a=r_a; b=r_b; m=1; end
    else if(inscode2==8) begin a=r_a; b=addr32; m=1; end
    else if(inscode2==9) begin a=r_a; b=r_b; m=1; end
    else if(inscode2==10) begin a=r_a; b=addr32; m=1; end
    else if(inscode2==11) begin a=r_a; b=r_b; m=7; end//除法待优化。。。。。。。。。。。。。。。。
    else if(inscode2==12) begin a=r_a; b=r_b; m=7; end//未区分，除法待优化。。。。。。。。。。。。。。。。
    else if(inscode2==13) begin a=r_a; b=r_b; m=5; end//乘法算法待优化
    else if(inscode2==14) begin a=r_a; b=r_b; m=6; end//乘法算法待优化
    else if(inscode2==15) begin a=r_a; b=r_b; m=2; end
    else if(inscode2==16) begin a=r_a; b=addr0; m=2; end
    else if(inscode2==17) begin a=0; b=addr_0; m=0; end
    else if(inscode2==18) begin a=r_a; b=r_b; m=3; end
    else if(inscode2==19) begin a=r_a; b=r_b; m=3; end
    else if(inscode2==20) begin a=r_a; b=addr0; m=3; end
    else if(inscode2==21) begin a=r_a; b=r_b; m=4; end
    else if(inscode2==22) begin a=r_a; b=addr0; m=4; end
    else if(inscode2==23) begin a=shamt32; b=r_b; m=8; end
    else if(inscode2==24) begin a=r_a; b=r_b; m=8; end
    else if(inscode2==25) begin a=shamt32; b=r_b; m=10; end
    else if(inscode2==26) begin a=r_a; b=r_b; m=10; end
    else if(inscode2==27) begin a=shamt32; b=r_b; m=9; end
    else if(inscode2==28) begin a=r_a; b=r_b; m=9; end
    else if(inscode2==29) begin a=r_a; b=r_b; m=1; end//另一个alu暂未加上，可加。。。。。。。。。。。。
    else if(inscode2==30) begin a=r_a; b=r_b; m=1; end
end

always@(*)//存储器访问...之后化繁为简，需用到inscode,rs       rt,rd     此处实现跳转
begin
    c_inscode3=1;
    c_ir3=1;//可以优化。。。。。。。。。。。。。。。。。。。。
    if(va3==0) jump=0;  
    else if(inscode3==29) begin if(zf1==1) jump=1; else jump=0; end
    else if(inscode3==30) begin if(zf1==0) jump=1; else jump=0; end
  
end

always@(*)//寄存器写回...之后化繁为简，需用到inscode,rt,rd
begin
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
    else if(inscode4==11) begin we=0; LO=r_y1; HI=r_a2%r_b; end//这个寄存器可以在前面写回，省去传递
    else if(inscode4==12) begin we=0; LO=r_y1; HI=r_a2%r_b2; end//这个寄存器可以在前面写回，省去传递
    else if(inscode4==13) begin we=0; HI=r_y1; LO=r_a2*r_b2; end//这个寄存器可以在前面写回，省去传递
    else if(inscode4==14) begin we=0; HI=r_y1; LO=r_a2*r_b2; end//这个寄存器可以在前面写回，省去传递
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
  
    
end

endmodule
