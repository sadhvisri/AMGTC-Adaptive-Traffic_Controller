# Task 5 — Full Verification and Coverage
## Verification architecture
The final environment is self-checking and combines directed corner cases with randomized traffic-density activity.

## Mandatory scenarios covered
- Reset during active operation
- Emergency during all six traffic phases
- More than 100 pedestrian grants
- Five green-wave density combinations
- Density sweep 0–7
- Minimum and maximum adaptive timing
- Randomized traffic-density operation

## Final quantitative results
- Randomized cycles: 200
- Pedestrian grants: 120
- Pedestrian A/B: 60/60
- Emergency phases: 0–5
- Green-wave combinations: 5
- Green-wave offset: 2 clock cycles
- ModelSim errors/warnings: 0/0
- Final result: TASK 5 FULL VERIFICATION: PASS

## Debugging
An early fairness test ended at 64 grants. The testbench was corrected to continue to 120 grants, after which the fairness result was 60/60.
