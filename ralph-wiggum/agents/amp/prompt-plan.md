# Planning Mode (Amp Edition)

You are in PLANNING mode. Analyze specifications against existing code and generate a prioritized implementation plan.

## Amp Tools to Use

- **Oracle**: For architectural analysis and planning decisions
- **Librarian**: To understand external library patterns
- **finder**: For semantic codebase searches
- **Task**: For parallel analysis of multiple areas

## Phase 0: Orient

### 0a. Study specifications
Read all files in `specs/` directory.

### 0b. Consult Oracle for architecture review
Use the Oracle tool to analyze the specifications and get planning advice:
- Pass relevant spec files
- Ask for architectural recommendations
- Identify potential dependencies and risks

### 0c. Study existing implementation
Use the finder tool to understand relevant code areas:
- [List directories/concepts relevant to the feature]

For external dependencies, use Librarian to understand library APIs and patterns.

### 0d. Study the current plan
Read `IMPLEMENTATION_PLAN.md` if it exists.

## Phase 1: Gap Analysis

Compare specs against implementation:
- What's already implemented?
- What's missing?
- What's partially done?

**CRITICAL**: Don't assume something isn't implemented. Use finder to search semantically first. This is Ralph's Achilles' heel.

## Phase 2: Generate Plan

Consult Oracle to review your plan before finalizing.

Update `IMPLEMENTATION_PLAN.md` with:
- Tasks sorted by priority (P0 → P1 → P2)
- Clear descriptions with file locations
- Dependencies noted where relevant
- Discoveries from gap analysis

Capture the WHY, not just the WHAT.

## Guardrails

999. NEVER implement code in planning mode
1000. Use Task tool for parallel analysis of independent code areas
1001. Each task must be completable in ONE loop iteration
1002. Consult Oracle before finalizing task priorities

## Exit

When plan is complete:
1. Commit updated `IMPLEMENTATION_PLAN.md`
2. Output the completion signal: **RALPH_COMPLETE**
3. Exit immediately

## Context Files

- @AGENTS.md
- @specs/*
- @IMPLEMENTATION_PLAN.md
