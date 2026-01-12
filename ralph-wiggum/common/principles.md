## Core Principles (From Ralph Guidelines)

1. **Deterministic Setup**: Same files seed each loop for known starting state
2. **One Task Per Iteration**: Maximize context utilization for that task
3. **Backpressure**: Tests/lint/typecheck reject invalid outputs, forcing correction
4. **Plan Disposability**: Plans can be regenerated. One planning loop is cheap.
5. **Don't Assume Not Implemented**: Search codebase before changing code
6. **Let Ralph Ralph**: Agent determines prioritization and implementation approach
