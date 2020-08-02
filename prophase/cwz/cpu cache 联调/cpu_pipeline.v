`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/16 09:08:24
// Design Name: 
// Module Name: cpu_pipeline
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


module cpu_pipeline
#(parameter WIDTH = 32)(
    input clk, 
    input rst,
    
    output             i_req,
    output             i_wreq,
    output [WIDTH-1:0] i_write_data,
    input  [WIDTH-1:0] i_read_data,
    output [WIDTH-1:0] i_addr,
    output [3      :0] i_wbyte,
    input              i_ok,
    
    output             d_req,
    output             d_wreq,
    output [WIDTH-1:0] d_write_data,
    input  [WIDTH-1:0] d_read_data,
    output [WIDTH-1:0] d_addr,
    output [3      :0] d_wbyte,
    input              d_ok,
    
    output             led
);

reg [WIDTH-1:0] PC;
reg [WIDTH-1:0] IF_ID_NPC, IF_ID_IR;
reg [WIDTH-1:0] ID_EX_A, ID_EX_B, ID_EX_IMM;
reg [5:0] ID_EX_funct;
reg [4:0] ID_EX_rd, ID_EX_rt;
reg ID_EX_alusrc, ID_EX_regdst, ID_EX_memwrite, ID_EX_memtoreg, ID_EX_regwrite, ID_EX_memread;
reg [2:0] ID_EX_aluop;
reg [WIDTH-1:0] EX_MEM_Y, EX_MEM_B;
reg [4:0] EX_MEM_WA;
reg EX_MEM_memwrite, EX_MEM_memtoreg, EX_MEM_regwrite, EX_MEM_memread;
reg [WIDTH-1:0] MEM_WB_MDR, MEM_WB_Y;
reg [4:0] MEM_WB_WA;
reg MEM_WB_memtoreg, MEM_WB_regwrite;

wire [WIDTH-1:0]pc_plus_4, data_to_write, extend_imm, data_a, data_b, imm_left_2;
wire [WIDTH-1:0]alu_input_1, branch_addr, alu_result, next_pc, jump_address, temp_addr_0;
wire [WIDTH-1:0]forwarded_A, forwarded_B;
wire regdst,branch, memtoreg, regwrite, memwrite, alusrc, zero, jump, memread, branch_success;
wire [2:0]aluop;
wire [2:0]alu_manage;
wire [1:0]forward_A, forward_B;
wire PC_retain, IF_ID_retain, ID_EX_flush, ID_EX_blocked;
wire [4:0]write_address;

assign i_req = ~PC_retain;
assign i_wreq = 0;
assign i_write_data = 0;
assign i_addr = PC;
assign i_wbyte = 4'h0;

assign d_req = EX_MEM_memread | EX_MEM_memwrite;
assign d_wreq = EX_MEM_memwrite;
assign d_write_data = EX_MEM_B;
assign d_addr = EX_MEM_Y;
assign d_wbyte = 4'hf;

assign jump_address[31:28] = IF_ID_NPC[31:28];
assign branch_success = zero & branch;
//assign IF_ID_flush = branch_success | jump; ¼ÓÑÓ³Ù²ÛÁË
assign ID_EX_flush = ID_EX_blocked;
assign zero = (forwarded_A == forwarded_B);

assign led = (PC >= 32'h8c);

always @(posedge clk, posedge rst)
begin
    if(rst)
    begin
        PC <= 44;
    
        IF_ID_NPC <= 0;
        IF_ID_IR <= 0;
        
        ID_EX_A <= 0;
        ID_EX_B <= 0;
        ID_EX_funct <= 0;
        ID_EX_rd <= 0;
        ID_EX_rt <= 0;
        ID_EX_IMM <= 0;
        ID_EX_alusrc <= 0;
        ID_EX_regdst <= 0;
        ID_EX_regwrite <= 0;
        ID_EX_memwrite <= 0;
        ID_EX_memtoreg <= 0;
        ID_EX_aluop <= 3'b111;
        ID_EX_memread <= 0;
        
        EX_MEM_Y <= 0;
        EX_MEM_B <= 0;
        EX_MEM_WA <= 0;
        EX_MEM_memwrite <= 0;
        EX_MEM_memtoreg <= 0;
        EX_MEM_regwrite <= 0;
        EX_MEM_memread <= 0;
        
        MEM_WB_MDR <= 0;
        MEM_WB_Y <= 0;
        MEM_WB_WA <= 0;
        MEM_WB_memtoreg <= 0;
        MEM_WB_regwrite <= 0;
    end
    else if((d_req & ~d_ok))
        PC <= branch_success | jump ? next_pc : PC;
    else
    begin
        PC <= branch_success | jump ? next_pc :
            PC_retain | ~i_ok ? PC : next_pc;
        
        if(IF_ID_retain)
        begin
            IF_ID_NPC <= IF_ID_NPC;
            IF_ID_IR <= IF_ID_IR;
        end
        else
        begin
            IF_ID_NPC <= pc_plus_4;
            IF_ID_IR <= ~i_ok ? 32'h0 : i_read_data;
        end
        
        if(ID_EX_flush)
        begin
            ID_EX_IMM <= 0;
            ID_EX_A <= 0;
            ID_EX_B <= 0;
            ID_EX_funct <= 0;
            ID_EX_rt <= 0;
            ID_EX_rd <= 0;
            ID_EX_alusrc <= 0;
            ID_EX_regdst <= 0;
            ID_EX_regwrite <= 0;
            ID_EX_memwrite <= 0;
            ID_EX_memtoreg <= 0;
            ID_EX_aluop <= 3'b111;
            ID_EX_memread <= 0;
        end
        else
        begin
            ID_EX_A <= forwarded_A;
            ID_EX_B <= forwarded_B;
            ID_EX_funct <= IF_ID_IR[6:0];
            ID_EX_rd <= IF_ID_IR[20:16];
            ID_EX_rt <= IF_ID_IR[15:11];
            ID_EX_IMM <= extend_imm;
            ID_EX_alusrc <= alusrc;
            ID_EX_regdst <= regdst;
            ID_EX_regwrite <= regwrite;
            ID_EX_memwrite <= memwrite;
            ID_EX_memtoreg <= memtoreg;
            ID_EX_aluop <= aluop;
            ID_EX_memread <= memread;
        end
        
        EX_MEM_Y <= alu_result;
        EX_MEM_B <= ID_EX_B;
        EX_MEM_WA <= write_address;
        EX_MEM_memwrite <= ID_EX_memwrite;
        EX_MEM_memtoreg <= ID_EX_memtoreg;
        EX_MEM_regwrite <= ID_EX_regwrite;
        EX_MEM_memread <= ID_EX_memread;
        
        MEM_WB_MDR <= d_read_data;
        MEM_WB_Y <= EX_MEM_Y;
        MEM_WB_WA <= EX_MEM_WA;
        MEM_WB_memtoreg <= EX_MEM_memtoreg;
        MEM_WB_regwrite <= EX_MEM_regwrite;
    end
end

four_adder four_0(
.in(PC[31:0]),
.out(pc_plus_4)
);

register_file reg_file(
.clk(clk),
.ra0(IF_ID_IR[25:21]),
.rd0(data_a),
.ra1(IF_ID_IR[20:16]),
.rd1(data_b),
.wa(MEM_WB_WA),
.we(MEM_WB_regwrite),
.wd(data_to_write)
);

sign_extender sign_0(
.in(IF_ID_IR[15:0]),
.out(extend_imm)
);

control con_0(
.op(IF_ID_IR[31:26]),
.regdst(regdst),
.jump(jump),
.branch(branch),
.memtoreg(memtoreg),
.memread(memread),
.memwrite(memwrite),
.alusrc(alusrc),
.regwrite(regwrite),
.aluop(aluop)
);

shifter_0 shi_0(
.in(extend_imm),
.out(imm_left_2)
);

mux #(5) regdst_mux(
.in_0(ID_EX_rd),
.in_1(ID_EX_rt),
.choose(ID_EX_regdst),
.out(write_address)
);

mux #(32) alusrc_mux(
.in_0(ID_EX_B),
.in_1(ID_EX_IMM),
.choose(ID_EX_alusrc),
.out(alu_input_1)
);

adder adder_0(
.in_0(IF_ID_NPC),
.in_1(imm_left_2),
.out(branch_addr)
);

alu_control alu_ctrl(
.funct(ID_EX_funct),
.aluop(ID_EX_aluop),
.alu_control(alu_manage)
);

ALU alu_0(
.a(ID_EX_A),
.b(alu_input_1),
.y(alu_result),
.m(alu_manage)
);

mux #(32) memtoreg_mux(
.in_0(MEM_WB_Y),
.in_1(MEM_WB_MDR),
.choose(MEM_WB_memtoreg),
.out(data_to_write)
);

mux #(32) branch_mux(
.in_0(temp_addr_0),
.in_1(branch_addr),
.choose(branch),
.out(next_pc)
);

mux #(32) jump_mux(
.in_0(pc_plus_4),
.in_1(jump_address),
.choose(jump),
.out(temp_addr_0)
);

shifter_1 shi_1(
.in(IF_ID_IR[25:0]),
.out(jump_address[27:0])
);

forwarding for_0(
.IF_ID_rs(IF_ID_IR[25:21]),
.IF_ID_rt(IF_ID_IR[20:16]),
.EX_MEM_memread(EX_MEM_memread),
.EX_MEM_regwrite(EX_MEM_regwrite),
.ID_EX_regwrite(ID_EX_regwrite),
.EX_MEM_WA(EX_MEM_WA),
.ID_EX_WA(write_address),
.forward_A(forward_A),
.forward_B(forward_B)
);

mux_4 mux_4_A(
.in_0(data_a),
.in_1(EX_MEM_Y),
.in_2(alu_result),
.in_3(d_read_data),
.choose(forward_A),
.out(forwarded_A)
);

mux_4 mux_4_B(
.in_0(data_b),
.in_1(EX_MEM_Y),
.in_2(alu_result),
.in_3(d_read_data),
.choose(forward_B),
.out(forwarded_B)
);

hazard_unit haz_0(
.ID_EX_rt(write_address),
.ID_EX_memread(ID_EX_memread),
.IF_ID_rs(IF_ID_IR[25:21]),
.IF_ID_rt(IF_ID_IR[20:16]),
.PC_retain(PC_retain),
.IF_ID_retain(IF_ID_retain),
.ID_EX_flush(ID_EX_blocked)
);

endmodule
