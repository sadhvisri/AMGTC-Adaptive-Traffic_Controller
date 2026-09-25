# Task 1 — Architecture and Planning
## Objective
Define a reusable RTL architecture for two coordinated traffic junctions and establish a verification plan before implementation.

## Functional requirements
The system shall sequence North-South and East-West traffic phases, provide all-red safety intervals, support pedestrian requests, arbitrate simultaneous requests fairly, respond to emergency override, coordinate a green wave between junctions, and adapt green duration to traffic density.

## Planned architecture
The architecture separates timing, junction control, pedestrian arbitration and top-level integration. The same parameterized junction controller is instantiated for Junction A and Junction B.

## Verification plan
The plan covers normal state transitions, timer behavior, pedestrian requests, simultaneous requests, emergency operation, green-wave timing, density sweep, minimum/maximum green limits, reset during operation and randomized activity.

## Deliverable
The final architecture and FSM diagrams are stored in `../diagrams/`.
