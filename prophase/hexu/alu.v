`timescale 1ns / 1ps

module alu
    #(parameter WIDTH = 32)
    (output reg [WIDTH-1:0] y,
    output reg zf,
    output reg cf,
    output reg of,
    input [WIDTH-1:0] a,b,
    input [3:0] m
    );
    
reg [63:0] prod;
reg [31:0] num;
reg q;
 
 initial    //赋予初始值为0
 begin
    zf = 0;
    of = 0;
    cf = 0;
    y = 0;
 end
 
always @(*)
begin
    case(a)
        0: num<=32'b1;
        1: num<=32'b10;
        2: num<=32'b100;
        3: num<=32'b1000;
        4: num<=32'b10000;
        5: num<=32'b100000;
        6: num<=32'b1000000;
        7: num<=32'b10000000;
        8: num<=32'b100000000;
        9: num<=32'b1000000000;
        10: num<=32'b10000000000;
        11: num<=32'b100000000000;
        12: num<=32'b1000000000000;
        13: num<=32'b10000000000000;
        14: num<=32'b100000000000000;
        15: num<=32'b1000000000000000;
        16: num<=32'b10000000000000000;
        17: num<=32'b100000000000000000;
        18: num<=32'b1000000000000000000;
        19: num<=32'b10000000000000000000;
        20: num<=32'b100000000000000000000;
        21: num<=32'b1000000000000000000000;
        22: num<=32'b10000000000000000000000;
        23: num<=32'b100000000000000000000000;
        24: num<=32'b1000000000000000000000000;
        25: num<=32'b10000000000000000000000000;
        26: num<=32'b100000000000000000000000000;
        27: num<=32'b1000000000000000000000000000;
        28: num<=32'b10000000000000000000000000000;
        29: num<=32'b100000000000000000000000000000;
        30: num<=32'b1000000000000000000000000000000;
        31: num<=32'b10000000000000000000000000000000;
    default: num<=0;
    endcase
end
    
always @(*)//进位与借位的表示
begin
    case(m)
        4'b0000: {cf,y} <= a + b;
        4'b0001: {cf,y} <= a - b;
        4'b0010: {cf,y} <= a & b;
        4'b0011: {cf,y} <= a | b;
        4'b0100: {cf,y} <= a ^ b;
        4'b0101: begin 
                    prod<=a*b; 
                    y<=prod[63:32]; 
                    q=prod[31]; 
                    if(y=={q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q} )
                        cf<=0;
                    else cf<=1;
                end//有符号乘法,待优化................................
        4'b0110:begin
                   prod<=a*b; 
                    y<=prod[63:32]; 
                    q=prod[31];
                    if(y==0) cf<=0; else cf<=1;
               end//无符号乘法，待优化。。。。。。。。。。。。。。。。。。。。。。
        4'b0111:begin y<=a/b; end//除法，有符号和无符号暂未分清，待优化。。。。。。。。。。。。。。。。。。。。。
        4'b1000:begin if(a>=32) y<=0; else y<=b*num; end//逻辑左移位,可优化。。。。。。。。。。。。
        4'b1001:begin if(a>=32) y<=0; else y<=b/num; end//逻辑右移，可优化。。。。。。。。。。。。
        4'b1010:begin 
                    if(a>=31) y<={32{b[31]}}; 
                    else if(a==0) y<=b;
                    else if(a==1) y<={b[31],b[31:1]};
                    else if(a==2) y<={{2{b[31]}},b[31:2]};
                    else if(a==3) y<={{3{b[31]}},b[31:3]};
                    else if(a==4) y<={{4{b[31]}},b[31:4]};
                    else if(a==5) y<={{5{b[31]}},b[31:5]};
                    else if(a==6) y<={{6{b[31]}},b[31:6]};
                    else if(a==7) y<={{7{b[31]}},b[31:7]};
                    else if(a==8) y<={{8{b[31]}},b[31:8]};
                    else if(a==9) y<={{9{b[31]}},b[31:9]};
                    else if(a==10) y<={{10{b[31]}},b[31:10]};
                    else if(a==11) y<={{11{b[31]}},b[31:11]};
                    else if(a==12) y<={{12{b[31]}},b[31:12]};
                    else if(a==13) y<={{13{b[31]}},b[31:13]};
                    else if(a==14) y<={{14{b[31]}},b[31:14]};
                    else if(a==15) y<={{15{b[31]}},b[31:15]};
                    else if(a==16) y<={{16{b[31]}},b[31:16]};
                    else if(a==17) y<={{17{b[31]}},b[31:17]};
                    else if(a==18) y<={{18{b[31]}},b[31:18]};
                    else if(a==19) y<={{19{b[31]}},b[31:19]};
                    else if(a==20) y<={{20{b[31]}},b[31:20]};
                    else if(a==21) y<={{21{b[31]}},b[31:21]};
                    else if(a==22) y<={{22{b[31]}},b[31:22]};
                    else if(a==23) y<={{23{b[31]}},b[31:23]};
                    else if(a==24) y<={{24{b[31]}},b[31:24]};
                    else if(a==25) y<={{25{b[31]}},b[31:25]};
                    else if(a==26) y<={{26{b[31]}},b[31:26]};
                    else if(a==27) y<={{27{b[31]}},b[31:27]};
                    else if(a==28) y<={{28{b[31]}},b[31:28]};
                    else if(a==29) y<={{29{b[31]}},b[31:29]};
                    else if(a==30) y<={{30{b[31]}},b[31:30]};
                end//算术右移
        default: {cf,y} <= 0;
    endcase
end

always @(*)//溢出位的表示
begin
    case(m)
        3'b000: of <= (~a[WIDTH-1]&~b[WIDTH-1]&y[WIDTH-1])|(a[WIDTH-1]&b[WIDTH-1]&~y[WIDTH-1]);
        3'b001: of <= (~a[WIDTH-1]&b[WIDTH-1]&y[WIDTH-1])|(a[WIDTH-1]&~b[WIDTH-1]&~y[WIDTH-1]);
        3'b101: if(cf==0) of<=0; else of<=1; 
        3'b110: if(cf==0) of<=0; else of<=1;
    default: of <= 0;
    endcase
end

always @(*)//零位的表示
begin
    case(m)
        3'b101:if ((a==0)||(b==0)) zf<=0;
        3'b110:if ((a==0)||(b==0)) zf<=0;
    default: zf<=~|y;
    endcase
end
    
endmodule
