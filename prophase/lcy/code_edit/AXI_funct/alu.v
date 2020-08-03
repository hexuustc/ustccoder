`timescale 1ns / 1ps

module alu
    #(parameter WIDTH = 32)
    (output reg [WIDTH-1:0] y,
    output reg zf,
    output reg cf,
    output reg of,
    input [WIDTH-1:0] a, b,
    input [3:0] m
    );
    
//reg [63:0] prod;
//reg [31:0] num;
//reg q;
 
 initial    //璧嬩簣鍒濆鍊间负0
 begin
    zf = 0;
    of = 0;
    cf = 0;
    y = 0;
 end
    
always @(*)//杩涗綅涓庡?熶綅鐨勮〃绀?
begin
    //prod = 0;
    //q = 0;
    cf = 0;
    case(m)
        4'b0000: {cf,y} = a + b;
        4'b0001: {cf,y} = a - b;
        4'b0010: {cf,y} = a & b;
        4'b0011: {cf,y} = a | b;
        4'b0100: {cf,y} = a ^ b;
        /*4'b0101: begin 
                    prod = 0; 
                    y = prod[63:32]; 
                    q = prod[31]; 
                    if(y == {32{q}} )
                        cf = 0;
                    else cf = 1;
                end//鏈夌鍙蜂箻娉?,寰呬紭鍖?................................
        4'b0110:begin
                   prod = 0; 
                    y = prod[63:32]; 
                    q = prod[31];
                    if(y == 0) cf = 0; else cf = 1;
               end//鏃犵鍙蜂箻娉曪紝寰呬紭鍖栥?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘??
        4'b0111:begin y = 0; end//鏃犵鍙烽櫎娉?*/
        4'b1000:begin if(a >= 32) y = 0; else y = b<<a; end//閫昏緫宸︾Щ浣?,鍙紭鍖栥?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘??
        4'b1001:begin if(a >= 32) y = 0; else y = b>>a; end//閫昏緫鍙崇Щ锛屽彲浼樺寲銆傘?傘?傘?傘?傘?傘?傘?傘?傘?傘?傘??
        4'b1010:begin 
                    y=($signed(b)) >>> a;
                end//绠楁湳鍙崇Щ
        default: {cf,y} = 0;
    endcase
end

always @(*)//婧㈠嚭浣嶇殑琛ㄧず
begin
    case(m)
        3'b000: of = (~a[WIDTH-1]&~b[WIDTH-1]&y[WIDTH-1])|(a[WIDTH-1]&b[WIDTH-1]&~y[WIDTH-1]);
        3'b001: of = (~a[WIDTH-1]&b[WIDTH-1]&y[WIDTH-1])|(a[WIDTH-1]&~b[WIDTH-1]&~y[WIDTH-1]);
        /*3'b101: if(cf == 0) of = 0; else of = 1; 
        3'b110: if(cf == 0) of = 0; else of = 1;*/
    default: of = 0;
    endcase
end

always @(*)//闆朵綅鐨勮〃绀?
begin
    /*case(m)
        3'b101:if ((a == 0)||(b == 0)) zf = 0;
        3'b110:if ((a == 0)||(b == 0)) zf = 0;
    default:*/ zf = ~|y;
    //endcase
end
    
endmodule
