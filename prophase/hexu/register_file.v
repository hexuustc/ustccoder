`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 15:40:42
// Design Name: 
// Module Name: register_file
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


module register_file
    #(parameter WIDTH = 32)
    (input clk,
    input [4:0] ra0,
    output [WIDTH-1:0] rd0,
    input [4:0] ra1,
    output [WIDTH-1:0] rd1,
    input [4:0] wa,
    input we,
    input [WIDTH-1:0] wd,
    input rst
    );
    
reg [WIDTH-1:0] r[0:31];
integer i;

initial
    for (i=0;i<=31;i=i+1)
        r[i]=0;
        
always@(posedge clk, posedge rst)
begin
    if(rst)
        for (i=0;i<=31;i=i+1)
            r[i]<=0;
    else
        if(we&&wa>0)
            r[wa]<=wd;
end
assign rd0=r[ra0];
assign rd1=r[ra1];
endmodule
