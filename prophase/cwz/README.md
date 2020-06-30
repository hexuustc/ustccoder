### 5 stage pipeline CPU
My design sources of 5 stage pipeline cpu with forwarding unit and hazard detection unit are in directory cpu_pipeline. It only supports six simple instructions: add, addi, lw, sw, beq and j. Beq and j are finished in EX stage in my design, so the pipeline is stalled for two clock cycles when j is executed or beq branched successfully.

Note: The pipeline cpu has passed test 1 and test 2 in cod experiment 5.

### axi interface for CPU
myCPU.v is my axi interface for a CPU with a sram-like interface. It has never been tested or simulated yet. Moreover, after I try to write this interface, I know how good cpu_axi_interface.v is. My code is worse than that code, need much resources and maybe have bugs...
If we need to write a cache before long, maybe I can rewrite my code.

cpu_axi_interface.v is the interface provided by the Loongson. We can use it first.
