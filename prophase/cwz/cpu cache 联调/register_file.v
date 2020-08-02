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


module register_file				//32 x WIDTH�Ĵ�����
#(parameter WIDTH = 32) 	//���ݿ��
(input clk,						//ʱ�ӣ���������Ч��
input [4:0] ra0,				//���˿�0��ַ
output reg [WIDTH-1:0] rd0, 	//���˿�0����
input [4:0] ra1, 				//���˿�1��ַ
output reg [WIDTH-1:0] rd1, 	//���˿�1����
input [4:0] wa, 				//д�˿ڵ�ַ
input we,					//дʹ�ܣ��ߵ�ƽ��Ч
input [WIDTH-1:0] wd 		//д�˿�����
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
