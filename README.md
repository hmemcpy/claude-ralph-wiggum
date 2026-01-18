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

1. **Planning** (interactive) — Skill/command interviews you with clarifying questions
2. **Building** (loop) — `./loop.sh` implements one task per iteration until complete

## Supported Agents

| Agent | CLI Command | Key Features |
|-------|-------------|--------------|
| **Amp** | `amp -x` | Oracle (planning/debug), Librarian (docs), finder (semantic search) |
| **Claude Code** | `claude -p` | Plan Mode, AskUserQuestion, Extended Thinking |

## Installation

```bash
git clone https://github.com/hmemcpy/ralph-wiggum
cd ralph-wiggum
./install.sh
```

This installs:
- **Claude Code**: Plugin to `~/.claude/plugins/`
- **Amp**: Skill to `~/.config/agents/skills/ralph-wiggum/`

Restart your agent for changes to take effect.

## Usage

### Amp

```bash
/skill ralph [optional/path/to/plan.md]
```

The skill will:
1. Interview you with clarifying questions (A/B/C/D format)
2. Optionally run Oracle for architectural review
3. Generate all files

### Claude Code

```bash
/ralph-wiggum:ralph [optional/path/to/plan.md]
```

The command will:
1. Use Plan Mode + `AskUserQuestion` to interview you
2. Optionally run `ultrathink` for deep analysis
3. Generate all files

### Generated Files

| File | Purpose |
|------|---------|
| `specs/<feature>.md` | Requirements, user stories, edge cases |
| `IMPLEMENTATION_PLAN.md` | Summary + prioritized task list |
| `PROMPT.md` | Build mode instructions |
| `loop.sh` | Build-only loop script |

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
- **Thread tracking**: Commits include thread URL for traceability
- **Completion detection**: Exits when agent outputs `RALPH_COMPLETE`

## Agent-Specific Features

### Amp
- **Oracle**: Architecture review, planning decisions, debugging
- **Librarian**: Read library documentation, understand APIs
- **finder**: Semantic codebase search (not just text matching)
- **Task**: Parallel subagent work for independent operations

### Claude Code
- **Plan Mode**: Read-only analysis with `AskUserQuestion` for requirements gathering
- **Extended Thinking**: Use `ultrathink` keyword for deep reasoning
- **Subagents**: Parallel analysis of code areas

## Core Principles

1. **Interactive Planning** - Clarifying questions before generation
2. **One Task Per Iteration** - Maximize context for that task
3. **Backpressure** - Validation must pass before commit
4. **Search First** - Don't assume functionality doesn't exist
5. **Let Ralph Ralph** - Agent determines approach

## Project Structure

```
ralph-wiggum/
├── .claude-plugin/         # Claude Code plugin manifest
├── commands/
│   └── ralph.md            # Claude Code command
├── skills/
│   └── ralph/
│       └── SKILL.md        # Amp skill
├── SKILL.md                # Root skill
├── install.sh              # Installer for both agents
└── README.md
```

## Requirements

- An AI coding agent (Amp or Claude Code)
- A project with tests/linting (for backpressure)

## Security Warning

Ralph runs autonomously with permissions bypassed. **Always run in a sandboxed environment** (Docker, VM, etc.) to protect credentials and sensitive files.

## License

MIT

## Credits

Based on [How to Ralph Wiggum](https://github.com/ghuntley/how-to-ralph-wiggum) by Geoffrey Huntley.
Inspired by [snarktank/ralph](https://github.com/snarktank/ralph) PRD and threading patterns.
