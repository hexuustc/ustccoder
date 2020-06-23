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
input clk, rst
    );

reg [WIDTH-1:0] PC;
reg [WIDTH-1:0] IF_ID_NPC, IF_ID_IR;
reg [WIDTH-1:0] ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_IMM, ID_EX_IR, ID_EX_JUMP_ADDR;
reg ID_EX_alusrc, ID_EX_regdst, ID_EX_memwrite, ID_EX_branch, ID_EX_memtoreg, ID_EX_regwrite, ID_EX_jump, ID_EX_memread;
reg [2:0] ID_EX_aluop;
reg [WIDTH-1:0] EX_MEM_Y, EX_MEM_B;
reg [4:0] EX_MEM_WA;
reg EX_MEM_memwrite, EX_MEM_memtoreg, EX_MEM_regwrite, EX_MEM_memread;
reg [WIDTH-1:0] MEM_WB_MDR, MEM_WB_Y;
reg [4:0] MEM_WB_WA;
reg MEM_WB_memtoreg, MEM_WB_regwrite;

wire [WIDTH-1:0]instruction, pc_plus_4, data_to_write, extend_imm, data_a, data_b, imm_left_2;
wire [WIDTH-1:0]write_address, alu_input_1, branch_addr, alu_result, read_data, next_pc, jump_address, temp_addr_0;
wire [WIDTH-1:0]forwarded_A, forwarded_B;
wire regdst,branch, memtoreg, regwrite, memwrite, alusrc, zero, jump, memread, branch_success;
wire [2:0]aluop;
wire [2:0]alu_manage;
wire [1:0]forward_A, forward_B;
wire PC_retain, IF_ID_retain, ID_EX_flush, IF_ID_flush, ID_EX_blocked;

assign jump_address[31:28] = IF_ID_NPC[31:28];
assign branch_success = zero & ID_EX_branch;
assign IF_ID_flush = branch_success | ID_EX_jump;
assign ID_EX_flush = IF_ID_flush | ID_EX_blocked;

always @(posedge clk, posedge rst)
begin
    if(rst)
    begin
        PC <= 0;
    
        IF_ID_NPC <= 0;
        IF_ID_IR <= (1 << 26);
        
        ID_EX_NPC <= 0;
        ID_EX_A <= 0;
        ID_EX_B <= 0;
        ID_EX_IMM <= 0;
        ID_EX_IR <= (1 << 26);
        ID_EX_alusrc <= 0;
        ID_EX_regdst <= 0;
        ID_EX_regwrite <= 0;
        ID_EX_memwrite <= 0;
        ID_EX_memtoreg <= 0;
        ID_EX_branch <= 0;
        ID_EX_aluop <= 3'b111;
        ID_EX_jump <= 0;
        ID_EX_JUMP_ADDR <= 0;
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
    else
    begin
        PC <= (PC_retain)?PC:next_pc;
        
        if(IF_ID_flush)
        begin
            IF_ID_NPC <= 0;
            IF_ID_IR <= (1 << 26);
        end
        else if(IF_ID_retain)
        begin
            IF_ID_NPC <= IF_ID_NPC;
            IF_ID_IR <= IF_ID_IR;
        end
        else
        begin
            IF_ID_NPC <= pc_plus_4;
            IF_ID_IR <= instruction;
        end
        
        if(ID_EX_flush)
        begin
            ID_EX_NPC <= 0;
            ID_EX_A <= 0;
            ID_EX_B <= 0;
            ID_EX_IMM <= 0;
            ID_EX_IR <= (1 << 26);
            ID_EX_alusrc <= 0;
            ID_EX_regdst <= 0;
            ID_EX_regwrite <= 0;
            ID_EX_memwrite <= 0;
            ID_EX_memtoreg <= 0;
            ID_EX_branch <= 0;
            ID_EX_aluop <= 3'b111;
            ID_EX_jump <= 0;
            ID_EX_JUMP_ADDR <= 0;
            ID_EX_memread <= 0;
        end
        else
        begin
            ID_EX_NPC <= IF_ID_NPC;
            ID_EX_A <= data_a;
            ID_EX_B <= data_b;
            ID_EX_IMM <= extend_imm;
            ID_EX_IR <= IF_ID_IR;
            ID_EX_alusrc <= alusrc;
            ID_EX_regdst <= regdst;
            ID_EX_regwrite <= regwrite;
            ID_EX_memwrite <= memwrite;
            ID_EX_memtoreg <= memtoreg;
            ID_EX_branch <= branch;
            ID_EX_aluop <= aluop;
            ID_EX_jump <= jump;
            ID_EX_JUMP_ADDR <= jump_address;
            ID_EX_memread <= memread;
        end
        
        EX_MEM_Y <= alu_result;
        EX_MEM_B <= forwarded_B;
        EX_MEM_WA <= write_address;
        EX_MEM_memwrite <= ID_EX_memwrite;
        EX_MEM_memtoreg <= ID_EX_memtoreg;
        EX_MEM_regwrite <= ID_EX_regwrite;
        EX_MEM_memread <= ID_EX_memread;
        
        MEM_WB_MDR <= read_data;
        MEM_WB_Y <= EX_MEM_Y;
        MEM_WB_WA <= EX_MEM_WA;
        MEM_WB_memtoreg <= EX_MEM_memtoreg;
        MEM_WB_regwrite <= EX_MEM_regwrite;
    end
end

instruction_rom ins_0(
.a(PC[9:2]),
.spo(instruction)
);

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
.in(ID_EX_IMM),
.out(imm_left_2)
);

mux #(5) regdst_mux(
.in_0(ID_EX_IR[20:16]),
.in_1(ID_EX_IR[15:11]),
.choose(ID_EX_regdst),
.out(write_address)
);

mux #(32) alusrc_mux(
.in_0(forwarded_B),
.in_1(ID_EX_IMM),
.choose(ID_EX_alusrc),
.out(alu_input_1)
);

adder adder_0(
.in_0(ID_EX_NPC),
.in_1(imm_left_2),
.out(branch_addr)
);

alu_control alu_ctrl(
.funct(ID_EX_IR[5:0]),
.aluop(ID_EX_aluop),
.alu_control(alu_manage)
);

ALU alu(
.a(forwarded_A),
.b(alu_input_1),
.y(alu_result),
.m(alu_manage),
.zf(zero)
);

data_ram data_0(
.a(EX_MEM_Y[9:2]),
.d(EX_MEM_B),
.clk(clk),
.we(EX_MEM_memwrite),
.spo(read_data)
);

mux #(32) memtoreg_mux(
.in_0(MEM_WB_Y),
.in_1(MEM_WB_MDR),
.choose(MEM_WB_memtoreg),
.out(data_to_write)
);

mux #(32) branch_mux(
.in_0(pc_plus_4),
.in_1(branch_addr),
.choose(ID_EX_branch),
.out(temp_addr_0)
);

mux #(32) jump_mux(
.in_0(temp_addr_0),
.in_1(ID_EX_JUMP_ADDR),
.choose(ID_EX_jump),
.out(next_pc)
);

shifter_1 shi_1(
.in(IF_ID_IR[25:0]),
.out(jump_address[27:0])
);

forwarding for_0(
.ID_EX_rs(ID_EX_IR[25:21]),
.ID_EX_rt(ID_EX_IR[20:16]),
.EX_MEM_regwrite(EX_MEM_regwrite),
.MEM_WB_regwrite(MEM_WB_regwrite),
.EX_MEM_WA(EX_MEM_WA),
.MEM_WB_WA(MEM_WB_WA),
.forward_A(forward_A),
.forward_B(forward_B)
);

mux_3 mux_3_A(
.in_0(ID_EX_A),
.in_1(EX_MEM_Y),
.in_2(data_to_write),
.choose(forward_A),
.out(forwarded_A)
);

mux_3 mux_3_B(
.in_0(ID_EX_B),
.in_1(EX_MEM_Y),
.in_2(data_to_write),
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
