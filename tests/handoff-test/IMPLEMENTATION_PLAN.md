# Implementation Plan

## Legend
- `[ ]` Not started
- `[~]` In progress  
- `[x]` Completed
- `[!]` Blocked

## Tasks

### P0: Core (must have)

- [x] P0.1 Create greet function with basic greeting
  - scope: src/greet.ts
  - validation: npx tsc --noEmit
  - assigned_thread: https://ampcode.com/threads/T-019bb2c7-2b51-715b-b592-99848d31dc42
  - status: completed

### P1: Should have

- [ ] P1.1 Add formal mode parameter to greet function
  - scope: src/greet.ts
  - validation: npx tsc --noEmit
  - assigned_thread:
  - status: not_started
  - depends_on: P0.1

### P2: Nice to have

- [ ] P2.1 Add greetByTime function for time-based greetings
  - scope: src/greet.ts
  - validation: npx tsc --noEmit
  - assigned_thread:
  - status: not_started
  - depends_on: P0.1

## Notes
- All tasks touch src/greet.ts so must be sequential
- P1.1 and P2.1 both depend on P0.1 (file creation)
