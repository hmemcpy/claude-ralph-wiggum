## Execution Checklist

All generated files should be placed in the **project's root folder**.

1. [ ] Read project context (AGENTS.md/CLAUDE.md, package.json/Cargo.toml/etc.)
2. [ ] Read feature doc from argument or find in docs/
3. [ ] Remove old specs if they belong to a different feature
4. [ ] Generate new specs in `specs/` (one topic per file, passes "one sentence" test)
5. [ ] Generate `IMPLEMENTATION_PLAN.md` in project root with prioritized tasks
6. [ ] Generate `PROMPT_plan.md` in project root (customize for agent and directories)
7. [ ] Generate `PROMPT_build.md` in project root (set correct validation command)
8. [ ] Generate `loop.sh` in project root (agent-specific CLI invocation)
9. [ ] Run `chmod +x loop.sh`
10. [ ] Verify all files created in project root

## Final Notes

- **Sandbox Warning**: Ralph runs autonomously. Run in Docker/sandbox to protect credentials.
- **Tuning**: Observe early loops. When Ralph fails consistently, add guardrails to prompts.
- **Regenerate**: If plan goes off-track, delete and regenerate. One planning loop is cheap.
- **Let Ralph Ralph**: Don't over-specify. Agent determines approach.
