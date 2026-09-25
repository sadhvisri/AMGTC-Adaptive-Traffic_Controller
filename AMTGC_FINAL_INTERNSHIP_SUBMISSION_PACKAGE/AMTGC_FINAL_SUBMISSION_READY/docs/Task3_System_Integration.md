# Task 3 — System Integration
## Integration
`amtgc_top.v` integrates two junction controllers, timing resources and a shared pedestrian arbiter.

## Green-wave
Junction B is coordinated relative to Junction A using a bounded clock-cycle offset. The measured integration result is a 2-clock-cycle green-wave offset.

## Pedestrian arbitration
Requests are handled through a shared arbiter rather than duplicated priority logic. The final fairness verification reports 50/50 grants in the earlier integration test and 60/60 over 120 grants in the final Task 5 run.

## Emergency
The top-level emergency path is verified as a system feature rather than as an isolated module behavior.
