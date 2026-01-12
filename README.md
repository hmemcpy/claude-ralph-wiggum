# Ralph Wiggum Loop - Multi-Agent Plugin

Generate the complete [Ralph Wiggum loop](https://github.com/ghuntley/how-to-ralph-wiggum) infrastructure for iterative AI-driven development. Supports multiple AI agents with agent-specific optimizations.

## What is Ralph?

An iterative AI development loop where tasks are executed one at a time, with the agent figuring out what to do next by reading the plan file.

### Ralph 2.0 (Amp SDK) - Recommended

Uses the Amp SDK for programmatic thread orchestration with native thread map integration:

```
┌─────────────────────────────────────────────────────────────┐
│                    RALPH ORCHESTRATOR                        │
│  TypeScript CLI using @sourcegraph/amp-sdk                  │
└─────────────────────────────────────────────────────────────┘
         │
         ├──▶ Thread: Planning (create plan from specs)
         │
         ├──▶ Thread: Build P0.1 ──┐
         ├──▶ Thread: Build P0.2   │ Connected in Thread Map
         │    ...                 ──┘
         │
         └──▶ Thread: Validation (final checks)
```

**Key features:**
- Native Amp thread management
- Thread map connectivity via URL mentions (no context pollution)
- Clean context per task
- Thread IDs tracked in `IMPLEMENTATION_PLAN.md`

See [sdk/README.md](sdk/README.md) for details.

### Ralph 1.0 (Bash Loop) - Legacy

A dumb bash script keeps restarting the AI agent:

```
┌─────────────────────────────────────────────────────────────┐
│                    OUTER LOOP (bash)                        │
│          while :; do $AGENT < PROMPT.md ; done              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   INNER LOOP (agent)                        │
│   Read plan → Pick task → Implement → Test → Commit         │
└─────────────────────────────────────────────────────────────┘
```

Two modes:
- **Planning**: Gap analysis. Output prioritized task list. No implementation.
- **Building**: Implement ONE task, validate, commit, exit. Repeat.

## Supported Agents

| Agent | Ralph 2.0 (SDK) | Ralph 1.0 (Bash) |
|-------|-----------------|------------------|
| **Amp** | ✅ `bun run sdk/src/cli.ts` | ✅ `./loop.sh` |
| **Claude Code** | ❌ | ✅ `./loop.sh` |

## Installation

### Amp - Ralph 2.0 (SDK)

```bash
# Clone and install
git clone https://github.com/hmemcpy/ralph-wiggum
cd ralph-wiggum/sdk
bun install

# Run
bun run src/cli.ts --help
bun run src/cli.ts auto -p /path/to/project --validation "pnpm run check"
```

### Amp - Ralph 1.0 (Skill)

```bash
# Install the ralph skill
amp skill add hmemcpy/ralph-wiggum/ralph

# Use
/skill ralph docs/my-feature.md
```

### Claude Code

```bash
# In Claude Code interactive mode:
/plugin install https://github.com/hmemcpy/ralph-wiggum

# Use
/ralph-wiggum:ralph docs/my-feature.md
```

## Usage

### Ralph 2.0 (SDK)

```bash
cd sdk

# Auto mode: plan then build
bun run src/cli.ts auto -p /path/to/project

# Plan only
bun run src/cli.ts plan -p /path/to/project

# Build only (requires existing IMPLEMENTATION_PLAN.md)
bun run src/cli.ts build -p /path/to/project

# With options
bun run src/cli.ts build -v --validation "pnpm run check"
```

### Ralph 1.0 (Bash)

```bash
chmod +x loop.sh

# Auto mode: plan first, then build (default)
./loop.sh

# Planning mode only
./loop.sh plan

# Build mode only
./loop.sh build

# Limit iterations
./loop.sh 10
```

## Generated Files

| File | Purpose |
|------|---------|
| `specs/*.md` | Feature specs (one topic per file) |
| `IMPLEMENTATION_PLAN.md` | Prioritized task list with thread tracking |
| `PROMPT_plan.md` | Planning mode instructions (v1 only) |
| `PROMPT_build.md` | Building mode instructions (v1 only) |
| `loop.sh` | The bash loop script (v1 only) |

## IMPLEMENTATION_PLAN.md Format

```markdown
# Implementation Plan

## Tasks

### P0: Core (must have)

- [ ] P0.1 Create user model
  - scope: src/models/user.ts
  - validation: npm run check
  - assigned_thread: T-xxx (filled by Ralph 2.0)
  - status: not_started

- [ ] P0.2 Add user API
  - scope: src/api/users.ts
  - validation: npm run check
  - assigned_thread:
  - status: not_started
  - depends_on: P0.1
```

## Core Principles

1. **Deterministic Setup** - Same files seed each loop
2. **One Task Per Iteration** - Maximize context for that task
3. **Backpressure** - Tests must pass before commit
4. **Plan Disposability** - Regenerate when off-track
5. **Search First** - Don't assume not implemented
6. **Clean Context** - No inherited cruft between tasks

## Project Structure

```
ralph-wiggum/
├── sdk/                    # Ralph 2.0 - TypeScript SDK orchestrator
│   ├── src/
│   │   ├── cli.ts
│   │   ├── orchestrator.ts
│   │   ├── plan-parser.ts
│   │   ├── prompts.ts
│   │   └── types.ts
│   ├── package.json
│   └── README.md
├── agents/                 # Ralph 1.0 - Agent-specific templates
│   ├── claude/
│   │   ├── prompt-plan.md
│   │   ├── prompt-build.md
│   │   └── loop.sh
│   └── amp/
│       ├── prompt-plan.md
│       ├── prompt-build.md
│       └── loop.sh
├── common/                 # Shared documentation
├── commands/               # Claude Code plugin commands
├── skills/                 # Amp skill definitions
├── SKILL.md
└── README.md
```

## Comparison

| Aspect | Ralph 2.0 (SDK) | Ralph 1.0 (Bash) |
|--------|-----------------|------------------|
| Driver | TypeScript + Amp SDK | Bash loop + CLI |
| Thread mgmt | Native, tracked in plan | External, disconnected |
| Thread map | Coordinator → child links | No connections |
| Context | Clean, explicit per task | Lost between iterations |
| Agents | Amp only | Amp, Claude Code |

## Requirements

- **Ralph 2.0**: Bun, Amp account
- **Ralph 1.0**: AI coding agent (Claude Code or Amp), `jq`
- A project with tests/linting (for backpressure)

## Security Warning

Ralph runs autonomously with permissions bypassed. **Always run in a sandboxed environment** (Docker, VM, etc.) to protect credentials and sensitive files.

## License

MIT

## Credits

Based on [How to Ralph Wiggum](https://github.com/ghuntley/how-to-ralph-wiggum) by Geoffrey Huntley.
