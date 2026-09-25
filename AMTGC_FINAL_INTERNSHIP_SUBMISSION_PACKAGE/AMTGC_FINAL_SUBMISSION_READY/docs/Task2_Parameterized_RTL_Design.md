# Task 2 — Parameterized RTL Design
## Generic timer
`generic_timer.v` is a standalone timing primitive with a parameterized counter width and programmable target. This keeps timing logic independent of traffic policy.

## Junction controller
`junction_controller.v` implements a parameterized Moore-style FSM. Traffic phases are represented explicitly, including green, yellow, all-red and pedestrian handling.

## Design practices
- Non-blocking assignments in sequential logic
- Reset-defined registers
- Parameters instead of timing magic numbers
- Named port connections
- Default FSM branches
- Timer logic separated from policy

## Reuse
The same controller source is used for both junctions, reducing duplicated RTL and keeping the architecture consistent.
