#### 5 stage pipeline CPU
My design sources of 5 stage pipeline cpu with forwarding unit and hazard detection unit are in directory cpu_pipeline. It only supports six simple instructions: add, addi, lw, sw, beq and j. Beq and j are finished in EX stage in my design, so the pipeline is stalled for two clock cycles when j is executed or beq branched successfully.
