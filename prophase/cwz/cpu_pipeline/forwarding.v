`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 16:34:26
// Design Name: 
// Module Name: forwarding
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


module forwarding(
input [4:0] ID_EX_rs, ID_EX_rt,
input EX_MEM_regwrite, MEM_WB_regwrite,
input [4:0] EX_MEM_WA, MEM_WB_WA,
output reg [1:0]forward_A, forward_B
    );
always @(*)
begin
    if(EX_MEM_regwrite && ID_EX_rs == EX_MEM_WA && EX_MEM_WA != 0)
        forward_A = 2'b01;
    else if(MEM_WB_regwrite && ID_EX_rs == MEM_WB_WA && MEM_WB_WA != 0)
        forward_A = 2'b10;
    else
        forward_A = 2'b00;
        
    if(EX_MEM_regwrite && ID_EX_rt == EX_MEM_WA && EX_MEM_WA != 0)
        forward_B = 2'b01;
    else if(MEM_WB_regwrite && ID_EX_rt == MEM_WB_WA && MEM_WB_WA != 0)
        forward_B = 2'b10;
    else
        forward_B = 2'b00;
end


endmodule
