---
name: ralph
description: Generate the complete Ralph Wiggum loop infrastructure for iterative AI-driven development. Creates specs, implementation plans, and loop scripts for autonomous AI development.
---

# Ralph Wiggum Loop Generator

Generate the complete Ralph Wiggum loop infrastructure for iterative AI-driven development.

## Ralph 2.0 (Recommended)

Uses the Amp SDK for programmatic thread orchestration with native thread map integration.

### Quick Start

```bash
# Navigate to SDK directory
cd ~/.config/agents/skills/ralph-wiggum/sdk

# Install dependencies (first time only)
bun install

# Run on your project
bun run src/cli.ts auto -p /path/to/project --validation "pnpm run check"
```

### Commands

```bash
bun run src/cli.ts plan      # Create implementation plan from specs
bun run src/cli.ts build     # Execute tasks from plan
bun run src/cli.ts auto      # Plan then build (recommended)
bun run src/cli.ts --help    # Show all options
```

### Key Features

| Feature | Description |
|---------|-------------|
| **Thread Map** | Build threads link to coordinator via URL mentions |
| **Clean Context** | Each thread reads only plan + specs (no pollution) |
| **Thread Tracking** | Thread IDs recorded in `IMPLEMENTATION_PLAN.md` |
| **Dependency Aware** | Respects `depends_on` task ordering |
| **Error Recovery** | Handles consecutive failures gracefully |

### How It Works

1. **Planning Phase**: Creates `IMPLEMENTATION_PLAN.md` from specs
2. **Build Phase**: For each task:
   - Spawns Amp thread with focused instructions
   - Includes coordinator URL (creates thread map link)
   - Implements, validates, commits
   - Updates plan with thread ID
3. **Validation Phase**: Final checks, outputs `RALPH_COMPLETE`

### Thread Map Visualization

All threads appear connected in Amp's Thread Map (`threads: map`):

```
    Coordinator (Plan)
         │
         ├── Build P0.1
         ├── Build P1.1
         └── Build P2.1
```

See [sdk/README.md](sdk/README.md) for full documentation.

---

## Ralph 1.0 (Legacy)

Traditional bash-based loop that restarts Amp for each iteration.

### Usage

```bash
# Generate loop files
/skill ralph docs/my-feature.md

# Run the loop
./loop.sh           # Auto mode: plan first, then build
./loop.sh plan      # Planning mode only
./loop.sh build     # Build mode only
```

### Generated Files

| File | Purpose |
|------|---------|
| `specs/*.md` | Feature specs (one topic per file) |
| `IMPLEMENTATION_PLAN.md` | Prioritized task list |
| `PROMPT_plan.md` | Planning mode instructions |
| `PROMPT_build.md` | Building mode instructions |
| `loop.sh` | The bash loop script |

---

## When to Use Ralph

- Starting a new feature that needs iterative AI development
- Setting up autonomous development loops
- Generating specs and implementation plans from feature docs

## IMPLEMENTATION_PLAN.md Format

```markdown
# Implementation Plan

## Tasks

### P0: Core (must have)

- [ ] P0.1 Create user model
  - scope: src/models/user.ts
  - validation: npm run check
  - assigned_thread:
  - status: not_started

- [ ] P0.2 Add user API
  - scope: src/api/users.ts
  - validation: npm run check
  - assigned_thread:
  - status: not_started
  - depends_on: P0.1
```

## Amp Tools Used

- **Oracle**: For planning, gap analysis, and debugging
- **Librarian**: For reading library documentation
- **finder**: For semantic codebase search
- **Task**: For parallel subagent work (within threads)
- **Amp SDK**: For programmatic thread orchestration (v2)
