`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/14 18:55:11
// Design Name: 
// Module Name: CT1
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


module CT1(
input [5:0]insop,funct,
input [4:0] bc,mc,
output reg memtoreg,j,jr,alr,tzx,regwrite,blzlop,alusrc,regdst,ert,memwrite,mtr,mtw,lui,bgl,
output reg [2:0] zhx,lsc,
output reg [3:0] op
    );
always @ * 
begin
  {memtoreg,j,jr,alr,tzx,regwrite,blzlop,alusrc,regdst,ert,memwrite,mtr,mtw,lui,bgl,zhx,lsc,op}=0;
  case(insop)
    6'b000000:begin op=4'b1111;regwrite=1;regdst=1; 
                    if(funct==6'b001000||funct==6'b001001) begin jr=1;regwrite=funct[0]; end
              end
    6'b001000:begin op=4'b0000;alusrc=1;regwrite=1; end
    6'b001001:begin op=4'b1000;alusrc=1;regwrite=1; end
    6'b001010:begin op=4'b1010;alusrc=1;regwrite=1; end
    6'b001011:begin op=4'b1011;alusrc=1;regwrite=1; end
    6'b001100:begin op=4'b0010;alusrc=1;regwrite=1;tzx=1; end
    6'b001111:begin op=4'b0110;lui=1;alusrc=1;regwrite=1;tzx=1; end
    6'b001101:begin op=4'b0011;alusrc=1;regwrite=1;tzx=1; end
    6'b001110:begin op=4'b0100;alusrc=1;regwrite=1;tzx=1; end
    6'b000100:begin op=4'b0001;zhx=3'b001; end
    6'b000101:begin op=4'b0001;zhx=3'b010; end
    6'b000001:begin op=4'b1010;zhx=bc[0]?3'b100:3'b011;bgl=1;alr=bc[4]; end
    6'b000111:begin op=4'b1110;zhx=3'b011;bgl=1; end
    6'b000110:begin op=4'b1110;zhx=3'b100;bgl=1; end
    6'b000010:j=1;
    6'b000011:begin j=1;alr=1; end
    6'b100000:begin op=4'b0000;lsc=3'b000;memtoreg=1;alusrc=1;regwrite=1; end
    6'b100100:begin op=4'b0000;lsc=3'b001;memtoreg=1;alusrc=1;regwrite=1; end
    6'b100001:begin op=4'b0000;lsc=3'b010;memtoreg=1;alusrc=1;regwrite=1; end
    6'b100101:begin op=4'b0000;lsc=3'b011;memtoreg=1;alusrc=1;regwrite=1; end
    6'b100011:begin op=4'b0000;lsc=3'b100;memtoreg=1;alusrc=1;regwrite=1; end
    6'b101000:begin op=4'b0000;lsc=3'b101;alusrc=1;memwrite=1;end
    6'b101001:begin op=4'b0000;lsc=3'b110;alusrc=1;memwrite=1;end
    6'b101011:begin op=4'b0000;lsc=3'b111;alusrc=1;memwrite=1;end
    6'b010000:begin if(mc[4]) ert=1;
                    else if(mc==5'b00100) mtw=1;
                    else if(mc==5'b00000) begin mtr=1;regwrite=1; end
                    else blzlop=1;
              end
    default:blzlop=1;
  endcase
end
endmodule
