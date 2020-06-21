`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/30 17:09:28
// Design Name: 
// Module Name: ALU
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

/*module ALU
#(parameter WIDTH = 32) 	//数据宽度
(output [WIDTH-1:0] y, 		//运算结果
output zf, 					//零标志
output cf, 					//进位/借位标志
output of, 					//溢出标志
input [WIDTH-1:0] a, b,		//两操作数
input [2:0]m				//操作类型
);

	assign {cf,y}=m[2]?(m[0]?(a^b):(~a)) : 
				(m[1]?(m[0]?(a|b):(a&b)):(m[0]?(a-b):(a+b)));
	assign zf=~|y;
	assign of=a[3]^b[3]^y[3]^cf;
endmodule*/

module ALU
#(parameter WIDTH = 32) 	//数据宽度
(ALUctl,A,B,ALUOut,Zero);
    input [3:0]ALUctl;
    input [31:0]A,B;
    output reg [31:0] ALUOut;
    output Zero;
    assign Zero = (ALUOut == 0) ;
    always @(*)
    begin
        case(ALUctl)
            0: ALUOut = A & B;
            1: ALUOut = A | B;
            2: ALUOut = A + B;
            3: ALUOut = A ^ B;
            4: ALUOut = B << A;
            5: ALUOut = B >> A;
            6: ALUOut = A - B;
            7: ALUOut = A < B ? 1: 0;
            8: ALUOut = (A+32'h10000000) < (B+32'h10000000) ? 1 : 0;
            9: ALUOut = ((B[31] * 32'hffffffff) & (~(32'hffffffff >> A))) | (B >> A);
            10: ALUOut = {B[15:0],16'h0000};
            12: ALUOut = ~(A | B);
            default: ALUOut = 0;
        endcase
    end
endmodule