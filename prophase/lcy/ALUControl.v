`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/15 13:10:25
// Design Name: 
// Module Name: ALUControl
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


module ALUControl(ALUOp,FuncCode,ALUCtl);
    input [1:0] ALUOp;
    input [5:0] FuncCode;
    output  reg [3:0]ALUCtl;
    
    always @(*)
    begin
        case(ALUOp)
            2'b00: ALUCtl = 4'b0010;
            2'b01: ALUCtl = 4'b0110;
            2'b10: case(FuncCode)
                    6'b000000: ALUCtl = 4'b0010;
                    6'b000010: ALUCtl = 4'b0010;
                    6'b000011: ALUCtl = 4'b0010;
                    6'b000100: ALUCtl = 4'b0100;
                    6'b000110: ALUCtl = 4'b0101;
                    6'b000111: ALUCtl = 4'b1001;
                    6'b100000: ALUCtl = 4'b0010;
                    6'b100001: ALUCtl = 4'b0010;
                    6'b100010: ALUCtl = 4'b0110;
                    6'b100011: ALUCtl = 4'b0110;
                    6'b100100: ALUCtl = 4'b0000;
                    6'b100101: ALUCtl = 4'b0001;
                    6'b100110: ALUCtl = 4'b0011;
                    6'b100111: ALUCtl = 4'b1100;
                    6'b101010: ALUCtl = 4'b1000;
                    6'b101011: ALUCtl = 4'b0111;
                    default: ALUCtl = 4'b1111;
                endcase
            2'b11:case(FuncCode)
                    6'b001000: ALUCtl = 4'b0010;
                    6'b001001: ALUCtl = 4'b0010;
                    6'b001010: ALUCtl = 4'b1000;
                    6'b001011: ALUCtl = 4'b0111;
                    6'b001100: ALUCtl = 4'b0000;
                    6'b001101: ALUCtl = 4'b0001;
                    6'b001110: ALUCtl = 4'b0011;
                    6'b001111: ALUCtl = 4'b1010;
                    default: ALUCtl = 4'b1111;
                endcase
            default: ALUCtl = 4'b1111;
        endcase
    end
endmodule
