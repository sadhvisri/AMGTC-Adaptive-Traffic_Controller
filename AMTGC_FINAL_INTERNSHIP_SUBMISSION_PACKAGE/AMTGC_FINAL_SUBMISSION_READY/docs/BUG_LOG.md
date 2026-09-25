# Bug Log — AMTGC

| ID | Area | Observation | Root cause | Corrective action | Final status |
|---|---|---|---|---|---|
| BUG-01 | ModelSim path | ModelSim could not open `tb/...` files when launched outside the project root | Simulation working directory did not contain `rtl/`, `tb/`, and `sim/` | Moved to the actual project root and used `do sim/run_all.do` | Closed |
| BUG-02 | Task 5 fairness | Early verification stopped at 64 pedestrian grants | Testbench termination condition did not enforce the >100-request requirement | Extended the test until 120 grants were observed and checked A/B fairness | Closed |
| BUG-03 | Adaptive timing verification | Adaptive behavior required density-specific checking | Fixed timing was insufficient to demonstrate Task 4 | Added a density sweep for all 3-bit values 0–7 and checked min/max behavior | Closed |
| BUG-04 | Verification evidence | Visual waveform inspection alone was insufficient for final verification | Task 5 requires self-checking verification | Unified self-checking testbench reports PASS/FAIL results and covers directed plus randomized scenarios | Closed |

## Verification lesson
The fairness issue is explicitly retained in the record because verification environments must be debugged as carefully as RTL. The corrected final run checks 120 grants and reports A=60 and B=60.
