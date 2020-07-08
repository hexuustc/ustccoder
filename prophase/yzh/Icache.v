`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/07 16:21:26
// Design Name: 
// Module Name: Icache
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


module Icache(
input clk,
input rst,
input [31:0] insaddr,
output reg [31:0] ins,
input req,
output miss,
output reg stall,
output reg read_req,
input ok,
output reg [31:0] addr,
input [31:0] data
    );
reg [31:0] cachedata [3:0][255:0];
reg [21:0] biaoji    [3:0][255:0];
reg [255:0] youxiao  [3:0];
reg [1:0]  lru       [3:0][255:0];
wire [7:0] suoyin;
wire [21:0] bj;
reg  [1:0]  max,lux;
reg  [1:0]  s,ns;
wire mz0,mz1,mz2,mz3;
reg man;
assign bj    = insaddr[31:10];
assign suoyin= insaddr[9:2];
assign mz0   = youxiao[0][suoyin] & (bj == biaoji[0][suoyin]);
assign mz1   = youxiao[1][suoyin] & (bj == biaoji[1][suoyin]);
assign mz2   = youxiao[2][suoyin] & (bj == biaoji[2][suoyin]);
assign mz3   = youxiao[3][suoyin] & (bj == biaoji[3][suoyin]);
assign miss  = ~(mz0|mz1|mz2|mz3);
always @ (*)
begin
  if(rst) 
  begin
    youxiao [0] = 256'b0;
    youxiao [1] = 256'b0;
    youxiao [2] = 256'b0;
    youxiao [3] = 256'b0;
    man=0;
    lux=0;
    max=0;
  end
  else
  begin
    if(mz0)      lux=2'b00;
    else if(mz1) lux=2'b01;
    else if(mz2) lux=2'b10;
    else if(mz3) lux=2'b11;
    else
    begin
      if(~youxiao[0][suoyin])      lux=2'b00;
      else if(~youxiao[1][suoyin]) lux=2'b01;
      else if(~youxiao[2][suoyin]) lux=2'b10;
      else if(~youxiao[3][suoyin]) lux=2'b11;
      else
      begin
        man=1;max=lru[0][suoyin];lux=2'b00;
        if(lru[1][suoyin]>max)
        begin
          max=lru[1][suoyin];lux=2'b01;
        end
        if(lru[2][suoyin]>max)
        begin
          max=lru[2][suoyin];lux=2'b10;
        end
        if(lru[3][suoyin]>max)
        begin
          max=lru[3][suoyin];lux=2'b11;
        end
      end
    end
  end
end

always @ (posedge clk)
begin
  if(rst) s<=2'b00;
  else    s<=ns;
end

always @ *
begin
  case(s)
  2'b00:begin
        if(req)  ns=2'b01;
        else ns=2'b00;
        end
  2'b01:begin
        if(miss)  ns=2'b10;
        else     ns=2'b00;
        end
  2'b10:begin
        if(ok) ns=2'b01;
        else   ns=2'b11;
        end
  2'b11:begin
        if(ok) ns=2'b01;
        else   ns=2'b11;
        end
  default:ns=2'b00;
  endcase
end

always @ *
case(s)
2'b00:begin ins=0;stall=0;addr=0;read_req=0; end
2'b01:begin stall=0;addr=0;read_req=0;
            if(miss&ok)  begin cachedata[lux][suoyin]= data;
                            biaoji[lux][suoyin]   = bj;
                            youxiao[lux][suoyin]  = 1;
                            ins=data; end
            else if(~miss)  ins=cachedata[lux][suoyin];
            else ins=0;
            if(lru[0][suoyin]<lru[lux][suoyin])  lru[0][suoyin]=lru[0][suoyin]+1;
            if(lru[1][suoyin]<lru[lux][suoyin])  lru[1][suoyin]=lru[1][suoyin]+1;
            if(lru[2][suoyin]<lru[lux][suoyin])  lru[2][suoyin]=lru[2][suoyin]+1;
            if(lru[3][suoyin]<lru[lux][suoyin])  lru[3][suoyin]=lru[3][suoyin]+1;
            lru[lux][suoyin] = 0;
      end
2'b10:begin ins=0;stall=0;addr=insaddr;read_req=1; end
2'b11:begin ins=0;stall=1;addr=insaddr;read_req=1; end
default:begin ins=0;stall=0;addr=0;read_req=0; end
endcase

endmodule
