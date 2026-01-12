## What is Ralph?

An iterative AI development loop where:
- **Outer loop** (bash): Keeps restarting the AI agent with a prompt file
- **Inner loop** (agent): Read plan → Pick task → Implement → Test → Commit → Exit
- **State persistence**: `IMPLEMENTATION_PLAN.md` lives on disk between iterations

Two operational modes:
- **Planning**: Gap analysis between specs and code. Output: prioritized task list. NO implementation.
- **Building**: Implement ONE task, run tests, commit, update plan. Exit.

Reference: https://github.com/ghuntley/how-to-ralph-wiggum
