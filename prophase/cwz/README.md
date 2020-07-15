### 5 stage pipeline CPU
My design sources of 5 stage pipeline cpu with forwarding unit and hazard detection unit are in directory cpu_pipeline. It only supports six simple instructions: add, addi, lw, sw, beq and j. Beq and j are finished in EX stage in my design, so the pipeline is stalled for two clock cycles when j is executed or beq branched successfully.

Note: The pipeline cpu has passed test 1 and test 2 in cod experiment 5.

### axi interface for cache
cache_to_axi.v acts as the interface from cache to axi interface. It has passed on-board test together with cod multi-cycle CPU.

### arbiter between icache and dcache
myCPU_top.v is the top file of my test. It uses Xilinx IP core axi_crossbar as an arbiter between icache and dcache. It also uses Xilinx IP core axi_clock_converter and block memory. The CPU is multi-cycle CPU.
