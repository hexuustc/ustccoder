`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/20 02:59:03
// Design Name: 
// Module Name: ALU_come
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


module ALU_come(ALU_income,ALU_outcome,ALU_oppend,ALU_funct,ALU_sa,ALU_HI,ALU_LO);
    input [31:0]ALU_income;
    input [1:0]ALU_oppend;
    input [5:0]ALU_funct;
    input [4:0]ALU_sa;
    input [31:0]ALU_HI,ALU_LO;
    output reg [31:0]ALU_outcome;
    
    always @(*)
    begin
        if(ALU_oppend == 2'b10)
        begin
            case(ALU_funct[5:2])
                4'b0000:
                begin
                    case(ALU_funct[1:0])
                        2'b00: ALU_outcome = ALU_income << ALU_sa;
                        2'b10: ALU_outcome = ALU_income >> ALU_sa;
                        2'b11: ALU_outcome = ((ALU_income[31] * 32'hffffffff) & (~(32'hffffffff >> ALU_sa))) | (ALU_income >> ALU_sa);
                        default: ALU_outcome = ALU_income;
                    endcase
                end
                4'b0100:
                begin
                    case(ALU_funct[1:0])
                        2'b00: ALU_outcome = ALU_HI;
                        2'b10: ALU_outcome = ALU_LO;
                        default: ALU_outcome = ALU_income;
                    endcase
                end
                default: ALU_outcome = ALU_income;
            endcase
        end
        else ALU_outcome = ALU_income;
    end
endmodule
