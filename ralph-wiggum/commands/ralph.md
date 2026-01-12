# Ralph Wiggum Loop Generator

Generate the complete Ralph Wiggum loop infrastructure for iterative AI-driven development.

Reference: https://github.com/ghuntley/how-to-ralph-wiggum

## Input

$ARGUMENTS

The argument should be a path to a feature/UX document, or a description of the feature to implement. If empty, search for relevant docs in `docs/` directory.

---

@../common/what-is-ralph.md

---

@../common/principles.md

---

## Agent Detection

Detect which AI agent is running this command:

**Amp Detection**:
- Check if `oracle`, `librarian`, or `finder` tools are available
- Check if running in Amp environment

**Claude Detection**:
- Check if running in Claude Code environment
- Check for `claude` CLI availability

**Default**: If unclear, ask the user which agent they're using.

Set `AGENT_TYPE` to either `amp` or `claude` based on detection.

---

## Your Task

Generate/regenerate the complete Ralph loop infrastructure:

---

### Step 1: Discover Project Context

Read these files to understand the project:
- `AGENTS.md` or `CLAUDE.md` - project rules and commands
- `package.json`, `Cargo.toml`, `go.mod`, or equivalent - determine build system
- Existing `specs/` if any - understand current state

Extract:
- **Validation command** (e.g., `bun run check`, `npm test`, `cargo test`, `go test ./...`)
- **Code patterns** to follow
- **Path conventions** (imports, structure)

---

### Step 2: Generate Specs (`specs/*.md`)

@../common/spec-format.md

---

### Step 3: Generate `IMPLEMENTATION_PLAN.md`

@../common/plan-format.md

---

### Step 4: Generate `PROMPT_plan.md`

Based on `AGENT_TYPE`, use the appropriate template:

**For Amp** (`AGENT_TYPE=amp`):
@../agents/amp/prompt-plan.md

**For Claude** (`AGENT_TYPE=claude`):
@../agents/claude/prompt-plan.md

Customize the template:
- Replace `[List directories relevant to the feature]` with actual directories
- Keep all other instructions as-is

---

### Step 5: Generate `PROMPT_build.md`

Based on `AGENT_TYPE`, use the appropriate template:

**For Amp** (`AGENT_TYPE=amp`):
@../agents/amp/prompt-build.md

**For Claude** (`AGENT_TYPE=claude`):
@../agents/claude/prompt-build.md

Customize the template:
- Replace `[VALIDATION_COMMAND]` with the actual validation command from Step 1
- Keep all other instructions as-is

---

### Step 6: Generate `loop.sh`

Based on `AGENT_TYPE`, use the appropriate loop script:

**For Amp** (`AGENT_TYPE=amp`):
@../agents/amp/loop.sh

**For Claude** (`AGENT_TYPE=claude`):
@../agents/claude/loop.sh

Write the script to `loop.sh` in the project root.

---

### Step 7: Make Executable

Run: `chmod +x loop.sh`

---

@../common/checklist.md

---

## Agent-Specific Tool Guidance

Based on detected agent, include appropriate tool guidance:

**For Amp**:
@../agents/amp/tools.md

**For Claude**:
@../agents/claude/tools.md
