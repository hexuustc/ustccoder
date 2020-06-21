`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/20 04:00:33
// Design Name: 
// Module Name: MDC
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


module MDC(MDC_A,MDC_B,MDC_funct,MDC_oppend,MDC_LO,MDC_HI,MDC_HI_we,MDC_LO_we);
    input [31:0]MDC_A,MDC_B;
    input [5:0]MDC_funct;
    input [1:0]MDC_oppend;
    output reg [31:0]MDC_HI,MDC_LO;
    output reg MDC_HI_we,MDC_LO_we;
    
    wire signed [31:0]MDC_SA,MDC_SB;
    
    assign MDC_SA = MDC_A;
    assign MDC_SB = MDC_B;
    
    always @(*)
    begin
        if(MDC_oppend == 2'b10)
        begin
            case(MDC_funct[5:2])
                3'b0110:
                begin
                    {MDC_HI_we,MDC_LO_we} = 2'b11;
                    case(MDC_funct[1:0])
                        2'b00: {MDC_HI,MDC_LO} = MDC_SA * MDC_SB; 
                        2'b01: {MDC_HI,MDC_LO} = MDC_A * MDC_B;  
                        //{MDC_HI,MDC_LO} = (MDC_A[31] ^ MDC_B[31]) ? (32'hffff_ffff -(32'hffffffff-MDC_A+1)*(32'hffffffff-MDC_B+1) + 1):(32'hffffffff-MDC_A+1)*(32'hffffffff-MDC_B+1);
                        2'b10:
                        begin
                            MDC_HI = MDC_SA % MDC_SB;
                            MDC_LO = MDC_SA / MDC_SB;
                        end
                        2'b11:
                        begin
                            MDC_HI = MDC_A % MDC_B;
                            MDC_LO = MDC_A / MDC_B;
                        end
                        default: {MDC_HI,MDC_LO} = {MDC_HI,MDC_LO};
                    endcase
                end
                3'b0100:
                begin 
                    case(MDC_funct[1:0])
                        2'b01: 
                        begin
                            MDC_HI = MDC_A;
                            MDC_LO = MDC_LO;
                            {MDC_HI_we,MDC_LO_we} = 2'b10;
                        end
                        2'b11: 
                        begin
                            MDC_HI = MDC_HI;
                            MDC_LO = MDC_A;
                            {MDC_HI_we,MDC_LO_we} = 2'b01;
                        end
                        default:
                        begin
                            MDC_HI = MDC_HI;
                            MDC_LO = MDC_LO;
                            {MDC_HI_we,MDC_LO_we} = 2'b00;
                        end
                    endcase  
                end
                default:
                begin
                    MDC_HI = MDC_HI;
                    MDC_LO = MDC_LO;
                    {MDC_HI_we,MDC_LO_we} = 2'b00;
                end
            endcase
        end
        else
        begin
            MDC_HI = MDC_HI;
            MDC_LO = MDC_LO;
            {MDC_HI_we,MDC_LO_we} = 2'b00;
        end
    end
endmodule
