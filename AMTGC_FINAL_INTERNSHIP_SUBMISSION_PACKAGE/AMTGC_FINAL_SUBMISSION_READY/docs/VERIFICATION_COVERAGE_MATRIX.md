# Verification Coverage Matrix — AMTGC

| Requirement / Scenario | Method | Evidence | Result |
|---|---|---|---|
| Generic timer operation | Module test + waveform | `01_Generic_Timer_Waveform.png` | PASS |
| Junction FSM sequencing | Module test + waveform | `02_Junction_Controller_FSM_Waveform.png` | PASS |
| Green-wave coordination | Integration test | `03_Green_Wave_Waveform.png`, Task 3 PASS | PASS |
| Pedestrian fairness | Self-checking count | `04_Pedestrian_Fairness_Waveform.png`, Task 5 PASS | 120 grants; A=60/B=60 |
| Emergency during NS green | Directed test | Task 5 PASS | PASS |
| Emergency during NS yellow | Directed test | Task 5 PASS | PASS |
| Emergency during all-red | Directed test | Task 5 PASS | PASS |
| Emergency during EW green | Directed test | Task 5 PASS | PASS |
| Emergency during EW yellow | Directed test | Task 5 PASS | PASS |
| Emergency during pedestrian phase | Directed test | Task 5 PASS | PASS |
| Density 0–7 | Exhaustive 3-bit sweep | Task 4 PASS + adaptive waveform | PASS |
| Minimum green enforcement | Directed adaptive test | Task 4 PASS | 2 cycles |
| Maximum green enforcement | Directed adaptive test | Task 4 PASS | 5 cycles |
| Density sampled at green entry | Design decision + waveform | Adaptive documentation | PASS |
| Green-wave under density combinations | Five combinations | Task 5 PASS | PASS |
| Reset during active operation | Directed corner case | Task 5 PASS | PASS |
| Randomized traffic-density operation | 200 cycles | Task 5 PASS | PASS |
| Final system verification | Unified self-checking testbench | Task 5 PASS transcript | PASS |
| ModelSim errors/warnings | Simulation transcript | Task 5 PASS transcript | 0/0 |

## Coverage note
The verification package demonstrates the mandatory functional scenarios described in the assignment material, including >100 pedestrian requests, all six emergency phases, five green-wave combinations, exhaustive 0–7 density sweep, active-operation reset, and randomized operation.
