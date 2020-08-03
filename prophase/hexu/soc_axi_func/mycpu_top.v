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


module mycpu_top
    (input [5:0] ext_int,
    input aclk,
	input aresetn,
	
    //axi
    //ar
    output reg [3 :0] arid         ,//再判断----------------------
    output reg [31:0] araddr       ,//再判断----------------------
    output [3 :0] arlen        ,
    output reg [2 :0] arsize       ,//再判断----------------------
    output [1 :0] arburst      ,//有点问题
    output [1 :0] arlock        ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output   reg     arvalid      ,//再判断---------------------
    input         arready      ,//等着用+++++++++++++++++++++
    //r           
    input  [3 :0] rid          ,//等着用+++++++++++++++++++++
    input  [31:0] rdata        ,//等着用+++++++++++++++++++++
    input  [1 :0] rresp        ,//无用
    input         rlast        ,//无用
    input         rvalid       ,//等着用+++++++++++++++++++++
    output        rready       ,
    //aw          
    output [3 :0] awid         ,//有点问题
    output reg [31:0] awaddr       ,//再判断---------------------
    output [3 :0] awlen        ,
    output reg [2 :0] awsize       ,//再判断---------------------
    output [1 :0] awburst      ,//有点问题
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output   reg     awvalid      ,//再判断---------------------
    input         awready      ,//等着用+++++++++++++++++++++
    //w          
    output [3 :0] wid          ,//有点问题
    output reg [31:0] wdata        ,//再判断---------------------
    output reg [3 :0] wstrb        ,//再判断---------------------
    output        wlast        ,
    output   reg     wvalid       ,//再判断---------------------
    input         wready       ,//等着用+++++++++++++++++++++
    //b           
    input  [3 :0] bid          ,//无用
    input  [1 :0] bresp        ,//无用
    input         bvalid       ,//等着用+++++++++++++++++++++
    output        bready       ,

    output [31:0] debug_wb_pc,
	output [3:0] debug_wb_rf_wen,
	output [4:0] debug_wb_rf_wnum,
	output [31:0] debug_wb_rf_wdata
    
    
    );
    
wire inst_sram_en;
wire [3:0] inst_sram_wen;
reg [31:0] inst_sram_addr;
wire[31:0] inst_sram_wdata;
reg [31:0] inst_sram_rdata;
    
wire data_sram_en;
reg [3:0] data_sram_wen;
wire [31:0] data_sram_addr;
reg [31:0] data_sram_wdata;
reg [31:0] data_sram_rdata;
     
   
wire clk;
wire resetn;//低电平同步复位
assign clk=aclk;
assign resetn=aresetn;
assign arlen=0;
assign arburst=1;//到底是几。。。。。。。。。。。。。。。。。。。。。。。。。
assign arlock=0;
assign arcache=0;
assign arprot=0;
assign rready=1;
assign awid=1;
assign awlen=0;
assign awburst=1;//到底是几。。。。。。。。。。。。。。。。。。。。。。。。。
assign awlock=0;
assign awcache=0;
assign awprot=0;
assign wid=1;//到底是几。。。。。。。。。。。。。。。。。。。。。。。。。。。
assign wlast=1;
assign bready=1;

reg [31:0] a,b;//alu的输入数据
reg [31:0] a_1,b_1;//alu保存值

reg [31:0] inst_sram_rdata1;
reg [31:0] data_sram_rdata1;

reg [31:0] wd,r_wd;//寄存器写数据
reg [31:0] cp0_data;//传cp0数据
reg [31:0] data_sram_addr1;//前三位非0
reg [31:0] r_y,r_y1;//alu输出y传值
reg [31:0] r_addr32;
//HI,LO
reg [31:0] LO,r_LO;
reg [31:0] HI,r_HI;
//dmu输入数据
reg [31:0] a1,b1;
reg [31:0] a1_1,b1_1;

reg [31:0] aimdata,aimdata1,aimdata2,aimdata3,aimdata4,aimdata5;//目标写数据
reg [31:0] r_aimdata1;//寄存

//PC地址传递寄存器
reg [31:0]pc,pc1,pc2,pc3,pc4;
reg [31:0]r_pc_8;//pc-8

reg [31:0] r_a,r_b,r_a1,r_b1,r_a2,r_b2;//传递rs, rt中值
reg [31:0] r_ar,r_br,r_a1r,r_b1r,r_a2r,r_b2r,r_a3r,r_a4r,r_a5r;//rs, rt相关修正值,

//五个流水段使用到的指令相关
//指令本体
reg [31:0] ir,ir1,ir2,ir3,ir4;
//指令分割
wire [5:0] op,op1,op2,op3,op4;
wire [5:0] funct,funct1,funct2,funct3,funct4;
wire [4:0] rs,rs1,rs2,rs3,rs4;
wire [4:0] rt,rt1,rt2,rt3,rt4;
wire [4:0] rd,rd01,rd02,rd03,rd04;
wire [4:0] shamt,shamt1,shamt2,shamt3,shamt4;

reg [15:0] r_imm;
reg [15:0] b2value;
reg [7:0] bvalue;
//指令码
wire [5:0] inscode1;
reg [5:0] inscode2,inscode3,inscode4,inscode5,inscode6,inscode7;//指令码

reg [4:0] wa,r_wa;//寄存器写地址
reg [4:0] ra0,ra1;
reg [4:0] cp0_num;
//目标写地址
reg [4:0] aimaddr;
wire [4:0] aimaddr1,aimaddr2,aimaddr3,aimaddr4,aimaddr5;
reg [4:0] r_aimaddr,r_aimaddr1,r_aimaddr2,r_aimaddr3,r_aimaddr4;//目标写地址寄存
//alu,dmu操作码
reg [3:0] m;
reg [3:0] m1,m1_1;

reg [2:0] c_pc,sel;
reg [1:0] jump;//指令跳转信号
reg div_begin;//除法开始信号

reg zero;//没什么卵用的zero，当做0的宏定义来用

reg pd,pd1;//数据地址对否判断
reg we;//寄存器写使能
reg zf1,cf1,of1,zf2,cf2,of2;//alu三信号
reg c_inscode3,c_inscode4,c_ir3;
//延迟信号
//reg delay_block,delay_block_1;//取数据相关延迟
reg delay_hl,delay_hl_1;//乘除法相关延迟
reg delay_hl1,delay_hl1_1;
reg delay_sendhl,delay_sendhl_1;//ED取hi,lo相关延迟
//暂停信号
reg pause,pause1,pause2,pause3,pause4,pause5,pause6,pause7;//暂停信号[寄存器]
reg pause1_1,pause2_1,pause3_1,pause4_1,pause5_1,pause6_1,pause7_1;//暂停信号的缓冲[寄存器]
reg stall;
//有效位
reg va,va1,va2,va3,va4,va5,va6,va7;//有效位
reg r_va,r_va1,r_va2,r_va3;

reg reins1,reins2b,reins2,r_reins2;//保留指令

reg r_stall;//stall缓冲


//和计算有关系的wire线,y,zf,cf,of是ALU输出端口
wire [31:0] lo;
wire [31:0] hi;
wire [31:0] y;
wire zf,cf,of;

wire [31:0] pc_8,rd0,rd1;
wire [15:0] addr,addr1,addr2,addr3,addr4;//可以优化。。。。。。。。。。。。。。。
wire [1:0] exc_cp0;//例外
reg [1:0] exc;
wire back,stall_dv;
//cp0的端口
wire [31:0] reins;
//cp0的32个寄存器读口
reg [4:0] cp0_ra;
wire [31:0] cp0_load;
wire [31:0] BadVAddr,Count,Status,Cause,EPC;

//位拓展专用
//标记imm字段的15位，即符号位
wire q1;
//位扩展之后的信号
wire [31:0] addr32,addr0,addr_0;
wire [31:0] shamt32;

alu alu1(y,zf,cf,of,a,b,m);
register_file register_file(clk,ra0,rd0,ra1,rd1,wa,we,wd);
CP0 CP0(pc,y,cp0_data,
        inscode2,inscode3,ext_int,
        cp0_num,
        sel,
        cp0_ra,
        clk,~resetn,of,va2,va3,reins2,pause2,
        exc_cp0,
        back,
        BadVAddr,Count,Status,Cause,EPC,
        cp0_load);
assign reins = reins2;
dmu dmu(hi,lo,stall_dv,a1,b1,m1,clk,div_begin);

//将指令分割成各个部分以方便后续使用
assign {op ,rs ,rt ,rd ,shamt ,funct } = ir ;//IF级指令分割
assign {op1,rs1,rt1,rd01,shamt1,funct1} = ir1;//ID级指令分割
assign {op2,rs2,rt2,rd02,shamt2,funct2} = ir2;//EX级指令分割
assign {op3,rs3,rt3,rd03,shamt3,funct3} = ir3;//MEM级指令分割
assign {op4,rs4,rt4,rd04,shamt4,funct4} = ir4;//WB级指令分割

assign addr  = ir[15:0];
assign addr1 = ir1[15:0];
assign addr2 = ir2[15:0];
assign addr3 = ir3[15:0];
assign addr4 = ir4[15:0];

//位扩展之类的
assign q1=r_imm[15];//取符号位
assign addr32={{16{q1}},r_imm};//根据符号位进行位拓展
assign addr0={{16{zero}},r_imm};//基于0的位扩展，地址高位0
assign addr_0={r_imm,{16{zero}}};//基于0的位扩展，地址低位0
assign shamt32={{27{zero}},shamt2};//shamt字段进行位扩展，高位补0

//意义不明，pc-8
assign pc_8=pc-8;//保存当前-8值，防止后面pc变化

//各个存储器端口的说明
//指令存储器
assign inst_sram_en=1;
assign inst_sram_wen=0;
assign inst_sram_wdata=0;
//数据存储器
assign data_sram_en=1;
assign data_sram_addr={{3{zero}},data_sram_addr1[28:0]};//前三位归零，为什么？
//debug端口
assign debug_wb_pc=pc4;
assign debug_wb_rf_wen=we*4'b1111;
assign debug_wb_rf_wnum=wa;
assign debug_wb_rf_wdata=wd;

//初始化操作

initial zero=0;// 就是0的宏定义，没啥卵用
initial va=1; //va是个寄存器，会变
initial pc=32'hbfc00000;//初始地址为这个，算是一个常量
initial pause=0;
initial pause1=0;
initial pause2=0;
initial pause3=0;
initial pause4=0;

//initial delay_block=0;
initial delay_hl=0;
initial delay_hl1=1;
initial delay_sendhl=0;
initial r_stall=0;

//////////////////////////////////////////////////////
////////////////流水段之间寄存器传递部分////////////////
//////////////////////////////////////////////////////

///////////////////////////
/////IF段前方取指部分//

always@(posedge clk)//寄存器直接传递
begin
    pause1_1<=pause1;
    pause2_1<=pause2;
    pause3_1<=pause3;
    pause4_1<=pause4;
    pause5_1<=pause5;
    pause6_1<=pause6;
    pause7_1<=pause7;
    delay_hl_1<=delay_hl;
    delay_hl1_1<=delay_hl1;
    //delay_block_1<=delay_block;
    if(stall||pause3) delay_sendhl_1<=delay_sendhl_1; 
    else delay_sendhl_1<=delay_sendhl;
    r_stall<=stall_dv;
    if(~resetn) pc1<=0;
    else if(pause1) pc1<=pc1;
    else pc1<=pc;
    if(~resetn) r_va<=0;
    else if(pause1) r_va<=r_va;
    else r_va<=va;
    r_wd<=wd;
    r_wa<=wa;
    r_aimdata1<=aimdata1;
    r_reins2<=reins2;
    
//////////////////////
/////IF to ID:译码/////
if(pause2)
begin
    r_a<=r_a;
    r_b<=r_b;
    r_imm<=r_imm;
    inscode2<=inscode2;
    ir2<=ir2;
    //reins2b<=reins2b;
    pc2<=pc2;
    //r_va1<=r_va1;
end
else
begin
    r_a<=rd0;
    r_b<=rd1;
    r_imm<=addr1;
    inscode2<=inscode1;
    ir2<=ir1;
    //reins2b<=reins1;
    pc2<=pc1;
    //r_va1<=va1;
end

//////////////////////
/////ID to EX:执行/////    
if(pause3)
begin
    r_y<=r_y;
    zf1<=zf1;
    of1<=of1;
    cf1<=cf1;
    r_addr32<=r_addr32;    
    r_a1<=r_a1;
    r_b1<=r_b1;
    ir3<=ir3;
    pc3<=pc3;
    //r_va2<=r_va2;
end
else
begin    
    r_y<=y;
    zf1<=zf;
    of1<=of;
    cf1<=cf;
    r_addr32<=addr32;    
    r_a1<=r_a;
    r_b1<=r_b;
    ir3<=ir2;
    pc3<=pc2;
    //r_va2<=va2;
end

//////////////////////////////
/////EX to MEM:存储器访问///// 
if(pause4||delay_hl||delay_hl1)
begin
    r_y1<=r_y1;
    zf2<=zf2;
    of2<=of2;
    cf2<=cf2;
    r_a2<=r_a2;
    r_b2<=r_b2;
    r_pc_8<=r_pc_8;
    pd<=pd;
    pd1<=pd1;
    ir4<=ir4;
    //r_va3<=r_va3;
end
else
begin    
    r_y1<=r_y;
    zf2<=zf1;
    of2<=of1;
    cf2<=cf1;
    r_a2<=r_a1;
    r_b2<=r_b1;
    r_pc_8<=pc-4;
    if(r_y[0]==0) pd<=1; else pd<=0;
    if(r_y%4==0) pd1<=1; else pd1<=0;
    ir4<=ir3;
    //r_va3<=va3;
end

//////////////////////////////
/////MEM to WB:寄存器写回///// 
if(pause5) 
begin 
    aimdata3<=aimdata3;
    inscode5<=inscode5;
    r_a3r<=r_a3r;
end
else 
    begin 
        aimdata3<=aimdata2;
        inscode5<=inscode4;
        r_a3r<=r_a2r;
    end

if(pause6) 
begin 
    aimdata4<=aimdata4;
    inscode6<=inscode6;
    r_a4r<=r_a4r;
end
else 
    begin 
        aimdata4<=aimdata3;
        inscode6<=inscode5;
        r_a4r<=r_a3r;
    end

if(pause7) 
begin 
    aimdata5<=aimdata5;
    inscode7<=inscode7;
    r_a5r<=r_a5r;
end
else 
    begin 
        aimdata5<=aimdata4;
        inscode7<=inscode6;
        r_a5r<=r_a4r;
    end
end

always@(posedge clk)
begin
    if(pause1)
    inst_sram_rdata1<=inst_sram_rdata1;
    else inst_sram_rdata1<=inst_sram_rdata;
end

always@(posedge clk)
begin
    if(pause4)
    data_sram_rdata1<=data_sram_rdata1;
    else data_sram_rdata1<=data_sram_rdata;
end

always@(*)
begin
    exc=exc_cp0;
end

always @(posedge clk)
begin
    if(~resetn) reins2b<=0;
    else if(exc||Status[1]) reins2b<=0;
    else if(pause2) reins2b<=reins2b;
    else reins2b<=reins1;
end

always@(*)
begin
    if(~resetn) reins2=0;
    else if(~va2) reins2=0;
    else if(exc||Status[1]) reins2<=0;
    else if(stall||pause2) reins2=r_reins2;
    else reins2=reins2b;
end

always@(posedge clk)
begin
    if(~resetn) r_va1<=0;
    else if(pause2) r_va1<=r_va1;
    else r_va1<=va1;
end

always@(posedge clk)
begin
    if(~resetn) r_va2<=0;
    else if(pause3) r_va2<=r_va2;
    else r_va2<=va2;
end

always@(posedge clk)
begin
    if(~resetn) r_va3<=0;
    else if(pause4||delay_hl||delay_hl1) r_va3<=r_va3;
    else r_va3<=va3;
end

always@(*)
begin
    if(stall)
    begin
        pause5=1;
        pause6=1;
        pause7=1;
    end
    else
    begin
        pause5=0;
        pause6=0;
        pause7=0;
    end
end

always@(posedge clk,negedge resetn)
begin
    if(~resetn) va5<=0;
    else if(delay_hl||delay_hl1) va5<=0;
    else if(pause5) va5<=va5;
    else va5<=va4;
    
    if(~resetn) va6<=0;
    else if(pause6) va6<=va6;
    else va6<=va5;
    
    if(~resetn) va7<=0;
    else if(pause7) va7<=va7;
    else va7<=va6;
end

always@(*)
begin
    if(~resetn) va2=0;//这就是分支延迟槽
    else if(pause2) va2=va2;
    else if (exc) va2=0;
    else va2=r_va1;
end

always@(*)
begin
    if(~resetn) va3=0;
   // else if(delay_block_1) va3=0;
    else if(delay_sendhl_1) va3=0;
    else if(pause3_1) va3=va3;
    else if(exc) va3=0;
    else va3=r_va2;
end

always@(*)
begin
    if(~resetn) va4=0;
    else if(pause4_1||delay_hl_1||delay_hl1_1) va4=va4;
    else va4=r_va3;  
end

always@(*)
begin
    if((inscode4==47)||(inscode4==48)||(inscode4==49)||(inscode4==50)||(inscode4==51)) aimdata2=wd;
    else if(inscode4==41) aimdata2=HI;
    else if(inscode4==42) aimdata2=LO;
    else if(pause4_1) aimdata2=aimdata2;
    else aimdata2=r_aimdata1;
end

always@(posedge clk)
begin
    r_aimaddr<=aimaddr;
    r_aimaddr1<=aimaddr1;
    r_aimaddr2<=aimaddr2;
    r_aimaddr3<=aimaddr3;
    r_aimaddr4<=aimaddr4;
end

always@(posedge clk)
begin
    if(pause4||delay_hl||delay_hl1) pc4<=pc4;
    else pc4<=pc3;
end

/////////////////////////////////////
///////////生成aimaddr///////////////
/////////////////////////////////////

////////////////////////
/////aimaddr1生成//
reg [4:0]aimaddr1_curr,aimaddr1_next;
always @(posedge clk)
begin
    aimaddr1_curr <= aimaddr1_next;
end
always @(*)
begin
    if(pause3_1) aimaddr1_next=aimaddr1_curr;
    else if(~va3) aimaddr1_next=0;
    else aimaddr1_next=r_aimaddr;  
end
assign aimaddr1 = aimaddr1_next;

/////////////////////////
/////aimaddr2生成//
reg [4:0]aimaddr2_curr,aimaddr2_next;
always @(posedge clk)
begin
    aimaddr2_curr <= aimaddr2_next;
end
always@(*)
begin
    if(pause4_1||delay_hl_1||delay_hl1_1) aimaddr2_next=aimaddr2_curr;
    else if(~va4) aimaddr2_next=0;
    else aimaddr2_next=r_aimaddr1;    
end
assign aimaddr2 = aimaddr2_next;

//////////////////////////
/////aimaddr3生成//
reg [4:0]aimaddr3_curr,aimaddr3_next;
always @(posedge clk)
begin
    aimaddr3_curr <= aimaddr3_next;
end
always@(*)
begin
    if(pause5_1) aimaddr3_next=aimaddr3_curr;
    else if(~va5) aimaddr3_next=0;
    else aimaddr3_next=r_aimaddr2;    
end
assign aimaddr3 = aimaddr3_next;

////////////////////////////
/////aimaddr4生成//
reg [4:0]aimaddr4_curr,aimaddr4_next;
always @(posedge clk)
begin
    aimaddr4_curr <= aimaddr4_next;
end
always@(*)
begin
    if(pause6_1) aimaddr4_next=aimaddr4_curr;
    else if(~va6) aimaddr4_next=0;
    else aimaddr4_next=r_aimaddr3;    
end
assign aimaddr4 = aimaddr4_next;

//////////////////////////////
/////aimaddr5生成//
reg [4:0]aimaddr5_curr,aimaddr5_next;
always @(posedge clk)
begin
    aimaddr5_curr <= aimaddr5_next;
end
always@(*)
begin
    if(pause7_1) aimaddr5_next=aimaddr5_curr;
    else if(~va7) aimaddr5_next=0;
    else aimaddr5_next=r_aimaddr4;    
end
assign aimaddr5 = aimaddr5_next;

always@(posedge clk)//多项选择器
begin
     case(c_pc)//pc取指
        0:pc<=pc;
        1:pc<=pc+4;
        2:pc<=pc-8+4*r_addr32;//跳转时pc加过了12
        3:pc<={pc_8[31:28],ir3[25:0],{2{zero}}};
        4:pc<=r_a1r;
        5:pc<=32'hbfc00380;
        6:pc<=EPC;
        7:pc<=32'hbfc00000;
     default:pc<=32'hbfc00000;
     endcase
     
     case(c_inscode3)//指令码继承
        0:inscode3<=inscode3;
        1:inscode3<=inscode2;
        default:inscode3<=inscode3;
     endcase 
     
     case(c_inscode4)//指令码继承
        0:inscode4<=inscode4;
        1:inscode4<=inscode3;
        default:inscode4<=inscode4;
     endcase
     
end

always@(*)
begin
    case(inscode3)
        35: aimdata1=pc-4;
        36: aimdata1=pc-4;
        38: aimdata1=pc-4;
        40: aimdata1=pc-4;
        7:  if((~of1&r_y[31]&~zf1)|(of1&~r_y[31]&~zf1))aimdata1=1;else aimdata1=0;
        8:  if((~of1&r_y[31]&~zf1)|(of1&~r_y[31]&~zf1))aimdata1=1;else aimdata1=0;
        9:  if(cf1&~zf1) aimdata1=1;else aimdata1=0;
        10: if(cf1&~zf1) aimdata1=1;else aimdata1=0;
        41: aimdata1=HI;
        42: aimdata1=LO;
        56: if(funct3[2:0]==0)
            begin
                cp0_ra = rd03;
                aimdata1 = cp0_load;
            end
            else aimdata1=0;
        18: aimdata1=~r_y;
        47:aimdata1=data_sram_rdata;
        48:aimdata1=data_sram_rdata;
        49:aimdata1=data_sram_rdata;
        50:aimdata1=data_sram_rdata;
        51:aimdata1=data_sram_rdata;
        default: aimdata1=r_y;
    endcase
end




/*
always@(*)
begin
    rok=0;
    araddr={{3{zero}},inst_sram_addr[28:0]};
        arsize=4;//字节数吗
    if(va&&arready&&~busy_r)
    begin
        arid=0;
        arvalid=1;
        rok=0;
    end
    else if(~va)
    begin
        arid=0;
        arvalid=0;
        rok=1;
    end
    else if()
end*/
wire [31:0] inst_addr;
reg busy_r,busy_w;
reg rok,awok,wok,bok,tok;
reg stallr,stallw,stallrw;
wire va3_r,va3_w;
reg [4:0] rstate,wstate;


always@(*)//所有信号集合
begin
    stall=stall_dv||stallrw;
end

assign inst_addr={{3{zero}},inst_sram_addr[28:0]};
assign va3_r=va3&&(inscode3>=47)&&(inscode3<=51);
assign va3_w=va3&&((inscode3==52)||(inscode3==53)||(inscode3==54));

always@(*)
begin
    if(bok&&tok) stallrw=0;
    else stallrw=1;
end

/*always@(*)
begin
    stallr=1;
    if(~aresetn) 
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
    end
    else if(tok&&~bok)
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        stallr=0;
    end
    else if(tok&&bok)
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        stallr=0;
    end
    else if(va&&arready&&~busy_r&&~rok)//已准备好，还没读指令
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
    end
    else if(va&&busy_r&&~rok&&~rvalid)//已传指令地址，还没返回
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
    end
    else if(va&&rvalid&&~rok)//读指令返回
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        if(rid==0) inst_sram_rdata=rdata; 
        else inst_sram_rdata=inst_sram_rdata; 
    end
    else if(va3_r&&arready&&~busy_r&&rok)//已准备好，已读指令，还没读数据
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;//是不是4呢
        arvalid=1;
    end
    else if(va3_r&&busy_r&&rok&&~rvalid)//已读指令，已传数据地址，还没返回
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else if(va3_r&&rvalid&&rok)//已读指令，读数据已返回
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
        if(rid==1) data_sram_rdata=rdata; 
        else data_sram_rdata=data_sram_rdata;
        stallr=0; 
    end
    else if(~va&&va3_r&&~rok)//不读指令，要读数据
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        arvalid=0;
    end
    else if(~va&&~va3_r&&arready)//都不读，直接取消暂停
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
        if(rid==1) data_sram_rdata=rdata; 
        else data_sram_rdata=data_sram_rdata;
        stallr=0; 
    end
    else if(~va&&~va3_r&&~arready)//都不读
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else if(va&&~va3_r&&rok)//已读指令，不读数据，就取消暂停
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
        stallr=0; 
    end
    else if(va&&~arready&&~busy_r&&~rok&&~rvalid)//初始没准备好
    begin
        arid=0;
        araddr=inst_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else if(va3_r&&~arready&&~busy_r&&rok&&~rvalid)
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else//其他不可预知情况
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
        stallr=0; 
    end
end*/

always@(*)
begin
    
    if(va&&rvalid&&~rok)//读指令返回
    begin
        if(rid==0) inst_sram_rdata=rdata; 
        else inst_sram_rdata=inst_sram_rdata; 
    end
    else if(va3_r&&rvalid&&rok)//已读指令，读数据已返回
    begin
        if(rid==1) data_sram_rdata=rdata; 
        else data_sram_rdata=data_sram_rdata;
    end
    else 
    begin
        inst_sram_rdata=inst_sram_rdata; 
        data_sram_rdata=data_sram_rdata;
    end
end

always@(*)
begin
    stallr=1;
    if(rstate==0) 
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==1)
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        stallr=0;
        arvalid=0;
    end
    else if(rstate==2)
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        stallr=0;
        arvalid=0;
    end
    else if(rstate==3)//已准备好，还没读指令
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        arvalid=1;
    end
    else if(rstate==4)//已传指令地址，还没返回
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==5)//读指令返回
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==6)//已准备好，已读指令，还没读数据
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;//是不是4呢
        arvalid=1;
    end
    else if(rstate==7)//已读指令，已传数据地址，还没返回
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==8)//已读指令，读数据已返回
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        stallr=0;
        arvalid=0; 
    end
    else if(rstate==9)//不读指令，要读数据
    begin
        arid=0;
        araddr=inst_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==10)//都不读，直接取消暂停
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        stallr=0; 
        arvalid=0;
    end
    else if(rstate==11)//都不读
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==12)//已读指令，不读数据，就取消暂停
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        stallr=0; 
        arvalid=0;
    end
    else if(rstate==13)//初始没准备好
    begin
        arid=0;
        araddr=inst_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==14)
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        arvalid=0;
    end
    else if(rstate==16)
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        stallr=0;
        arvalid=0;
    end
    else//其他不可预知情况
    begin
        arid=1;
        araddr=data_sram_addr;
        arsize=4;
        stallr=0; 
        arvalid=0;
    end
end


always@(posedge clk)
begin
    if(~aresetn) 
    begin
        busy_r<=0;
        rok<=0;
        tok<=0;
        //arvalid<=0;
        rstate<=0;
    end
   else if(tok&&~bok)
    begin
        busy_r<=0;
        rok<=0;
        tok<=1;
        //arvalid<=0;
        rstate<=1;
    end
    else if(tok&&bok&&~stall_dv)
    begin
        busy_r<=0;
        rok<=0;
        tok<=0;
        //arvalid<=0;
        rstate<=2;
    end
    else if(tok&&bok&&stall_dv)
    begin
        busy_r<=0;
        rok<=0;
        tok<=1;
        //arvalid<=0;
        rstate<=16;
    end
    else if(va&&arready&&~busy_r&&~rok)//已准备好，还没读指令
    begin
        busy_r<=1;
        rok<=0;
        tok<=0;
        //arvalid<=1;
        rstate<=3;
    end
    else if(va&&busy_r&&~rok&&~rvalid)//已传指令地址，还没返回
    begin
        busy_r<=1;
        rok<=0;
        tok<=0;
        //arvalid<=0;
        rstate<=4;
    end
    else if(va&&rvalid&&~rok)//读指令返回
    begin
        busy_r<=0;
        rok<=1;
        tok<=0;
        //arvalid<=0;
        rstate<=5;
    end
    else if(va3_r&&arready&&~busy_r&&rok)//已准备好，已读指令，还没读数据
    begin
        busy_r<=1;
        rok<=1;
        tok<=0;
        //arvalid<=1;
        rstate<=6;
    end
    else if(va3_r&&busy_r&&rok&&~rvalid)//已读指令，已传数据地址，还没返回
    begin
        busy_r<=1;
        rok<=1;
        tok<=0;
        //arvalid<=0;
        rstate<=7;
    end
    else if(va3_r&&rvalid&&rok)//已读指令，读数据已返回
    begin
        busy_r<=0;
        rok<=0;
        tok<=1;
        //arvalid<=0;
        rstate<=8;
    end
    else if(~va&&va3_r&&~rok)//不读指令，要读数据
    begin
        busy_r<=0;        
        rok<=1; 
        tok<=0;
        //arvalid<=0; 
        rstate<=9;      
    end
    else if(~va&&~va3_r&&arready)//都不读，直接取消暂停
    begin
        busy_r<=0;
        rok<=0;
        tok<=1;
        //arvalid<=0;
        rstate<=10;
    end
    else if(~va&&~va3_r&&~arready)//都不读，直接取消暂停
    begin
        busy_r<=0;
        rok<=0;
        tok<=0;
        //arvalid<=0;
        rstate<=11;
    end
    else if(va&&~va3_r&&rok)//已读指令，不读数据，就取消暂停
    begin
        busy_r<=0;
        rok<=0;
        tok<=1;
        //arvalid<=0;
        rstate<=12;
    end
    else if(va&&~arready&&~busy_r&&~rok&&~rvalid)//初始没准备好
    begin
        busy_r<=0;
        rok<=0;
        tok<=0;
        //arvalid<=0;
        rstate<=13;
    end
    else if(va3_r&&~arready&&~busy_r&&rok&&~rvalid)
    begin
        busy_r<=0;
        rok<=0;
        tok<=0;
        //arvalid<=0;
        rstate<=14;
    end
    else//其他不可预知情况
    begin
        busy_r<=0;
        rok<=0;
        tok<=1;
        //arvalid<=0;
        rstate<=15;
    end
end

/*always@(posedge clk)
begin
    stallw=1;
    if(~resetn)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=1;
    end
   if(bok&&~tok)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(bok&&tok)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(va3_w&&awready&&~busy_w&&~wok)//已准备好，还没传地址
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=1;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
    end
    else if(va3_w&&busy_w&&~wready&&~wok)//正在传地址
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
    end
    else if(va3_w&&wready&&~wok)//地址已传完，开始传数据
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=1;
    end
    else if(va3_w&&wok&&~bvalid)//地址，数据已传完，还没响应
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
    end
    else if(va3_w&&wok&&bvalid)//地址传完，数据传完，已响应
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(~va3_w&&awready)//不读也不写
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(~va3_w&&~awready)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=1;
    end
    else
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
end*/

always@(posedge clk)
begin
    stallw=1;
    if(wstate==0)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=1;
    end
   if(wstate==1)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(wstate==2)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(wstate==3)//已准备好，还没传地址
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=1;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
    end
    else if(wstate==4)//正在传地址
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
    end
    else if(wstate==5)//地址已传完，开始传数据
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=1;
    end
    else if(wstate==6)//地址，数据已传完，还没响应
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
    end
    else if(wstate==7)//地址传完，数据传完，已响应
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(wstate==8)//不读也不写
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else if(wstate==9)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=1;
    end
    else if(wstate==11)
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
    else
    begin
        awaddr=data_sram_addr;
        awsize=4;
        awvalid=0;
        wdata=data_sram_wdata;
        wstrb=data_sram_wen;
        wvalid=0;
        stallw=0;
    end
end

always@(posedge clk)
begin
    if(~resetn)
    begin
        busy_w<=0;
        wok<=0;
        bok<=0;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=0;
    end
   else if(bok&&~tok)
    begin
        busy_w<=0;
        wok<=0;
        bok<=1;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=1;
    end
    else if(bok&&tok&&~stall_dv)
    begin
        busy_w<=0;
        wok<=0;
        bok<=0;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=2;
    end
    else if(bok&&tok&&stall_dv)
    begin
        busy_w<=0;
        wok<=0;
        bok<=1;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=11;
    end
    else if (va3_w&&awready&&~busy_w&&~wok)//已准备好，还没传地址
    begin
        busy_w<=1;
        wok<=0;
        bok<=0;
        //awvalid<=1;
        //wvalid<=0;
        wstate<=3;
    end
    else if(va3_w&&busy_w&&~wready&&~wok)//正在传地址
    begin
        busy_w<=1;
        wok<=0;
        bok<=0;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=4;
    end
    else if(va3_w&&wready&&~wok)//地址已传完，开始传数据
    begin
        busy_w<=0;
        wok<=1;
        bok<=0;
        //awvalid<=0;
        //wvalid<=1;
        wstate<=5;
    end
    else if(va3_w&&wok&&~bvalid)//地址，数据已传完，还没响应
    begin
        busy_w<=0;
        wok<=1;
        bok<=0;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=6;
    end
    else if(va3_w&&wok&&bvalid)//地址传完，数据传完，已响应
    begin
        busy_w<=0;
        wok<=0;
        bok<=1;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=7;
    end
    else if(~va3_w&&awready)//不读也不写
    begin
        busy_w<=0;
        wok<=0;
        bok<=1;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=8;
    end
    else if(~va3_w&&~awready)
    begin
        busy_w<=0;
        wok<=0;
        bok<=0;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=9;
    end
    else
    begin
        busy_w<=0;
        wok<=0;
        bok<=1;
        //awvalid<=0;
        //wvalid<=0;
        wstate<=10;
    end
end


always@(*)//取指
begin
    //if(delay_block||delay_hl||delay_hl1||delay_sendhl||stall) pause=1;
    if(delay_hl||delay_hl1||delay_sendhl||stall) pause=1;
    else pause=0;
    if(~resetn)begin  va=0; end
    else 
        begin     
            if(back) begin va=0;  end
            else if(exc) begin va=0;end
            else if(jump==1) begin va=0;end//若jump则无效
            else if(jump==2) begin va=0;  end
            else if(jump==3) begin va=0;  end
            else begin va=1;end            
        end
    
    if(~resetn)begin c_pc=7; end
    else 
        begin           
            inst_sram_addr=pc;
            if(pause) begin c_pc=0; end
            else if(back) begin  c_pc=6; end
            else if(exc) begin c_pc=5; end
            else if(jump==1) begin c_pc=2; end//若jump则无效
            else if(jump==2) begin c_pc=3; end
            else if(jump==3) begin c_pc=4; end
            else begin c_pc=1; end            
        end
end

//////////////////////////////////////////////////
////////////////////译码段组合逻辑/////////////////
//////////////////////////////////////////////////

////////PART ONE////////////
//基由op、funct等字段值生成指令码
wire [5:0]InsConvert_op;
wire [5:0]InsConvert_funct;
wire InsConvert_va1;
wire [5:0] InsConvert_rs;
wire [5:0] InsConvert_rt;
wire [5:0]InsConvert_inscode;

InsConvert InsConvert(.InsConvert_op(InsConvert_op),
                      .InsConvert_funct(InsConvert_funct),
                      .InsConvert_va1(InsConvert_va1),
                      .InsConvert_rs(InsConvert_rs),
                      .InsConvert_rt(InsConvert_rt),
                      .InsConvert_inscode(InsConvert_inscode));

assign InsConvert_op = op1;
assign InsConvert_funct = funct1;
assign InsConvert_va1 = va1;
assign InsConvert_rs = rs1;
assign InsConvert_rt = rt1;
assign inscode1 = InsConvert_inscode;

////////PART TWO////////////////
//生成其它乱七八糟的控制码
always@(*)//需用到rs,rt,addr   rd,shamt
begin    
    //if(delay_block||delay_hl||delay_hl1||delay_sendhl||stall) pause1=1;
    if(delay_hl||delay_hl1||delay_sendhl||stall) pause1=1;
    else pause1=0;
     
     if(pause1_1) ir1=ir1; else ir1=inst_sram_rdata;
     
     if(~resetn) va1=0;
    else if(pause1) va1=va1;
    else if(jump) va1=0;
    else if (back||exc) va1=0;
    else va1=r_va;   

    //保留指令部分
    if(~resetn) reins1=0;
    else if(exc||Status[1]) reins1=0;
    else if(va1 && InsConvert_inscode==0) reins1=1;
    else reins1=0;
    
    ra0=rs1;ra1=rt1;
end



always@(*)//执行...之后化繁为简，需用到inscode,shamt     rt,rd
begin
    div_begin=0;
    a1=a1_1;b1=b1_1;m1=m1_1;
    //if(delay_block||delay_hl||delay_hl1||delay_sendhl||stall) pause2=1;
    if(delay_hl||delay_hl1||delay_sendhl||stall) pause2=1;
    else pause2=0;
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
    if(va2==0) begin  aimaddr=0; a=a_1; b=b_1; m=0; end
    else if(inscode2==1) begin a=r_ar; b=r_br; m=0; aimaddr=rd02;  end
    else if(inscode2==2) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if(inscode2==3) begin a=r_ar; b=r_br; m=0; aimaddr=rd02; end
    else if(inscode2==4) begin a=r_ar; b=addr32; m=0; aimaddr=rt2;end
    else if(inscode2==5) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end
    else if(inscode2==6) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end
    else if(inscode2==7) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end
    else if(inscode2==8) begin a=r_ar; b=addr32; m=1; aimaddr=rt2; end
    else if(inscode2==9) begin a=r_ar; b=r_br; m=1; aimaddr=rd02; end
    else if(inscode2==10) begin a=r_ar; b=addr32; m=1; aimaddr=rt2; end
    else if(inscode2==11) begin 
                              a=0;b=0;m=0;if(r_stall) div_begin=0; else div_begin=1;
                              if(r_stall)
                              begin
                                a1=a1_1;
                                b1=b1_1;
                              end
                              else
                              begin
                                  a1=r_ar;
                                  b1=r_br;
                              end
                              aimaddr=0;
                              m1=11;
                          end//假设IP核是流水的
    else if(inscode2==12) begin 
                              a=0;b=0;m=0;if(r_stall) div_begin=0; else div_begin=1;
                              if(r_stall)
                              begin
                                a1=a1_1;
                                b1=b1_1;
                              end
                              else
                              begin
                                  a1=r_ar;
                                  b1=r_br;
                              end
                              aimaddr=0;m1=7;
                          end
    else if(inscode2==13) begin 
                              a=0;b=0;m=0;
                                  a1=r_ar;
                                  b1=r_br;
                              aimaddr=0;m1=5;
                          end
    else if(inscode2==14) begin 
                              a=0;b=0;m=0;
                                  a1=r_ar;
                                  b1=r_br;
                              aimaddr=0;m1=6;
                          end
    else if(inscode2==15) begin a=r_ar; b=r_br; m=2; aimaddr=rd02; end
    else if(inscode2==16) begin a=r_ar; b=addr0; m=2; aimaddr=rt2; end
    else if(inscode2==17) begin a=0; b=addr_0; m=0; aimaddr=rt2; end
    else if(inscode2==18) begin a=r_ar; b=r_br; m=3; aimaddr=rd02; end
    else if(inscode2==19) begin a=r_ar; b=r_br; m=3; aimaddr=rd02; end
    else if(inscode2==20) begin a=r_ar; b=addr0; m=3; aimaddr=rt2; end
    else if(inscode2==21) begin a=r_ar; b=r_br; m=4; aimaddr=rd02; end
    else if(inscode2==22) begin a=r_ar; b=addr0; m=4; aimaddr=rt2; end
    else if(inscode2==23) begin a=shamt32; b=r_br; m=8; aimaddr=rd02; end
    else if(inscode2==24) begin a={{26{zero}},r_ar[4:0]}; b=r_br; m=8; aimaddr=rd02; end
    else if(inscode2==25) begin a=shamt32; b=r_br; m=10; aimaddr=rd02; end
    else if(inscode2==26) begin a={{26{zero}},r_ar[4:0]}; b=r_br; m=10; aimaddr=rd02; end
    else if(inscode2==27) begin a=shamt32; b=r_br; m=9; aimaddr=rd02; end
    else if(inscode2==28) begin a={{26{zero}},r_ar[4:0]}; b=r_br; m=9; aimaddr=rd02; end
    else if(inscode2==29) begin a=r_ar; b=r_br; m=1; aimaddr=0; end
    else if(inscode2==30) begin a=r_ar; b=r_br; m=1; aimaddr=0; end
    else if((inscode2==47)||(inscode2==48)) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if((inscode2==49)||(inscode2==50)) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if(inscode2==51) begin a=r_ar; b=addr32; m=0; aimaddr=rt2; end
    else if((inscode2==52)||(inscode2==53)||(inscode2==54)) begin a=r_ar; b=addr32; m=0; aimaddr=0; end
    else if((inscode2==35)||(inscode2==36)||(inscode2==38)) begin aimaddr=31; a=a_1;b=b_1;m=0; end
    else if((inscode2==40)||(inscode2==41)||(inscode2==42)) begin aimaddr=rd02;a=a_1;b=b_1;m=0; end
    else if(inscode2==56) begin aimaddr=rt2;a=a_1;b=b_1;m=0; end
    else if(inscode2==57) begin a=0; b=r_br; m=0; aimaddr=0; sel=funct2[2:0]; cp0_num=rd02; cp0_data=y;end
    else begin aimaddr=0; a=a_1;b=b_1;m=0; end
end

always@(*)//存储器访问...之后化繁为简，需用到inscode       rt,rd     此处实现跳转。。。。。前三位归零，原因何在？？？？？
begin
    //delay_block=0;
    delay_sendhl=0;
    if(delay_hl||delay_hl1||stall) pause3=1;
    else pause3=0;
    if(pause3) begin c_inscode3=0; c_ir3=0; end 
    else begin c_inscode3=1; c_ir3=1; end
    if (rs3==0) r_a1r=0;
    else if(rs3==aimaddr2) r_a1r=aimdata2;
    else if(rs3==aimaddr3) r_a1r=aimdata3;
    else if(rs3==aimaddr4) r_a1r=aimdata4;
    else r_a1r=r_a1;   
    if (rt3==0) r_b1r=0;
    else if(rt3==aimaddr2) r_b1r=aimdata2;
    else if(rt3==aimaddr3) r_b1r=aimdata3;
    else if(rt3==aimaddr4) r_b1r=aimdata4;
    else r_b1r=r_b1;
    if(va3==0) begin jump=0; data_sram_wen=0; end
    else if(inscode3==29) begin if(zf1==1) jump=1; else jump=0; data_sram_wen=0; end
    else if(inscode3==30) begin if(zf1==0) jump=1; else jump=0; data_sram_wen=0; end
    else if(inscode3==31) begin if(r_a1r[31]==0) jump=1; else jump=0; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==32) begin if((r_a1r[31]==0)&&(r_a1r!=0)) jump=1; else jump=0; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==33) begin if((r_a1r[31]==1)||(r_a1r==0)) jump=1; else jump=0; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==34) begin if(r_a1r[31]==1) jump=1; else jump=0; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==35) begin if(r_a1r[31]==1) jump=1; else jump=0; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==36) begin if(r_a1r[31]==0) jump=1; else jump=0; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==37) begin jump=2; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==38) begin jump=2; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==39) begin jump=3; data_sram_wen=0; end//默认rs为有符号数
    else if(inscode3==40) begin jump=3; data_sram_wen=0; end//默认rs为有符号数
    else if((inscode3==47)||(inscode3==48)) 
        begin jump=0; data_sram_addr1=r_y; data_sram_wen=0;
            //if(va2&&((rs2==aimaddr1)||(rt2==aimaddr1))) delay_block=1;
            //else delay_block=0;
        end
    else if((inscode3==49)||(inscode3==50)) 
        begin jump=0; data_sram_wen=0; data_sram_addr1=r_y;
           // if(va2&&(((rs2==aimaddr1)||(rt2==aimaddr1))&&(~r_y[0]))) delay_block=1;
           // else delay_block=0; 
        end
    else if(inscode3==51) 
        begin 
            jump=0; data_sram_wen=0; data_sram_addr1=r_y;
           // if(va2&&(((rs2==aimaddr1)||(rt2==aimaddr1))&&(~r_y[1:0]))) delay_block=1;
               // else delay_block=0; 
        end
    else if(inscode3==52) begin jump=0; data_sram_addr1=r_y;//写字节与数据就是位置对应关系。。。。。。。。。。。
                                case(r_y[1:0])
                                    0:begin data_sram_wen=4'b0001;data_sram_wdata[7:0]=r_b1r[7:0]; end //已进行小尾端处理
                                    1:begin data_sram_wen=4'b0010;data_sram_wdata[15:8]=r_b1r[7:0]; end//已进行小尾端处理
                                    2:begin data_sram_wen=4'b0100;data_sram_wdata[23:16]=r_b1r[7:0]; end//已进行小尾端处理。
                                    3:begin data_sram_wen=4'b1000;data_sram_wdata[31:24]=r_b1r[7:0]; end//已进行小尾端处理
                                    default: begin data_sram_wen=0; data_sram_wdata=0; end
                                endcase
                          end
    else if(inscode3==53) begin jump=0; data_sram_addr1=r_y;
                                case(r_y[1:0])
                                    0:begin data_sram_wen=4'b0011;data_sram_wdata[15:0]=r_b1r[15:0]; end//已进行小尾端处理
                                    2:begin data_sram_wen=4'b1100;data_sram_wdata[31:16]=r_b1r[15:0]; end//已进行小尾端处理
                                default:data_sram_wen=4'b0000;//已进行小尾端处理
                                endcase
                          end
    else if(inscode3==54) begin jump=0; data_sram_addr1=r_y; if(r_y[1:0]==0) data_sram_wen=4'b1111; else data_sram_wen=0; data_sram_wdata=r_b1r; end
    else if(inscode3==7) begin jump=0; data_sram_wen=0; end
    else if(inscode3==8) begin jump=0; data_sram_wen=0; end
    else if(inscode3==9) begin jump=0; data_sram_wen=0; end
    else if(inscode3==10) begin jump=0; data_sram_wen=0; end
    else if(inscode3==41) begin 
                              jump=0; data_sram_wen=0;
                              if(va2&&((rs2==aimaddr1)||(rt2==aimaddr1)))
                              begin
                                  if(va4&&((inscode4==11)||(inscode4==12)||(inscode4==13)||(inscode4==14)||(inscode4==43)||(inscode4==44))) delay_sendhl=1;
                                  else if(va5&&((inscode5==11)||(inscode5==12)||(inscode5==13)||(inscode5==14)||(inscode5==43)||(inscode5==44))) delay_sendhl=1;
                                  else if(va6&&((inscode6==11)||(inscode6==12)||(inscode6==13)||(inscode6==14)||(inscode6==43)||(inscode6==44))) delay_sendhl=1;
                                  else delay_sendhl=0;
                              end
                              else delay_sendhl=0;
                          end
    else if(inscode3==42) begin 
                              jump=0; data_sram_wen=0;
                              if(va2&&((rs2==aimaddr1)||(rt2==aimaddr1)))
                              begin
                                  if(va4&&((inscode4==11)||(inscode4==12)||(inscode4==13)||(inscode4==14)||(inscode4==43)||(inscode4==44))) delay_sendhl=1;
                                  else if(va5&&((inscode5==11)||(inscode5==12)||(inscode5==13)||(inscode5==14)||(inscode5==43)||(inscode5==44))) delay_sendhl=1;
                                  else if(va6&&((inscode6==11)||(inscode6==12)||(inscode6==13)||(inscode6==14)||(inscode6==43)||(inscode6==44))) delay_sendhl=1;
                                  else delay_sendhl=0;
                              end
                              else delay_sendhl=0; 
                          end
    else if(inscode3==56) begin jump=0; data_sram_wen=0; end
    else if(inscode3==57) 
        begin
            jump=0; 
            data_sram_wen=0;
        end
    else if(inscode3==18) begin jump=0; data_sram_wen=0; end
    else begin jump=0; data_sram_wen=0; end
    
    if(pause3) begin jump=0; end  

end


//该部分用到的输入数据是r_y1,ir4,r_pc_8,HI,LO
always@(*)//寄存器写回...之后化繁为简，需用到inscode,rt,rd
begin
    delay_hl=0;
    delay_hl1=0;

    if(stall) pause4=1;
    else pause4=0;
    
    if(rs4==0) r_a2r=0;
    else if(rs4==aimaddr3) r_a2r=aimdata3;
    else if(rs4==aimaddr4) r_a2r=aimdata4;
    else if(rs4==aimaddr5) r_a2r=aimdata5;
    else r_a2r=r_a2; 
    
    if(rt4==0) r_b2r=0;  
    else if(rt4==aimaddr3) r_b2r=aimdata3;
    else if(rt4==aimaddr4) r_b2r=aimdata4;
    else if(rt4==aimaddr5) r_b2r=aimdata5;
    else r_b2r=r_b2;
    
    if(pause4||delay_hl||delay_hl1||stall) c_inscode4=0; else  c_inscode4=1;
    
    if(va4==0) begin we=0; wa=r_wa; wd=r_wd; end
    else if(pause4) begin we=0; wa=r_wa; wd=r_wd; end
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
    else if(inscode4==35) begin we=1; wa=31; wd=r_pc_8; end
    else if(inscode4==36) begin we=1; wa=31; wd=r_pc_8; end
    else if(inscode4==38) begin we=1; wa=31; wd=r_pc_8; end
    else if(inscode4==40) begin we=1; wa=rd04; wd=r_pc_8; end
    else if(inscode4==41) begin
                              wa=rd04; wd=HI; 
                              if(va5&&((inscode5==11)||(inscode5==12)||(inscode5==13)||(inscode5==14)||(inscode5==43)||(inscode5==44))) begin delay_hl=1; c_inscode4=0; we=0; end
                              else if(va6&&((inscode6==11)||(inscode6==12)||(inscode6==13)||(inscode6==14)||(inscode6==43)||(inscode6==44))) begin delay_hl1=1;c_inscode4=0; we=0; end
                              else begin we=1; end
                          end
    else if(inscode4==42) begin 
                              wa=rd04; wd=LO; 
                              if(va5&&((inscode5==11)||(inscode5==12)||(inscode5==13)||(inscode5==14)||(inscode5==43)||(inscode5==44))) begin delay_hl=1;c_inscode4=0; we=0; end
                              else if(va6&&((inscode6==11)||(inscode6==12)||(inscode6==13)||(inscode6==14)||(inscode6==43)||(inscode6==44))) begin delay_hl1=1;c_inscode4=0; we=0; end
                              else begin we=1;  end
                          end
    else if((inscode4==47)||(inscode4==48)) 
        begin 
            we=1; wa=rt4; 
            case(r_y1[1:0])//已进行小尾端处理
                0:bvalue=data_sram_rdata1[7:0];
                1:bvalue=data_sram_rdata1[15:8];
                2:bvalue=data_sram_rdata1[23:16];
                3:bvalue=data_sram_rdata1[31:24];
                default:bvalue=0;
            endcase
            if(inscode4==47) wd={{24{bvalue[7]}},bvalue};
            else wd={{24{zero}},bvalue};
        end
    else if((inscode4==49)||(inscode4==50)) 
        begin //CP0判断处理。。。。。。。。。。。。。。。。。。。。。。。。。
            if (pd) we=1; else we=0; wa=rt4; 
            case(r_y1[1:0])//已进行小尾端处理
                0:b2value=data_sram_rdata1[15:0];
                2:b2value=data_sram_rdata1[31:16];
                default:b2value=0;
            endcase
            if (inscode4==49) wd={{16{b2value[15]}},b2value}; 
            else wd={{16{zero}},b2value};
        end
    else if(inscode4==51) begin if (pd1) we=1; else we=0; wa=rt4; wd=data_sram_rdata1; end
    else if(inscode4==56) begin we=1; wa=rt4; wd=aimdata2;end
    else begin we=0;wa=r_wa; wd=r_wd;end
end

always @(*)//HI,LO在这里写回
begin
    if(va7==0) begin HI=r_HI;LO=r_LO; end
    else if(inscode7==43) begin HI=r_a5r; LO=r_LO; end
    else if(inscode7==44) begin LO=r_a5r; HI=r_HI; end
    else if((inscode7==11)||(inscode7==12)||(inscode7==13)||(inscode7==14)) begin HI=hi; LO=lo; end
    else begin HI=r_HI; LO=r_LO; end
end

always@(posedge clk)//防锁存器电路
begin
    r_HI<=HI;
    r_LO<=LO;
    a1_1<=a1;
    b1_1<=b1;
    a_1<=a;
    b_1<=b;
    m1_1<=m1;
end

endmodule
