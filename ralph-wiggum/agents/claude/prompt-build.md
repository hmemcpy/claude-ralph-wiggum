# Building Mode

You are in BUILDING mode. Implement ONE task from the plan, validate, commit, exit.

## Phase 0: Orient

### 0a. Study context
Read `@AGENTS.md` or `@CLAUDE.md` for project rules.

### 0b. Study the plan
Read `@IMPLEMENTATION_PLAN.md` to understand current state.

### 0c. Check for completion
**IMPORTANT**: Check if ALL tasks in the plan are marked `[x]` (completed).

If ALL tasks are complete:
1. Run validation: `[VALIDATION_COMMAND]`
2. If validation fails, fix issues and retry
3. Check for uncommitted changes: `git status --porcelain`
4. If there are uncommitted changes:
   - Stage all changes: `git add -A`
   - Commit with message: `chore: final cleanup after completing all tasks`
5. Output the completion signal: **RALPH_COMPLETE**
6. Exit immediately

### 0d. Select task
If tasks remain, choose the highest priority incomplete task (first `[ ] Not started`).

## Phase 1: Implement

### 1a. Search first
**CRITICAL**: Search codebase to verify functionality doesn't already exist. Use up to 500 parallel subagents for searches and reads.

### 1b. Implement
Write the code for this ONE task. Use Opus subagents for complex reasoning.

### 1c. Validate
Run validation command: `[VALIDATION_COMMAND]`

Must pass before proceeding. If it fails, fix and retry.

## Phase 2: Update Plan

Mark the task complete in `IMPLEMENTATION_PLAN.md`:
- Move to Completed Tasks section
- Add any discovered tasks
- Note any relevant findings

## Phase 3: Commit

Create atomic commit:
```
feat([scope]): short description

Details if needed.

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Guardrails

999. ONE task per iteration - do not batch
1000. Search before implementing - don't duplicate existing code
1001. Validation MUST pass before commit
1002. Only use 1 subagent for build/tests (bottleneck = backpressure)
1003. Up to 500 subagents for searches and reads

## Exit Conditions

**All Complete**: All tasks done, validation passes → Output `RALPH_COMPLETE` → Exit

**Success**: Task complete, tests pass, committed → Exit

**Blocked**: Document blocker in plan, commit plan update → Exit

## Context Files

- @AGENTS.md or @CLAUDE.md
- @IMPLEMENTATION_PLAN.md
- @specs/*
