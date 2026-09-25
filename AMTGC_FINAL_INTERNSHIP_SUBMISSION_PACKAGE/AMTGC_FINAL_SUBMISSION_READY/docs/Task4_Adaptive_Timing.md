# Task 4 — Traffic-Adaptive Timing
## Adaptive policy
`traffic_density` is a 3-bit input representing density levels 0–7. The junction controller converts the density into a green-time target and clamps the result between configured minimum and maximum limits.

## Verified configuration
Minimum green = 2 cycles.
Maximum green = 5 cycles.

## Sampling decision
Density is sampled at green-phase entry. This prevents the target from changing unpredictably while a green phase is already active.

## Timer reuse
`generic_timer.v` was not modified for adaptive timing. The controller supplies a different count target to the existing timer interface.

## Verification
All density values 0–7 were tested. The final transcript reports PASS for every value and confirms the minimum and maximum limits.
