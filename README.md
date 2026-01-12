# Ralph Wiggum Loop - Multi-Agent Plugin

Generate the complete [Ralph Wiggum loop](https://github.com/ghuntley/how-to-ralph-wiggum) infrastructure for iterative AI-driven development. Supports multiple AI agents with agent-specific optimizations.

## What is Ralph?

An iterative AI development loop where a dumb bash script keeps restarting the AI agent, and the agent figures out what to do next by reading the plan file each time.

```
┌─────────────────────────────────────────────────────────┐
│                    OUTER LOOP (bash)                    │
│          while :; do $AGENT < PROMPT.md ; done          │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   INNER LOOP (agent)                    │
│   Read plan → Pick task → Implement → Test → Commit     │
└─────────────────────────────────────────────────────────┘
```

Two modes:
- **Planning**: Gap analysis. Output prioritized task list. No implementation.
- **Building**: Implement ONE task, validate, commit, exit. Repeat.

## Supported Agents

| Agent | CLI Command | Key Features |
|-------|-------------|--------------|
| **Claude Code** | `claude -p` | Parallel subagents, Opus reasoning, Ultrathink |
| **Amp** | `amp -x` | Oracle (planning/debug), Librarian (docs), finder (semantic search) |

The plugin auto-detects which agent is running and generates appropriate files.

## Installation

### Claude Code

#### Direct Install from GitHub
```bash
# In Claude Code interactive mode:
/plugin install https://github.com/hmemcpy/ralph-wiggum
```

#### Manual Installation (User-Global)
```bash
git clone https://github.com/hmemcpy/ralph-wiggum ~/.ralph-wiggum

# In Claude Code:
/plugin install ~/.ralph-wiggum --scope user
```

#### Manual Installation (Project-Local)
```bash
git clone https://github.com/hmemcpy/ralph-wiggum .ralph-wiggum

# In Claude Code:
/plugin install .ralph-wiggum --scope local
```

### Amp

#### Install from GitHub
```bash
# Install the ralph skill
amp skill add hmemcpy/ralph-wiggum/ralph
```

#### Manual Installation
```bash
# Clone to skills directory
git clone https://github.com/hmemcpy/ralph-wiggum ~/.config/agents/skills/ralph-wiggum
```

## Usage

### Claude Code
```bash
/ralph-wiggum:ralph docs/my-feature.md
/ralph-wiggum:ralph
```

### Amp
```bash
/skill ralph docs/my-feature.md
/skill ralph
```

The command generates all files in the **project's root folder**:

| File | Purpose |
|------|---------|
| `specs/*.md` | Feature specs (one topic per file) |
| `IMPLEMENTATION_PLAN.md` | Prioritized task list |
| `PROMPT_plan.md` | Planning mode instructions (agent-optimized) |
| `PROMPT_build.md` | Building mode instructions (agent-optimized) |
| `loop.sh` | The bash loop script (agent-specific CLI) |

## Running the Loop

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
./loop.sh build 5
```

## Loop Features

Both loop scripts include:

- **Auto mode**: Runs planning first, then switches to build mode automatically
- **Rate limit handling**: Detects API limits and waits with countdown timer
- **Error recovery**: Retries on transient failures (max 3 consecutive)
- **Plan iteration cap**: Maximum 3 planning iterations before switching to build
- **JSON streaming**: Uses `--stream-json` for structured output
- **Completion detection**: Exits when agent outputs `RALPH_COMPLETE`

## Agent-Specific Features

### Claude Code

- **Parallel subagents**: Up to 500 for searches/reads, 10 for analysis
- **Opus model**: Complex reasoning during implementation
- **Ultrathink**: Deep reasoning before finalizing priorities

### Amp

- **Oracle**: Architecture review, planning decisions, debugging
- **Librarian**: Read library documentation, understand APIs
- **finder**: Semantic codebase search (not just text matching)
- **Task**: Parallel subagent work for independent operations
- **todo_write**: Track progress within each iteration

## Core Principles

1. **Deterministic Setup** - Same files seed each loop
2. **One Task Per Iteration** - Maximize context for that task
3. **Backpressure** - Tests must pass before commit
4. **Plan Disposability** - Regenerate when off-track
5. **Search First** - Don't assume not implemented
6. **Let Ralph Ralph** - Agent determines approach

## Project Structure

```
ralph-wiggum/
├── .claude-plugin/
│   └── plugin.json         # Claude Code plugin manifest
├── commands/
│   └── ralph.md            # Main slash command (Claude Code)
├── skills/
│   └── ralph/
│       └── SKILL.md        # Amp skill definition
├── common/                 # Shared components
│   ├── what-is-ralph.md
│   ├── principles.md
│   ├── spec-format.md
│   ├── plan-format.md
│   └── checklist.md
├── agents/                 # Agent-specific templates
│   ├── claude/
│   │   ├── tools.md
│   │   ├── prompt-plan.md
│   │   ├── prompt-build.md
│   │   └── loop.sh
│   └── amp/
│       ├── tools.md
│       ├── prompt-plan.md
│       ├── prompt-build.md
│       └── loop.sh
├── SKILL.md                # Root skill (for compatibility)
├── install.sh              # Sync to local installations
└── README.md
```

## Adding Support for New Agents

1. Create a new directory under `agents/` (e.g., `agents/codex/`)
2. Add agent-specific files:
   - `tools.md` - Tool guidance for this agent
   - `prompt-plan.md` - Planning mode prompt template
   - `prompt-build.md` - Building mode prompt template
   - `loop.sh` - CLI-specific loop script
3. Update detection logic in `commands/ralph.md`

## Requirements

- An AI coding agent (Claude Code or Amp)
- A project with tests/linting (for backpressure)
- `jq` installed (for JSON output parsing)

## Security Warning

Ralph runs autonomously with permissions bypassed. **Always run in a sandboxed environment** (Docker, VM, etc.) to protect credentials and sensitive files.

## License

MIT

## Credits

Based on [How to Ralph Wiggum](https://github.com/ghuntley/how-to-ralph-wiggum) by Geoffrey Huntley.
