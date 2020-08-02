`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/10 23:09:58
// Design Name: 
// Module Name: control
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


module control(
input [5:0]op,
output reg regdst, jump,
output reg branch, memread,
output reg memtoreg, memwrite,
output reg alusrc, regwrite,
output reg [2:0]aluop
    );


always @(*)
begin
    case (op)
        6'b000000:          //add
        begin
            regdst = 1; jump = 0;
            branch = 0; memread = 0;
            memtoreg = 0; memwrite = 0;
            alusrc = 0; regwrite = 1;
            aluop = 3'b110;         //determined by funct
        end
        6'b001000:          //addi
        begin
            regdst = 0; jump = 0;
            branch = 0; memread = 0;
            memtoreg = 0; memwrite = 0;
            alusrc = 1; regwrite = 1;
            aluop = 3'b000;
        end
        6'b100011:          //lw
        begin
            regdst = 0; jump = 0;
            branch = 0; memread = 1;
            memtoreg = 1; memwrite = 0;
            alusrc = 1; regwrite = 1;
            aluop = 3'b000;
        end
        6'b101011:          //sw
        begin
            regdst = 0; jump = 0;
            branch = 0; memread = 0;
            memtoreg = 0; memwrite = 1;
            alusrc = 1; regwrite = 0;
            aluop = 3'b000;
        end
        6'b000100:          //beq
        begin
            regdst = 1; jump = 0;
            branch = 1; memread = 0;
            memtoreg = 0; memwrite = 0;
            alusrc = 0; regwrite = 0;
            aluop = 3'b001;
        end
        6'b000010:          //j
        begin
            regdst = 0; jump = 1;
            branch = 0; memread = 0;
            memtoreg = 0; memwrite = 0;
            alusrc = 0; regwrite = 0;
            aluop = 3'b111;             // alu do nothing
        end
        default:            //nop
        begin
            regdst = 0; jump = 0;
            branch = 0; memread = 0;
            memtoreg = 0; memwrite = 0;
            alusrc = 0; regwrite = 0;
            aluop = 3'b111;
        end
    endcase
end

endmodule
