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
input [4:0] IF_ID_rs, IF_ID_rt,
input EX_MEM_memread,
input EX_MEM_regwrite, ID_EX_regwrite,
input [4:0] EX_MEM_WA, ID_EX_WA,
output reg [1:0]forward_A, forward_B
    );
always @(*)
begin
    if(ID_EX_regwrite && IF_ID_rs == ID_EX_WA && ID_EX_WA != 0)
        forward_A = 2'b10;
    else if(EX_MEM_regwrite && IF_ID_rs == EX_MEM_WA && EX_MEM_WA != 0)
        forward_A = EX_MEM_memread ? 2'b11 : 2'b01;
    else
        forward_A = 2'b00;
    
    if(ID_EX_regwrite && IF_ID_rt == ID_EX_WA && ID_EX_WA != 0)
        forward_B = 2'b10;  
    else if(EX_MEM_regwrite && IF_ID_rt == EX_MEM_WA && EX_MEM_WA != 0)
        forward_B = EX_MEM_memread ? 2'b11 : 2'b01;
    else
        forward_B = 2'b00;
end


endmodule
