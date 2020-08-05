`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/28 16:19:40
// Design Name: 
// Module Name: InsConvert
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


module InsConvert(InsConvert_op,InsConvert_funct,InsConvert_va1,InsConvert_rs,InsConvert_rt,InsConvert_inscode);
    input [5:0] InsConvert_op;
    input [5:0] InsConvert_funct;
    input [5:0] InsConvert_rs;
    input [5:0] InsConvert_rt;
    input InsConvert_va1;
    output reg [5:0] InsConvert_inscode;
always @(*)
begin
    if (InsConvert_op==6'b000000) //指令码生成，此处省略不必要的零值，增加新指令或伪指令会冲突
    begin//InsConvert_inscode==0表示空指令//运算指令
        if(InsConvert_funct==6'b100000) InsConvert_inscode=1;//ADD
        else if(InsConvert_funct==6'b100001) InsConvert_inscode=3;//ADDU
        else if(InsConvert_funct==6'b100010) InsConvert_inscode=5;//SUB
        else if(InsConvert_funct==6'b100011) InsConvert_inscode=6;//SUBU
        else if(InsConvert_funct==6'b101010) InsConvert_inscode=7;//SLT
        else if(InsConvert_funct==6'b101011) InsConvert_inscode=9;//SLTU
        else if(InsConvert_funct==6'b011010) InsConvert_inscode=11;//DIV
        else if(InsConvert_funct==6'b011011) InsConvert_inscode=12;//DIVU
        else if(InsConvert_funct==6'b011000) InsConvert_inscode=13;//MULT
        else if(InsConvert_funct==6'b011001) InsConvert_inscode=14;//MULTU
        else if(InsConvert_funct==6'b100100) InsConvert_inscode=15;//AND
        else if(InsConvert_funct==6'b100111) InsConvert_inscode=18;//NOR
        else if(InsConvert_funct==6'b100101) InsConvert_inscode=19;//OR
        else if(InsConvert_funct==6'b100110) InsConvert_inscode=21;//XOR
        else if(InsConvert_funct==6'b000000) InsConvert_inscode=23;//SLL
        else if(InsConvert_funct==6'b000100) InsConvert_inscode=24;//SLLV
        else if(InsConvert_funct==6'b000011) InsConvert_inscode=25;//SRA
        else if(InsConvert_funct==6'b000111) InsConvert_inscode=26;//SRAV
        else if(InsConvert_funct==6'b000010) InsConvert_inscode=27;//SRL
        else if(InsConvert_funct==6'b000110) InsConvert_inscode=28;//SRLV
        else if(InsConvert_funct==6'b001000) InsConvert_inscode=39;//JR
        else if(InsConvert_funct==6'b001001) InsConvert_inscode=40;//JALR
        else if(InsConvert_funct==6'b010000) InsConvert_inscode=41;//MFHI
        else if(InsConvert_funct==6'b010010) InsConvert_inscode=42;//MFLO
        else if(InsConvert_funct==6'b010001) InsConvert_inscode=43;//MTHI
        else if(InsConvert_funct==6'b010011) InsConvert_inscode=44;//MTLO
        else if(InsConvert_funct==6'b001101) InsConvert_inscode=45;//BREAK
        else if(InsConvert_funct==6'b001100) InsConvert_inscode=46;//SYSCALL
        else InsConvert_inscode=0;
    end
    //立即数运算
    else if(InsConvert_op==6'b001000) InsConvert_inscode=2;//ADDI
    else if(InsConvert_op==6'b001001) InsConvert_inscode=4;//ADDIU等同于li
    else if(InsConvert_op==6'b001010) InsConvert_inscode=8;//SLTI
    else if(InsConvert_op==6'b001011) InsConvert_inscode=10;//SLTIU
    else if(InsConvert_op==6'b001100) InsConvert_inscode=16;//ANDI
    else if(InsConvert_op==6'b001111) InsConvert_inscode=17;//LUI
    else if(InsConvert_op==6'b001101) InsConvert_inscode=20;//ORI
    else if(InsConvert_op==6'b001110) InsConvert_inscode=22;//XORI
            
    else if(InsConvert_op==6'b000100) InsConvert_inscode=29;//BEQ
    else if(InsConvert_op==6'b000101) InsConvert_inscode=30;//BNE
    else if(InsConvert_op==6'b000001)
    begin
        if(InsConvert_rt==5'b00001) InsConvert_inscode=31;//BGEZ
        else if(InsConvert_rt==5'b00000) InsConvert_inscode=34;//BLTZ
        else if(InsConvert_rt==5'b10001) InsConvert_inscode=36;//BGEZAL
        else if(InsConvert_rt==5'b10000) InsConvert_inscode=35;//BLTZAL
        else InsConvert_inscode = 0;
    end
    else if(InsConvert_op==6'b000111) InsConvert_inscode=32;//BGTZ
    else if(InsConvert_op==6'b000110) InsConvert_inscode=33;//BLEZ
    else if(InsConvert_op==6'b000010) InsConvert_inscode=37;//J
    else if(InsConvert_op==6'b000011) InsConvert_inscode=38;//JAL
    else if(InsConvert_op==6'b100000) InsConvert_inscode=47;//LB
    else if(InsConvert_op==6'b100100) InsConvert_inscode=48;//LBU
    else if(InsConvert_op==6'b100001) InsConvert_inscode=49;//LH
    else if(InsConvert_op==6'b100101) InsConvert_inscode=50;//LHU
    else if(InsConvert_op==6'b100011) InsConvert_inscode=51;//LW
    else if(InsConvert_op==6'b101000) InsConvert_inscode=52;//SB
    else if(InsConvert_op==6'b101001) InsConvert_inscode=53;//SH
    else if(InsConvert_op==6'b101011) InsConvert_inscode=54;//SW
    else if(InsConvert_op==6'b010000)
    begin
        if((InsConvert_rs==5'b10000)&&(InsConvert_funct==6'b011000)) InsConvert_inscode=55;//ERET
        else if(InsConvert_rs==5'b00000) InsConvert_inscode=56;//MFC
        else if(InsConvert_rs==5'b00100) InsConvert_inscode=57;//MTC
        else InsConvert_inscode = 0;
    end
    else if(InsConvert_va1) InsConvert_inscode=0;
    else InsConvert_inscode=0;
end
endmodule
