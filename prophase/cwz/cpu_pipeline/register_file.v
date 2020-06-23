// Create Date: 2020/05/05 09:04:03
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


module register_file				//32 x WIDTH寄存器堆
#(parameter WIDTH = 32) 	//数据宽度
(input clk,						//时钟（上升沿有效）
input [4:0] ra0,				//读端口0地址
output reg [WIDTH-1:0] rd0, 	//读端口0数据
input [4:0] ra1, 				//读端口1地址
output reg [WIDTH-1:0] rd1, 	//读端口1数据
input [4:0] wa, 				//写端口地址
input we,					//写使能，高电平有效
input [WIDTH-1:0] wd 		//写端口数据
);

reg [WIDTH-1:0] reg_file [0:31];

initial
    $readmemh("E:/cod experiment/project_5/reg_data.txt", reg_file);

always @(negedge clk)
begin
    rd0 <= (ra0 == wa && we && wa != 0)? wd : reg_file[ra0];
    rd1 <= (ra1 == wa && we && wa != 0)? wd : reg_file[ra1];
end

always @(posedge clk)
begin
    if(we)
    begin
        if(wa > 0)
            reg_file[wa] <= wd;
        else
            reg_file[wa] <= 0;
    end
end

endmodule
