# Ralph Wiggum Loop - Multi-Agent Plugin

Generate the complete [Ralph Wiggum loop](https://github.com/ghuntley/how-to-ralph-wiggum) infrastructure for iterative AI-driven development. Supports multiple AI agents with agent-specific optimizations.

## What is Ralph?

An iterative AI development loop where a dumb bash script keeps restarting the AI agent, and the agent figures out what to do next by reading the plan file each time.

```
┌─────────────────────────────────────────────────────────┐
│                    OUTER LOOP (bash)                    │
│            while :; do amp -x < PROMPT.md ; done        │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   INNER LOOP (agent)                    │
│   Read plan → Pick task → Implement → Test → Commit     │
└─────────────────────────────────────────────────────────┘
```

## Workflow

1. **Planning** (interactive) — `/skill ralph` asks clarifying questions, optionally consults Oracle, generates specs + plan
2. **Building** (loop) — `./loop.sh` implements one task per iteration until complete

## Supported Agents

| Agent | CLI Command | Key Features |
|-------|-------------|--------------|
| **Claude Code** | `claude -p` | Parallel subagents, Opus reasoning, Ultrathink |
| **Amp** | `amp -x` | Oracle (planning/debug), Librarian (docs), finder (semantic search) |

## Installation

### Amp

```bash
# Clone and install
git clone https://github.com/hmemcpy/ralph-wiggum
cd ralph-wiggum
./install.sh
```

### Claude Code

```bash
# Add as a marketplace
/plugin marketplace add hmemcpy/ralph-wiggum

# Install the plugin
/plugin install ralph-wiggum@ralph-wiggum
```

## Usage

### Amp

```bash
# Start interactive planning
/skill ralph [optional/path/to/plan.md]
```

The skill will:
1. Ask 3-5 clarifying questions (A/B/C/D format — respond with "1A, 2C, 3B")
2. Optionally run Oracle for architectural review
3. Generate all files

**Generated files:**

| File | Purpose |
|------|---------|
| `specs/<feature>.md` | Requirements, user stories, edge cases |
| `IMPLEMENTATION_PLAN.md` | Summary + prioritized task list |
| `PROMPT.md` | Build mode instructions |
| `loop.sh` | Build-only loop script |

### Claude Code

```bash
/ralph-wiggum:ralph [optional/path/to/plan.md]
```

The command will:
1. Ask 3-5 clarifying questions (A/B/C/D format — respond with "1A, 2C, 3B")
2. Optionally run deep analysis with Opus subagents
3. Generate all files

## Running the Loop

```bash
chmod +x loop.sh

# Run until complete
./loop.sh

# Limit iterations
./loop.sh 10
```

## Loop Features

- **Build-only**: Planning is interactive, loop only builds
- **Rate limit handling**: Detects API limits and waits with countdown timer
- **Error recovery**: Retries on transient failures (max 3 consecutive)
- **Thread tracking**: Commits include Amp thread URL for traceability
- **Completion detection**: Exits when agent outputs `RALPH_COMPLETE`

## Amp-Specific Features

- **Oracle**: Architecture review, planning decisions, debugging
- **Librarian**: Read library documentation, understand APIs
- **finder**: Semantic codebase search (not just text matching)
- **Task**: Parallel subagent work for independent operations

## Core Principles

1. **Interactive Planning** - Clarifying questions before generation
2. **One Task Per Iteration** - Maximize context for that task
3. **Backpressure** - Validation must pass before commit
4. **Search First** - Don't assume functionality doesn't exist
5. **Let Ralph Ralph** - Agent determines approach

## Project Structure

```
ralph-wiggum/
├── skills/
│   └── ralph/
│       └── SKILL.md        # Amp skill (unified planning + generation)
├── commands/
│   └── ralph.md            # Claude Code command (unified planning + generation)
├── common/                 # Shared components
├── SKILL.md                # Root skill
├── install.sh              # Install to ~/.config/agents/skills/
└── README.md
```

## Requirements

- An AI coding agent (Amp or Claude Code)
- A project with tests/linting (for backpressure)
- `jq` installed (for JSON output parsing)

## Security Warning

Ralph runs autonomously with permissions bypassed. **Always run in a sandboxed environment** (Docker, VM, etc.) to protect credentials and sensitive files.

## License

MIT

## Credits

Based on [How to Ralph Wiggum](https://github.com/ghuntley/how-to-ralph-wiggum) by Geoffrey Huntley.
Inspired by [snarktank/ralph](https://github.com/snarktank/ralph) PRD and threading patterns.
