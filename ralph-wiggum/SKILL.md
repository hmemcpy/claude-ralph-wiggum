# Ralph Wiggum Loop Generator

Generate the complete Ralph Wiggum loop infrastructure for iterative AI-driven development.

## Description

Creates specs, implementation plans, and loop scripts for autonomous AI development using the Ralph Wiggum methodology. Supports multiple AI agents (Claude Code, Amp) with agent-specific optimizations.

## When to Use

- When starting a new feature that needs iterative AI development
- When you want to set up autonomous development loops
- When you need to generate specs and implementation plans from feature docs

## Supported Agents

- **Claude Code**: Uses parallel subagents, Opus for complex reasoning
- **Amp**: Uses Oracle for planning/debugging, Librarian for library docs, finder for semantic search

## Arguments

Optional path to a feature/UX document. If not provided, searches `docs/` directory.

## Example Usage

```
/skill ralph docs/my-feature.md
/skill ralph
```
