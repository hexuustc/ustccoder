`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/26 17:24:46
// Design Name: 
// Module Name: CP0
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


module CP0//给定指令默认为分支延迟槽的形式，即分支后一条指令必执行，与CPU有出入;计时器中断由于暂无输入比较，暂不考虑
    (input [31:0] pc,y,cp0_data,
    input [5:0] inscode2,inscode3,ext_int,
    input [4:0] cp0_num,
    input [2:0] sel,
    input clk,rst,of,va2,va3,reins,
    output reg [1:0] exc,
    output reg back,
    output reg [31:0] BadVAddr,Count,Status,Cause,EPC,
    output reg [31:0] cp0_0,cp0_1,cp0_2,cp0_3,cp0_4,cp0_5,cp0_6,cp0_7,cp0_8,cp0_9,
                       cp0_10,cp0_11,cp0_12,cp0_13,cp0_14,cp0_15,cp0_16,cp0_17,cp0_18,cp0_19,
                       cp0_20,cp0_21,cp0_22,cp0_23,cp0_24,cp0_25,cp0_26,cp0_27,cp0_28,cp0_29,
                       cp0_30,cp0_31
    );
reg [31:0] pc1,pc2;
reg clk2;
reg reins_check;
wire EXL;

assign EXL=Status[1];

initial Count=0;
initial clk2=1;
initial exc=0;
initial back=0;
initial pc1=0;
initial pc2=0;
initial reins_check=0;
initial Status[15:8]=0;

always@(posedge clk,posedge rst)
begin
    Status[31:23]<=0;
    Status[22]<=1;
    Status[21:16]<=0;//中断情况暂不清楚，IM有待增加
    Status[7:2]<=0;
    Cause[30:16]<=0;//IP暂不知对应关系
    Cause[7]<=0;
    Cause[1:0]<=0;
    pc1<=pc;
    pc2<=pc1;
    Cause[15:10]<=ext_int;
    if(reins) reins_check<=1;
    if(rst) begin
                Status[1]<=0;
                Status[0]<=0;//为什么复位值为0，屏蔽中断
                Status[9:8]<=0;
                BadVAddr<=0;
                Cause[31]<=0;
                Cause[30]<=0;
                Cause[9:8]<=0;
                Cause[6:2]<=0;
                EPC<=0;
                exc<=0;
            end
    else if(va2&&(inscode2==55))//返回指令
        begin
            Status[1]<=0;
            Status[0]<=0;
            exc<=0;
        end
    else if(va2&&(inscode2==57))//特权指令存值
        begin
            if(sel==0)
                begin
                    if(cp0_num==0) cp0_0<=cp0_data;
                    else if(cp0_num==1) cp0_1<=cp0_data;
                    else if(cp0_num==2) cp0_2<=cp0_data;
                    else if(cp0_num==3) cp0_3<=cp0_data;
                    else if(cp0_num==4) cp0_4<=cp0_data;
                    else if(cp0_num==5) cp0_5<=cp0_data;
                    else if(cp0_num==6) cp0_6<=cp0_data;
                    else if(cp0_num==7) cp0_7<=cp0_data;
                    else if(cp0_num==10) cp0_10<=cp0_data;
                    else if(cp0_num==11) cp0_11<=cp0_data;
                    else if(cp0_num==12) begin Status[15:8]<=cp0_data[15:8];Status[1:0]<=cp0_data[1:0];end
                    else if(cp0_num==13)begin Cause[9:8]<=cp0_data[9:8];end
                    else if(cp0_num==14) EPC<=cp0_data;
                    else if(cp0_num==15) cp0_15<=cp0_data;
                    else if(cp0_num==16) cp0_16<=cp0_data;
                    else if(cp0_num==17) cp0_17<=cp0_data;
                    else if(cp0_num==18) cp0_18<=cp0_data;
                    else if(cp0_num==19) cp0_19<=cp0_data;
                    else if(cp0_num==20) cp0_20<=cp0_data;
                    else if(cp0_num==21) cp0_21<=cp0_data;
                    else if(cp0_num==22) cp0_22<=cp0_data;
                    else if(cp0_num==23) cp0_23<=cp0_data;
                    else if(cp0_num==24) cp0_24<=cp0_data;
                    else if(cp0_num==25) cp0_25<=cp0_data;
                    else if(cp0_num==26) cp0_26<=cp0_data;
                    else if(cp0_num==27) cp0_27<=cp0_data;
                    else if(cp0_num==28) cp0_28<=cp0_data;
                    else if(cp0_num==29) cp0_29<=cp0_data;
                    else if(cp0_num==30) cp0_30<=cp0_data;
                    else if(cp0_num==31) cp0_31<=cp0_data;
                end
        end
    else if(~EXL&&Status[0]&&Cause[15:8])//中断
        begin
            Status[1]<=1;
            if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12; exc<=2;end
                 else begin Cause[31]<=0;EPC<=pc-8; exc<=1; end//注意pc可改变了
            Cause[30]<=0;
            Cause[6:2]<=0;      
        end
    else if(va2&&(pc2[1:0])&&~EXL)//取指错误
                begin
                        BadVAddr<=pc2;
                        Status[1]<=1;
                        if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12;exc<=2; end
                        else begin Cause[31]<=0;EPC<=pc-8; exc<=1;end//注意pc可改变了；是否真有效，两个跳转？
                        Cause[30]<=0;//不知何时为1.。。。。。。。。。。。。
                        Cause[6:2]<=4;
                end
    else if(va2&&((((inscode2==49)||(inscode2==50)||(inscode2==53))&&(y[0]==1))||(((inscode2==51)||(inscode2==54))&&(y[1:0]!=0)))&&~EXL) //地址错例外
        begin
            if((inscode2==49)||(inscode2==50)||(inscode2==53))
                begin
                    if(~EXL&&(y[0]==1))
                        begin
                            BadVAddr<=y;
                            Status[1]<=1;
                            if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12;exc<=2; end
                            else begin Cause[31]<=0;EPC<=pc-8;exc<=1; end//注意pc可改变了；是否真有效，两个跳转？
                            Cause[30]<=0;
                            if((inscode2==49)||(inscode2==50))
                                Cause[6:2]<=4;
                            else if(inscode2==53)
                                Cause[6:2]<=5;
                        end
                end
            else if((inscode2==51)||(inscode2==54))
                begin
                    if(~EXL&&(y[1:0]!=0))
                        begin
                            BadVAddr<=y;
                            Status[1]<=1;
                            if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12;exc<=2; end
                            else begin Cause[31]<=0;EPC<=pc-8;exc<=1; end//注意pc可改变了；是否真有效，两个跳转？
                            Cause[30]<=0;
                            if(inscode2==51)
                                Cause[6:2]<=4;
                            else if(inscode2==54)
                                Cause[6:2]<=5;
                        end
                end
        end
    else if(va2&&(inscode2==46)&&~EXL)//系统调用例外
        begin
            Status[1]<=1;
            if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12;exc<=2; end
                 else begin Cause[31]<=0;EPC<=pc-8;exc<=1; end//注意pc可改变了；是否真有效，两个跳转？
            Cause[30]<=0;
            Cause[6:2]<=8;
        end
    else if(va2&&(inscode2==45)&&~EXL)//断点例外
        begin
            Status[1]<=1;
            if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12;exc<=2; end
                else begin Cause[31]<=0;EPC<=pc-8; exc<=1;end//注意pc可改变了；是否真有效，两个跳转？
            Cause[30]<=0;
            Cause[6:2]<=9;
        end
    else if((reins||reins_check)&&~EXL)//保留指令例外
        begin
            Status[1]<=1;
            if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12;exc<=2; end
            else begin Cause[31]<=0;EPC<=pc-8;exc<=1; end//注意pc可改变了；是否真有效，两个跳转？
            Cause[30]<=0;//不知何时为1.。。。。。。。。。。。。
            Cause[6:2]<=10;
            reins_check<=0;
        end
    else if(va2&&((inscode2==1)||(inscode2==2)||(inscode2==5))&&of&&~EXL) //整形溢出例外
         begin 
             Status[1]<=1;
             if(va3&&(inscode3>=29)&&(inscode3<=40)) begin Cause[31]<=1; EPC<=pc-12; exc<=2;end
                 else begin Cause[31]<=0;EPC<=pc-8; exc<=1;end//注意pc可改变了
             Cause[30]<=0;
             Cause[6:2]<=12;
         end
    else if(~EXL)//没有例外
        exc<=0;
    else exc<=0;
    
end

always@(*)
begin
    cp0_8=BadVAddr;
    cp0_9=Count;
    cp0_12=Status;
    cp0_13=Cause;
    cp0_14=EPC;
end

always@(*)//返回指令
begin
    if(inscode2==55)
        begin
            back=1;
        end
    else back=0;
end

always@(posedge clk)
    if(clk) clk2<=~clk2;

always@(posedge clk2,posedge rst)
    if(rst) Count<=0;
    else if(va3&&(inscode3==57))
        begin
            if(sel==0)
                begin
                    if(cp0_num==9) Count<=cp0_data;
                end
        end
    else Count<=Count+1;

endmodule
