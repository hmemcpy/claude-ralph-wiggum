## Generating Specs (`specs/*.md`)

**Topic Scope Test**: Can you describe the topic in ONE sentence WITHOUT "and" for unrelated capabilities?
- PASS: "The effect system renders CSS filters on album art backgrounds"
- FAIL: "The user system handles authentication, profiles, and billing" → Split into 3 specs

**Spec Format** (let format evolve naturally, but include these sections):

```markdown
# [Topic Name]

## Overview
One sentence describing this topic of concern.

## Requirements

### [Requirement Group]
- Requirement detail
- Another requirement

### [Another Group]
...

## State Model (if applicable)
```typescript
interface State { ... }
```

## Files to Create/Modify
- `path/to/file.ext` - what changes

## Acceptance Criteria
- [ ] Observable, verifiable outcome 1
- [ ] Observable, verifiable outcome 2
```

**Naming**: `kebab-case-topic.md` (e.g., `image-edit-mode.md`, `effects-system.md`)

**Important**: Acceptance criteria define WHAT (behavioral outcomes), not HOW (implementation details).
