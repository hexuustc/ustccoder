`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/29 03:21:06
// Design Name: 
// Module Name: AimDataGen
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


module AimDataGen( inscode ,
                   zf      ,
                   cf      ,
                   of      ,
                   y       ,
                   funct   ,
                   rd      ,
                   pc      ,
                   HI      ,
                   LO      ,
                   cp0_ra  ,
                   cp0_load,
                   aimdata );
    
    input wire [5:0] inscode;
    input wire zf,cf,of;
    input wire [31:0] y;
    input wire [5:0] funct;
    input wire [5:0] rd;

    input wire [31:0] pc;
    input wire [31:0] HI;
    input wire [31:0] LO;
    input wire [31:0] cp0_load;
    output reg cp0_ra;
    output reg [31:0] aimdata;

    always@(*)
begin
    case(inscode)
        35: aimdata=pc-4;
        36: aimdata=pc-4;
        38: aimdata=pc-4;
        40: aimdata=pc-4;
        7:  if((~of&y[31]&~zf)|(of&~y[31]&~zf))aimdata=1;else aimdata=0;
        8:  if((~of&y[31]&~zf)|(of&~y[31]&~zf))aimdata=1;else aimdata=0;
        9:  if(cf&~zf) aimdata=1;else aimdata=0;
        10: if(cf&~zf) aimdata=1;else aimdata=0;
        41: aimdata=HI;
        42: aimdata=LO;
        56: if(funct[2:0]==0)
            begin
                cp0_ra = rd;
                aimdata = cp0_load;
            end
            else aimdata=0;
        18: aimdata=~y;
        default: aimdata=y;
    endcase
end
endmodule
