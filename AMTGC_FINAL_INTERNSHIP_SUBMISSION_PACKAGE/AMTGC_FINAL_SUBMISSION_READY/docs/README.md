# AMTGC — Adaptive Multi-Junction Traffic Grid Controller
## Final Internship Submission Package

### 1. Project
AMTGC is a Verilog RTL implementation for two coordinated traffic junctions. The design combines:
- Parameterized traffic-light FSM control
- Reusable generic timer
- Pedestrian arbitration with fairness
- Emergency override
- Green-wave coordination
- Traffic-density adaptive green timing
- Self-checking system-level verification

### 2. Tool
ModelSim Intel FPGA Edition 10.5b

### 3. Required repository structure
```text
AMTGC_FINAL_SUBMISSION/
├── rtl/
├── tb/
├── sim/
├── docs/
├── waveforms/
├── diagrams/
├── verification/
└── README.md
```

### 4. Reproduce the final verification
Open ModelSim in the project root and run:
```text
do sim/run_all.do
```

Manual sequence:
```text
vlib work
vlog rtl/generic_timer.v
vlog rtl/junction_controller.v
vlog rtl/ped_arbiter.v
vlog rtl/amtgc_top.v
vlog tb/tb_generic_timer.v
vlog tb/tb_junction_controller.v
vlog tb/tb_green_wave.v
vlog tb/tb_amtgc_top.v
vlog tb/tb_task4_adaptive.v
vlog tb/tb_task5_full.v
vsim work.tb_task5_full
run -all
```

### 5. Final verified results
- Task 4 adaptive density sweep: PASS for density 0–7
- Minimum green: 2 cycles
- Maximum green: 5 cycles
- `generic_timer.v` unchanged for adaptive timing
- Green-wave offset: 2 clock cycles
- Pedestrian fairness: 120 grants, A=60, B=60
- Emergency: tested during all six traffic phases
- Randomized density run: 200 cycles
- Reset during active operation: PASS
- Task 5 full verification: PASS
- ModelSim errors/warnings: 0/0

### 6. Evidence
The `waveforms/` directory contains the submitted ModelSim waveform and PASS-transcript screenshots. The `diagrams/` directory contains the architecture and FSM diagrams.

### 7. Final consistency rule
The RTL in `rtl/` is the version associated with the final verification evidence. Do not change the RTL after submission unless it is re-verified.

### 8. External submission items
Before the one-time internship submission, insert the public GitHub URL and public demonstration-video URL wherever the portal asks for them. Verify both in an incognito/private browser window before submitting.
