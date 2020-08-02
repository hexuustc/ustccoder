`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 17:06:57
// Design Name: 
// Module Name: hazard_unit
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


module hazard_unit(
    input [4:0]ID_EX_rt,
    input ID_EX_memread,
    input [4:0]IF_ID_rs, IF_ID_rt,
    output reg PC_retain, IF_ID_retain, ID_EX_flush
    );

always @(*)
begin
    if(ID_EX_memread && (ID_EX_rt != 0) && (ID_EX_rt == IF_ID_rs || ID_EX_rt == IF_ID_rt))
    begin
        PC_retain = 1; IF_ID_retain = 1; ID_EX_flush = 1;
    end
    else
    begin
        PC_retain = 0; IF_ID_retain = 0; ID_EX_flush = 0;
    end
end

endmodule
