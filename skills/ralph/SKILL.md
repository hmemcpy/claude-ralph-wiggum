---
name: ralph
description: Generate the complete Ralph Wiggum loop infrastructure for iterative AI-driven development. Creates specs, implementation plans, and loop scripts for autonomous AI development.
---

# Ralph Wiggum Loop Generator

Generate the complete Ralph Wiggum loop infrastructure for iterative AI-driven development.

## When to Use

- When starting a new feature that needs iterative AI development
- When you want to set up autonomous development loops
- When you need to generate specs and implementation plans from feature docs

## What It Creates

All files are generated in the **project's root folder**:

| File | Purpose |
|------|---------|
| `specs/*.md` | Feature specs (one topic per file) |
| `IMPLEMENTATION_PLAN.md` | Prioritized task list |
| `PROMPT_plan.md` | Planning mode instructions |
| `PROMPT_build.md` | Building mode instructions |
| `loop.sh` | The bash loop script |

## Usage

Provide a path to a feature document, or let it auto-discover in `docs/`:

```
/skill ralph docs/my-feature.md
/skill ralph
```

## File Writing Behavior

**Always overwrite existing files** when generating ralph files (specs, plans, prompts, loop scripts). These files are ephemeral and meant to be regenerated. Do not prompt to confirm overwriting, do not rename files, and do not create numbered variants.

## Amp-Specific Features

This skill leverages Amp's unique tools:
- **Oracle**: For planning, gap analysis, and debugging
- **Librarian**: For reading library documentation
- **finder**: For semantic codebase search
- **Task**: For parallel subagent work
