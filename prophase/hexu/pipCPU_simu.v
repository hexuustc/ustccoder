`timescale 1ns / 100ps

module pipCPU_simu;
    reg clk, rst;
    
parameter PERIOD = 10, 	//时钟周期长度
CYCLE = 100;		//时钟个数

 pipCPU  pipCPU(clk,rst);
    
    initial
    begin
        clk = 0;
        repeat (2 * CYCLE)
        	#(PERIOD/2) clk = ~clk;
        $finish;
    end
    
    initial
    begin
        rst = 1;
        #PERIOD rst = 0;
    end
  
endmodule
