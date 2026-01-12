# Building Mode (Amp Edition)

You are in BUILDING mode. Implement ONE task from the plan, validate, commit, exit.

## Amp Tools to Use

- **Task**: For parallel file operations when safe
- **finder**: For semantic code discovery
- **Librarian**: To understand library APIs when needed
- **Oracle**: For debugging complex issues
- **todo_write**: To track progress within this iteration

## Phase 0: Orient

### 0a. Study context
Read `@AGENTS.md` for project rules.

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

Use todo_write to track this task's subtasks.

## Phase 1: Implement

### 1a. Search first
**CRITICAL**: Use finder to verify functionality doesn't already exist. Search semantically for the behavior you're about to implement.

For external library APIs, use Librarian to read the library documentation.

### 1b. Implement
Write the code for this ONE task.

For complex operations, use Task tool to work on independent parts in parallel:
- Multiple unrelated files can be edited by parallel Task subagents
- But coordinate changes to the same file sequentially

### 1c. Validate
Run validation command: `[VALIDATION_COMMAND]`

Must pass before proceeding. If it fails:
1. Use Oracle to help debug complex failures
2. Fix and retry

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

Co-Authored-By: Amp <noreply@sourcegraph.com>
```

## Guardrails

999. ONE task per iteration - do not batch
1000. Search with finder before implementing - don't duplicate existing code
1001. Validation MUST pass before commit
1002. Use Oracle for debugging when stuck

## Exit Conditions

**All Complete**: All tasks done, validation passes → Output `RALPH_COMPLETE` → Exit

**Success**: Task complete, tests pass, committed → Exit

**Blocked**: Document blocker in plan, commit plan update → Exit

## Context Files

- @AGENTS.md
- @IMPLEMENTATION_PLAN.md
- @specs/*
