`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/13 21:08:07
// Design Name: 
// Module Name: ALUC
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


module ALUC(ins,op,out,dm,dmh,dml,v,blzlf,mh,ml);
input [5:0] ins;
input [3:0] op;
output reg [3:0] out;
output reg dm,v,blzlf,mh,ml,dmh,dml;

always @ *
begin
  out=0;dm=0;v=0;blzlf=0;mh=0;ml=0;dmh=0;dml=0;
  if(op==4'b1111)
     case(ins)
       6'b100000:out=4'b0000;
       6'b100001:out=4'b1000;
       6'b100010:out=4'b0001;
       6'b100011:out=4'b1001;
       6'b101010:out=4'b1010;
       6'b101011:out=4'b1011;
       6'b011010:begin dm=1;out=4'b0001; end
       6'b011011:begin dm=1;out=4'b1001; end
       6'b011000:begin dm=1;out=4'b0000; end
       6'b011001:begin dm=1;out=4'b1000; end
       6'b100100:out=4'b0010;
       6'b100111:out=4'b0101;
       6'b100101:out=4'b0011;
       6'b100110:out=4'b0100;
       6'b000000:begin v=1;out=4'b0110; end
       6'b000100:out=4'b0110;
       6'b000111:out=4'b0111;
       6'b000011:begin v=1;out=4'b0111; end
       6'b001101:out=4'b1101;
       6'b001100:out=4'b1100;
       6'b001000:out=0;
       6'b001001:out=0;
       6'b010000:begin out=0;mh=1; end
       6'b010010:begin out=0;ml=1; end
       6'b010001:begin out=0;dmh=1; end
       6'b010011:begin out=0;dml=1; end
       default:begin out=0;blzlf=1;end
     endcase
   else out=op;
end

endmodule
