# AMTGC Demonstration Video Script

## 0–10 s — Project overview
Introduce AMTGC as a two-junction adaptive traffic-grid controller implemented in Verilog RTL and verified in ModelSim.

## 10–20 s — Architecture
Show the architecture diagram and explain the two parameterized junction controllers, reusable timer and shared pedestrian arbiter.

## 20–30 s — FSM and timing
Show the junction FSM and generic timer waveform. Explain explicit green, yellow, all-red and pedestrian phases.

## 30–40 s — Green wave
Show the green-wave waveform and state that the measured coordination offset is two clock cycles.

## 40–50 s — Pedestrian fairness
Show pedestrian waveform and report 120 grants with A=60 and B=60.

## 50–60 s — Emergency override
Show emergency evidence and explain that emergency behavior was checked during all six traffic phases.

## 60–70 s — Adaptive timing
Show density-dependent timing. Explain density values 0–7, minimum green 2 cycles and maximum green 5 cycles.

## 70–80 s — Task 4 verification
Show the Task 4 PASS transcript and mention that generic_timer.v was not modified.

## 80–90 s — Final verification
Show the Task 5 PASS transcript and state: 200 randomized cycles, 120 pedestrian grants, all six emergency phases, five green-wave combinations, 0 errors and 0 warnings.
