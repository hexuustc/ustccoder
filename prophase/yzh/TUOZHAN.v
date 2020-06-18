module tuozhan(in,out);
input [15:0] in;
output [31:0] out;

assign out[15:0]=in;
assign out[31:16]=in[15]?16'hffff:16'h0000;

endmodule