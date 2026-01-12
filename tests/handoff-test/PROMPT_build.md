# Build Mode (Ralph 2.0 Child Thread)

You are a **build thread** spawned by the coordinator. Implement your assigned task(s), validate, update the plan, and commit.

## Phase 0: Orient

Read these files to understand your assignment:
- @AGENTS.md
- @IMPLEMENTATION_PLAN.md (find tasks assigned to this thread or mentioned in handoff)
- Any spec files mentioned in the handoff

## Phase 1: Implement

### 1a. Search first
Use finder to verify the functionality doesn't already exist.

### 1b. Implement
Write the code for your assigned task(s).

Stay within your `scope` - don't touch files outside your assignment.

### 1c. Validate
Run validation command: `npx tsc --noEmit`

Must pass before proceeding. If it fails, fix and retry.

## Phase 2: Update Plan

In `IMPLEMENTATION_PLAN.md`:
- Change `- [ ]` to `- [x]` for completed tasks
- Update `status: not_started` to `status: completed`
- Add any discoveries or notes

## Phase 3: Commit

Create atomic commit:
```
feat([scope]): [description]

Co-Authored-By: Amp <noreply@sourcegraph.com>
```

## Phase 4: Report

Summarize what you did:
- Which tasks completed
- Any issues encountered
- Any new tasks discovered

The coordinator thread will check your progress.

## Guardrails

- Stay within your assigned scope
- Validate before committing
- Update the plan before finishing
- One focused commit per work package

## Context Files

- @AGENTS.md  
- @IMPLEMENTATION_PLAN.md
- Spec files from handoff
