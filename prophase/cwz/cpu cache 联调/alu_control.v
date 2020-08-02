// Engineer: 
// 
// Create Date: 2020/05/10 22:48:24
// Design Name: 
// Module Name: alu_control
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


module alu_control(
input [5:0]funct, 
input [2:0]aluop,
output reg[2:0]alu_control
    );

always @(*)
begin
    if(aluop == 3'b110)
        if(funct == 6'b100000)
            alu_control = 3'b000;
        else
            alu_control = 3'b111;
    else
        alu_control = aluop;
end

endmodule
