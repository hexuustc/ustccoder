`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/15 13:45:33
// Design Name: 
// Module Name: CPU_control
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


module CPU_control(clk,rst,run,op,RegDst,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,push,ALUOp,PCSource);
    input clk,rst,run;
    input [5:0]op;
    output reg RegDst,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,push;
    output reg [1:0]ALUOp,PCSource;
    
    wire [5:0]IF_state;
    reg [5:0]ID_state;
    reg [5:0]EX_state;
    reg [5:0]MEM_state;
    reg [5:0]WB_state;
    
    parameter NONE = 6'b111111;
    
    assign IF_state = op;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            ID_state <= NONE;
            EX_state <= NONE;
            MEM_state <= NONE;
            WB_state <= NONE;
        end
        else
        begin
            if(run)
            begin
                ID_state <= IF_state;
                EX_state <= ID_state;
                MEM_state <= EX_state;
                WB_state <= MEM_state;
            end
            else
            begin
                ID_state <= ID_state;
                EX_state <= EX_state;
                MEM_state <= MEM_state;
                WB_state <= WB_state;
            end
        end
    end
    
    always @(*)
    begin
        case(IF_state)
            6'b000000: {PCSource,push}  = 3'b001;
            6'b111111: {PCSource,push} = 3'b010;
            default: {PCSource,push} = 3'b011;
        endcase
    end
    
    /*always @(*)
    begin
        case(ID_state)
            000000: PCSource  = 2'b00;
            default: PCSource = 2'b01;
        endcase
    end*/
    
    always @(*)
    begin
        case(EX_state[5:3])
            3'b001: {ALUSrc,ALUOp} = 3'b111;
            3'b000: {ALUSrc,ALUOp} = 3'b010;
            default: {ALUSrc,ALUOp} = 3'b100;
        endcase
    end
    
    always @(*)
    begin
        case(MEM_state[5:3])
            3'b000:
            begin
                if(MEM_state[2:0] == 3'b000) MemtoReg = 1'b0;
                else MemtoReg = 1'b1;
            end
            3'b001: MemtoReg = 1'b0;
            default: MemtoReg = 1'b1;
        endcase
    end
    
    always @(*)
    begin
        case(WB_state[5:3])
            3'b000: 
            begin
                if(WB_state[2:0] == 3'b000) {RegDst,RegWrite} = 2'b01;
                else {RegDst,RegWrite} = 2'b00;
            end
            3'b001: {RegDst,RegWrite} = 2'b11;
            default: {RegDst,RegWrite} = 2'b00;
        endcase
    end
endmodule
