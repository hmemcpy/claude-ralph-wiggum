## Generating `IMPLEMENTATION_PLAN.md`

```markdown
# [Feature Name] - Implementation Plan

Generated from specs. Tasks sorted by priority.

## Status Legend
- [ ] Not started
- [x] Completed
- [~] In progress
- [!] Blocked

---

## Phase 1: [Phase Name] (P0)

### Task 1: [Descriptive task name]
- **File**: `path/to/file.ext` (new) or (modify)
- **Description**: One sentence
- **Details**:
  - Specific implementation detail
  - Another detail
- [ ] Not started

### Task 2: ...

---

## Phase 2: [Phase Name] (P1)
...

---

## Discovered Tasks

(Tasks discovered during implementation go here)

---

## Completed Tasks

(Move completed tasks here with brief notes)

---

## Notes

- One task per loop iteration
- Search before implementing
```

**Priority**:
- P0: Core functionality (feature doesn't work without this)
- P1: Important (significantly improves feature)
- P2: Polish (nice-to-have, accessibility, edge cases)

**Task Sizing**: Each task completable in ONE loop iteration. If too big, split it.
