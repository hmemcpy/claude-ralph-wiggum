# Ralph Wiggum Loop Generator

Generate the complete Ralph Wiggum loop infrastructure for iterative AI-driven development.

Reference: https://github.com/ghuntley/how-to-ralph-wiggum

## Input

$ARGUMENTS

The argument should be a path to a feature/UX document, or a description of the feature to implement. If empty, search for relevant docs in `docs/` directory.

## What is Ralph?

An iterative AI development loop where:
- **Outer loop** (bash): `while :; do cat PROMPT.md | claude ; done`
- **Inner loop** (agent): Read plan → Pick task → Implement → Test → Commit → Exit
- **State persistence**: `IMPLEMENTATION_PLAN.md` lives on disk between iterations

Two operational modes:
- **Planning**: Gap analysis between specs and code. Output: prioritized task list. NO implementation.
- **Building**: Implement ONE task, run tests, commit, update plan. Exit.

## Core Principles (From Ralph Guidelines)

1. **Deterministic Setup**: Same files seed each loop for known starting state
2. **One Task Per Iteration**: Maximize context utilization for that task
3. **Backpressure**: Tests/lint/typecheck reject invalid outputs, forcing correction
4. **Plan Disposability**: Plans can be regenerated. One planning loop is cheap.
5. **Don't Assume Not Implemented**: Search codebase before changing code
6. **Let Ralph Ralph**: Agent determines prioritization and implementation approach

## Your Task

Generate/regenerate the complete Ralph loop infrastructure:

---

### Step 1: Discover Project Context

Read these files to understand the project:
- `CLAUDE.md` or `AGENTS.md` - project rules and commands
- `package.json`, `Cargo.toml`, `go.mod`, or equivalent - determine build system
- Existing `specs/` if any - understand current state

Extract:
- **Validation command** (e.g., `bun run check`, `npm test`, `cargo test`, `go test ./...`)
- **Code patterns** to follow
- **Path conventions** (imports, structure)

---

### Step 2: Generate Specs (`specs/*.md`)

**Topic Scope Test**: Can you describe the topic in ONE sentence WITHOUT "and" for unrelated capabilities?
- PASS: "The effect system renders CSS filters on album art backgrounds"
- FAIL: "The user system handles authentication, profiles, and billing" → Split into 3 specs

**Spec Format** (let format evolve naturally, but include these sections):

```markdown
# [Topic Name]

## Overview
One sentence describing this topic of concern.

## Requirements

### [Requirement Group]
- Requirement detail
- Another requirement

### [Another Group]
...

## State Model (if applicable)
```typescript
interface State { ... }
```

## Files to Create/Modify
- `path/to/file.ext` - what changes

## Acceptance Criteria
- [ ] Observable, verifiable outcome 1
- [ ] Observable, verifiable outcome 2
```

**Naming**: `kebab-case-topic.md` (e.g., `image-edit-mode.md`, `effects-system.md`)

**Important**: Acceptance criteria define WHAT (behavioral outcomes), not HOW (implementation details).

---

### Step 3: Generate `IMPLEMENTATION_PLAN.md`

```markdown
# [Feature Name] - Implementation Plan

Generated from specs. Tasks sorted by priority.

## Status Legend
- [ ] Not started
- [x] Completed
- [~] In progress
- [!] Blocked

---

## Phase 1: [Phase Name] (P0)

### Task 1: [Descriptive task name]
- **File**: `path/to/file.ext` (new) or (modify)
- **Description**: One sentence
- **Details**:
  - Specific implementation detail
  - Another detail
- [ ] Not started

### Task 2: ...

---

## Phase 2: [Phase Name] (P1)
...

---

## Discovered Tasks

(Tasks discovered during implementation go here)

---

## Completed Tasks

(Move completed tasks here with brief notes)

---

## Notes

- One task per loop iteration
- Search before implementing
```

**Priority**:
- P0: Core functionality (feature doesn't work without this)
- P1: Important (significantly improves feature)
- P2: Polish (nice-to-have, accessibility, edge cases)

**Task Sizing**: Each task completable in ONE loop iteration. If too big, split it.

---

### Step 4: Generate `PROMPT_plan.md`

```markdown
# Planning Mode

You are in PLANNING mode. Analyze specifications against existing code and generate a prioritized implementation plan.

## Phase 0: Orient

### 0a. Study specifications
Read all files in `specs/` directory using parallel subagents.

### 0b. Study existing implementation
Use parallel subagents to analyze relevant source directories:
- [List directories relevant to the feature]

### 0c. Study the current plan
Read `IMPLEMENTATION_PLAN.md` if it exists.

## Phase 1: Gap Analysis

Compare specs against implementation:
- What's already implemented?
- What's missing?
- What's partially done?

**CRITICAL**: Don't assume something isn't implemented. Search the codebase first. This is Ralph's Achilles' heel.

## Phase 2: Generate Plan

Update `IMPLEMENTATION_PLAN.md` with:
- Tasks sorted by priority (P0 → P1 → P2)
- Clear descriptions with file locations
- Dependencies noted where relevant
- Discoveries from gap analysis

Capture the WHY, not just the WHAT.

## Guardrails

999. NEVER implement code in planning mode
1000. Use up to 10 parallel subagents for analysis
1001. Each task must be completable in ONE loop iteration
1002. Ultrathink before finalizing priorities

## Exit

When plan is complete:
1. Commit updated `IMPLEMENTATION_PLAN.md`
2. Exit

## Context Files

- @AGENTS.md or @CLAUDE.md
- @specs/*
- @IMPLEMENTATION_PLAN.md
```

---

### Step 5: Generate `PROMPT_build.md`

```markdown
# Building Mode

You are in BUILDING mode. Implement ONE task from the plan, validate, commit, exit.

## Phase 0: Orient

### 0a. Study context
Read `@AGENTS.md` or `@CLAUDE.md` for project rules.

### 0b. Study the plan
Read `@IMPLEMENTATION_PLAN.md` to understand current state.

### 0c. Select task
Choose the highest priority incomplete task (first `[ ] Not started`).

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

**Success**: Task complete, tests pass, committed → Exit

**Blocked**: Document blocker in plan, commit plan update → Exit

## Context Files

- @AGENTS.md or @CLAUDE.md
- @IMPLEMENTATION_PLAN.md
- @specs/*
```

---

### Step 6: Generate `loop.sh`

```bash
#!/bin/bash

# Ralph Wiggum Loop
# Reference: https://github.com/ghuntley/how-to-ralph-wiggum
#
# Usage:
#   ./loop.sh           # Build mode (default)
#   ./loop.sh plan      # Planning mode
#   ./loop.sh 10        # Max 10 iterations
#   ./loop.sh plan 5    # Planning mode, max 5 iterations

set -e

MODE="build"
MAX_ITERATIONS=0
ITERATION=0

for arg in "$@"; do
  if [[ "$arg" == "plan" ]]; then
    MODE="plan"
  elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=$arg
  fi
done

PROMPT_FILE="PROMPT_${MODE}.md"

echo "Ralph loop: ${MODE^^} mode"
[[ $MAX_ITERATIONS -gt 0 ]] && echo "Max iterations: $MAX_ITERATIONS"
echo "Press Ctrl+C to stop"
echo "---"

while true; do
  ITERATION=$((ITERATION + 1))
  echo ""
  echo "=== Iteration $ITERATION ==="
  echo ""

  claude -p \
    --dangerously-skip-permissions \
    --model opus \
    --output-format stream-json \
    <<< "$(cat "$PROMPT_FILE")" \
    | jq -r 'select(.type == "assistant") | .message.content[]?.text // empty'

  if [[ $MAX_ITERATIONS -gt 0 && $ITERATION -ge $MAX_ITERATIONS ]]; then
    echo ""
    echo "Reached max iterations ($MAX_ITERATIONS)."
    break
  fi

  sleep 2
done

echo ""
echo "Ralph loop complete. Iterations: $ITERATION"
```

---

## Execution Checklist

1. [ ] Read project context (CLAUDE.md/AGENTS.md, package.json/Cargo.toml/etc.)
2. [ ] Read feature doc from argument or find in docs/
3. [ ] Remove old specs if they belong to a different feature
4. [ ] Generate new specs (one topic per file, passes "one sentence" test)
5. [ ] Generate IMPLEMENTATION_PLAN.md with prioritized tasks
6. [ ] Generate PROMPT_plan.md (customize directories to analyze)
7. [ ] Generate PROMPT_build.md (set correct validation command)
8. [ ] Generate loop.sh
9. [ ] Run `chmod +x loop.sh`
10. [ ] Verify all files created

## Final Notes

- **Sandbox Warning**: Ralph uses `--dangerously-skip-permissions`. Run in Docker/sandbox to protect credentials.
- **Tuning**: Observe early loops. When Ralph fails consistently, add guardrails to prompts.
- **Regenerate**: If plan goes off-track, delete and regenerate. One planning loop is cheap.
- **Let Ralph Ralph**: Don't over-specify. Agent determines approach.
