`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/14 18:39:02
// Design Name: 
// Module Name: pipeline_cpu
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

//,sel,m_rf_addr,rf_data,m_data,status
module pipeline_cpu(clk,rst,run);
    input clk,rst,run;
   // input [2:0]sel;
   // input [15:0]m_rf_addr;
   // output [31:0]rf_data,m_data;
   // output [47:0]status;
    //-----------------元件信号部分--------------------
    //PC寄存器部分
    wire [31:0] PC_curr,PC_next;
    wire PC_we;
    Register_32 PC(.clk(clk),.rst(rst),.en(PC_we),.d(PC_next),.q(PC_curr));
    //指令存储器部分
    wire [7:0] Ins_addr;
    wire [31:0]Ins;
    Ins_rom Ins_rom(.a(Ins_addr>>2),.spo(Ins));
    //寄存器堆部分
    wire [4:0]Rf_ra0,Rf_ra1,Rf_wa;
    wire [31:0]Rf_wd;
    wire Rf_we;
    wire [31:0]Rf_rd0,Rf_rd1;
    Registerfile Registerfile(.ra0(Rf_ra0),.ra1(Rf_ra1),
                              .wa(Rf_wa),.wd(Rf_wd),.we(Rf_we),
                              .rd0(Rf_rd0),.rd1(Rf_rd1),
                              .clk(clk));
//                              .ra_debug(m_rf_addr),
//                              .rd_debug(rf_data));
    //ALU部分
    wire [31:0]ALU_a,ALU_b;
    wire [3:0]ALU_Ctl_in;
    wire [31:0]ALU_out;
    wire ALU_zf;
    ALU ALU(.ALUctl(ALU_Ctl_in),.A(ALU_a),.B(ALU_b),.ALUOut(ALU_out),.Zero(ALU_zf));
    //数据存储器部分
    wire [7:0]Data_addr;
    wire [31:0]Data_w;
    wire Data_we;
    wire [31:0]Data_out;
    Data_ram Data_ram(.a(Data_addr >> 2),.d(Data_w),.we(Data_we),.spo(Data_out),.clk(clk));
    //,.dpra(m_rf_addr),.dpo(m_data)
    //控制器部分
    wire [5:0]op;
    wire RegDst,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,push;
    wire [1:0]PCSource,ALUOp;
    CPU_control CPU_control(.clk(clk),.rst(rst),.run(run),.op(op),
                            .RegDst(RegDst),.MemRead(MemRead),.MemtoReg(MemtoReg),.MemWrite(MemWrite),.ALUSrc(ALUSrc),.RegWrite(RegWrite),
                            .PCSource(PCSource),.ALUOp(ALUOp),.push(push));
    //ALU_control
    wire [3:0]ALU_Ctl_out;
    wire [5:0]FuncCode;
    wire [1:0]ALUOp_in;
    ALUControl ALUControl(.ALUOp(ALUOp_in),.FuncCode(FuncCode),.ALUCtl(ALU_Ctl_out));
    
    //ALU_outcome
    wire [31:0]ALU_income;
    wire [31:0]ALU_outcome;
    wire [1:0]ALU_oppend;
    wire [5:0]ALU_funct;
    wire [4:0]ALU_sa;
    wire [31:0]ALU_LO,ALU_HI;
    ALU_come ALU_come(.ALU_income(ALU_income),.ALU_outcome(ALU_outcome),.ALU_oppend(ALU_oppend),.ALU_funct(ALU_funct),.ALU_sa(ALU_sa),.ALU_LO(ALU_LO),.ALU_HI(ALU_HI));
    
    //LO&HI
    wire [31:0]LO_reg_in,LO_reg_out;
    wire [31:0]HI_reg_in,HI_reg_out;
    wire LO_reg_we,HI_reg_we;
    Register_32 LO_reg(.clk(clk),.rst(rst),.en(LO_reg_we),.d(LO_reg_in),.q(LO_reg_out));
    Register_32 HI_reg(.clk(clk),.rst(rst),.en(HI_reg_we),.d(HI_reg_in),.q(HI_reg_out));
    
    //MDC
    wire [31:0]MDC_A,MDC_B;
    wire [5:0]MDC_funct;
    wire [1:0]MDC_oppend;
    wire [31:0]MDC_LO,MDC_HI;
    wire MDC_HI_we,MDC_LO_we;
    MDC MDC(.MDC_A(MDC_A),.MDC_B(MDC_B),.MDC_funct(MDC_funct),.MDC_oppend(MDC_oppend),.MDC_LO(MDC_LO),.MDC_HI(MDC_HI),.MDC_HI_we(MDC_HI_we),.MDC_LO_we(MDC_LO_we));
    
    //---------------------中间寄存器信号部分-------------------
    //IF/ID
    wire [31:0]IF_ID_Ins_reg_in;
    wire [31:0]IF_ID_Ins_reg_out;
    wire [31:0]IF_ID_PC4_reg_in;
    wire [31:0]IF_ID_PC4_reg_out;
    wire IF_ID_reg_we;
    Register_32 IF_ID_Ins_reg(.clk(clk),.rst(rst),.en(IF_ID_reg_we),.d(IF_ID_Ins_reg_in),.q(IF_ID_Ins_reg_out));
    Register_32 IF_ID_PC4_reg(.clk(clk),.rst(rst),.en(IF_ID_reg_we),.d(IF_ID_PC4_reg_in),.q(IF_ID_PC4_reg_out));
    
    //ID/EX
    wire [31:0]ID_EX_A_reg_in;
    wire [31:0]ID_EX_A_reg_out;
    wire [31:0]ID_EX_B_reg_in;
    wire [31:0]ID_EX_B_reg_out;
    wire [31:0]ID_EX_Ins_reg_in;
    wire [31:0]ID_EX_Ins_reg_out;
    wire [31:0]ID_EX_reg_we;
    Register_32 ID_EX_A_reg(.clk(clk),.rst(rst),.en(ID_EX_reg_we),.d(ID_EX_A_reg_in),.q(ID_EX_A_reg_out));
    Register_32 ID_EX_B_reg(.clk(clk),.rst(rst),.en(ID_EX_reg_we),.d(ID_EX_B_reg_in),.q(ID_EX_B_reg_out));
    Register_32 ID_EX_Ins_reg(.clk(clk),.rst(rst),.en(ID_EX_reg_we),.d(ID_EX_Ins_reg_in),.q(ID_EX_Ins_reg_out));
    
    //EX/MEM
    wire [31:0]EX_MEM_ALU_reg_in;
    wire [31:0]EX_MEM_ALU_reg_out;
    wire [31:0]EX_MEM_B_reg_in;
    wire [31:0]EX_MEM_B_reg_out;
    wire [31:0]EX_MEM_Ins_reg_in;
    wire [31:0]EX_MEM_Ins_reg_out;
    wire [31:0]EX_MEM_reg_we;
    Register_32 EX_MEM_ALU_reg(.clk(clk),.rst(rst),.en(EX_MEM_reg_we),.d(EX_MEM_ALU_reg_in),.q(EX_MEM_ALU_reg_out));
    Register_32 EX_MEM_B_reg(.clk(clk),.rst(rst),.en(EX_MEM_reg_we),.d(EX_MEM_B_reg_in),.q(EX_MEM_B_reg_out));
    Register_32 EX_MEM_Ins_reg(.clk(clk),.rst(rst),.en(EX_MEM_reg_we),.d(EX_MEM_Ins_reg_in),.q(EX_MEM_Ins_reg_out));
    
    //MEM/WB
    wire [31:0]MEM_WB_data_reg_in;
    wire [31:0]MEM_WB_data_reg_out;
    wire [31:0]MEM_WB_Ins_reg_in;
    wire [31:0]MEM_WB_Ins_reg_out;
    wire [31:0]MEM_WB_reg_we;
    Register_32 MEM_WB_data_reg(.clk(clk),.rst(rst),.en(MEM_WB_reg_we),.d(MEM_WB_data_reg_in),.q(MEM_WB_data_reg_out));
    Register_32 MEM_WB_Ins_reg(.clk(clk),.rst(rst),.en(MEM_WB_reg_we),.d(MEM_WB_Ins_reg_in),.q(MEM_WB_Ins_reg_out));
    
     //-------------------信号通路部分---------------------------
    //指令寄存器输入
    assign Ins_addr = PC_curr;
    //IF/ID
    assign IF_ID_Ins_reg_in = Ins;
    assign IF_ID_PC4_reg_in = PC_curr + 4;
    assign IF_ID_reg_we = push;
    //寄存器堆输入
    assign Rf_ra0 = IF_ID_Ins_reg_out[25:21];
    assign Rf_ra1 = IF_ID_Ins_reg_out[20:16];
    assign Rf_wa = RegDst ? MEM_WB_Ins_reg_out[20:16] : MEM_WB_Ins_reg_out[15:11];
    assign Rf_wd = MEM_WB_data_reg_out;
    assign Rf_we = RegWrite;
    //ID/EX
    assign ID_EX_A_reg_in = Rf_rd0;
    assign ID_EX_B_reg_in = Rf_rd1;
    assign ID_EX_Ins_reg_in = IF_ID_Ins_reg_out;
    assign ID_EX_reg_we = 1;
    //ALU输入,ctl已给出
    assign ALU_a = ID_EX_A_reg_out;
    assign ALU_b = ALUSrc ? {ID_EX_Ins_reg_out[15]*16'hffff,ID_EX_Ins_reg_out[15:0]} : ID_EX_B_reg_out; 
    assign ALU_Ctl_in = ALU_Ctl_out;
    //MDC
    assign MDC_A = ID_EX_A_reg_out;
    assign MDC_B = ID_EX_B_reg_out;
    assign MDC_funct = ID_EX_Ins_reg_out[5:0];
    assign MDC_oppend = ALUOp;
    //LO&HI
    assign LO_reg_we = MDC_LO_we;
    assign LO_reg_in = MDC_LO;
    assign HI_reg_we = MDC_HI_we;
    assign HI_reg_in = MDC_HI;
    //ALU二阶
    assign ALU_income = ALU_out;
    assign ALU_oppend = ALUOp;
    assign ALU_funct = ID_EX_Ins_reg_out[5:0];
    assign ALU_sa = ID_EX_Ins_reg_out[10:6];
    assign ALU_LO = LO_reg_out;
    assign ALU_HI = HI_reg_out;
    //EX/MEM
    assign EX_MEM_ALU_reg_in = ALU_outcome;
    assign EX_MEM_Ins_reg_in = ID_EX_Ins_reg_out;
    assign EX_MEM_B_reg_in = ID_EX_B_reg_out;
    assign EX_MEM_reg_we = 1;
    //数据存储器输入
    assign Data_addr = EX_MEM_ALU_reg_in;
    assign Data_w = EX_MEM_B_reg_out;
    assign Data_we = MemWrite;
    //MEM/WB
    assign MEM_WB_data_reg_in = MemtoReg ? Data_out : EX_MEM_ALU_reg_out;
    assign MEM_WB_Ins_reg_in =  EX_MEM_Ins_reg_out;
    assign MEM_WB_reg_we = 1;
    //PC输入
    assign PC_we = 1;
    assign PC_next = PC_curr + 4;
    //CPU控制
    assign op = Ins[31:26];
    //ALUcontrol
    assign ALUOp_in = ALUOp;
    assign FuncCode = (ALUOp == 2'b11)? ID_EX_Ins_reg_out[31:26] : ID_EX_Ins_reg_out[5:0];
    
    /*
    //--------------------------------调试工具--------------------------------------
    wire [15:0]status1;
    wire [31:0]status2;
    assign status1 = {PCSource,PC_we,IorD,MemWrite,IRWrite,DegDst,MemtoReg,RegWrite,ALU_Ctl_in[2:0],ALUSrcA,ALUSrcB,ALU_zf};
    assign status2 = sel[2] ? (sel[1] ? (sel[0] ? (Data_out):
                                                  (ALUOut_out)):
                                        (sel[0] ? (B_out):
                                                  (A_out))):
                              (sel[1] ? (sel[0] ? (MDr_out):
                                                  (Ins_reg_out)):
                                        (PC_next          ));
    assign status = {status1,status2};
*/
                             
endmodule
