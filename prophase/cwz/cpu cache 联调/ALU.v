`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/23 20:38:17
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


module ALU
#(parameter WIDTH = 32) 	//���ݿ��
(output reg [WIDTH-1:0] y, 		//������
output reg zf, 					//���־
output reg cf, 					//��λ/��λ��־
output reg of, 					//�����־
output reg sf,                  //���ű�־
input [WIDTH-1:0]a, b,		     //��������
input [2:0]m				    //��������
);

always@(*)
begin
    case(m)
        3'b000: 
        begin 
            {cf, y} = a + b;
            of = (~a[WIDTH - 1] & ~b[WIDTH - 1] & y[WIDTH - 1]) | (a[WIDTH - 1] & b[WIDTH - 1] & ~y[WIDTH - 1]);
        end
        3'b001: 
        begin
            {cf, y} = a - b;
            of = (~a[WIDTH - 1] & b[WIDTH - 1] & y[WIDTH - 1]) | (a[WIDTH - 1] & ~b[WIDTH - 1] & ~y[WIDTH - 1]);
        end
        3'b010: 
        begin
            y = a & b;
            of = 0;
            cf = 0;
        end
        3'b011: 
        begin
            y = a | b;
            of = 0;
            cf = 0;
        end
        3'b100: 
        begin
            y = a ^ b;
            of = 0;
            cf = 0;
        end
        default: 
        begin
            y = 0;
            of = 0;
            cf = 0;
        end
    endcase
    zf = ~|y;
    sf = y[WIDTH-1];
end

endmodule
