module PC(clk,rst,in,out);
input clk,rst;
input [31:0] in;
output reg [31:0] out;

always @ (posedge clk or posedge rst)
if(rst) out<=32'b0;
else out<=in;

endmodule