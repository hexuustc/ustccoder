### 5 stage pipeline CPU
My design sources of 5 stage pipeline cpu with forwarding unit and hazard detection unit are in directory cpu_pipeline. It only supports six simple instructions: add, addi, lw, sw, beq and j. Beq and j are finished in EX stage in my design, so the pipeline is stalled for two clock cycles when j is executed or beq branched successfully.

Note: The pipeline cpu has passed test 1 and test 2 in cod experiment 5.

### axi interface for CPU
myCPU.v is the axi interface for a CPU with a normal sram interface. It has never been tested or simulated yet.

cpu_axi_interface.v is the interface provided by the Loongson. We can use it first.
