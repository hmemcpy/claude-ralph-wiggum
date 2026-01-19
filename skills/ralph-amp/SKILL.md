---
name: ralph-amp
description: Interactive planning skill for Amp. Generates specs, implementation plans, and loop infrastructure through clarifying questions.
allowed-tools:
  - "*"
---

# Ralph Planning Skill (Amp)

Generate specs, implementation plans, and loop infrastructure for iterative AI-driven development.

## Entry

**Usage:** `/skill ralph-amp [optional/path/to/plan.md]`

- If path provided: Read that `.md` file as the source specification
- If no path: Use the current conversation context

---

## Step 1: Interview the User

You MUST ask clarifying questions before generating any files. Present questions with lettered options for quick responses.

**Interview approach:**
1. Present 3-5 questions covering scope, constraints, and validation
2. Use A/B/C/D multiple choice format for quick answers
3. Allow the user to respond with shorthand like "1A, 2C, 3B"
4. Ask follow-up questions if answers are unclear

**Example interview:**

> I'll help you plan this feature. First, let me ask a few questions:
>
> **1. Scope** - How broad is this change?
> - A) Single file/module
> - B) Multiple related files  
> - C) Cross-cutting (many parts of codebase)
> - D) Greenfield (new feature from scratch)
>
> **2. Risk tolerance** - How aggressive should changes be?
> - A) Conservative - minimal changes
> - B) Balanced - reasonable refactoring OK
> - C) Aggressive - significant refactoring acceptable
>
> **3. Validation** - How should we verify the implementation?
> - A) Existing test suite
> - B) Add new tests
> - C) Manual testing sufficient
>
> Reply with your choices (e.g., "1B, 2A, 3B") or answer in your own words.

**WAIT for user response before proceeding.**

---

## Step 2: Oracle Review (Optional)

After receiving answers, offer to analyze the codebase:

> Would you like me to analyze the codebase architecture before generating the plan?
> - Reply **oracle** for architectural analysis
> - Reply **skip** to proceed directly

### If user chooses `oracle`:
1. Use the Oracle tool to analyze relevant code areas
2. Identify existing patterns, potential conflicts, dependencies
3. Present findings and any additional clarifying questions
4. **WAIT for user response before proceeding**

### If user chooses `skip`:
Proceed directly to Step 3.

---

## Step 3: Generate Files

**Always overwrite existing files** — never add suffixes like `-v2`, `-new`, or `_backup`. These files are ephemeral and meant to be regenerated. Use the exact filenames specified below.

### 1. `specs/<feature-slug>.md`

Requirements specification containing:
- Feature overview
- User stories
- Acceptance criteria
- Edge cases and error handling
- Out of scope items

### 2. `IMPLEMENTATION_PLAN.md`

Format:
```markdown
# Implementation Plan: <Feature Name>

> **Scope**: <scope choice> | **Risk**: <risk choice> | **Constraints**: <constraint choice>

## Summary

<2-3 sentence overview of the implementation approach>

## Tasks

- [ ] Task 1: Description with enough context for implementation
- [ ] Task 2: Description with enough context for implementation
- [ ] Task 3: Description with enough context for implementation
...
```

Tasks should be:
- Ordered by priority/dependency
- Small enough for single iteration
- Include file paths when known
- Self-contained with sufficient context

### 3. `PROMPT.md`

Generate with this exact content (replace `[VALIDATION_COMMAND]` with the appropriate command from AGENTS.md or project config):

```markdown
# Ralph Build Mode

Implement ONE task from the plan, validate, commit, exit.

## Phase 0: Orient

Study:
- @AGENTS.md (how to build/test)
- @specs/* (requirements)
- @IMPLEMENTATION_PLAN.md (current state)

### Check for completion

```bash
grep -c "^\- \[ \]" IMPLEMENTATION_PLAN.md || echo 0
```

- If 0: Run validation → commit → output **RALPH_COMPLETE** → exit
- If > 0: Continue to Phase 1

## Phase 1: Implement

1. **Study the plan** — Choose the most important task from @IMPLEMENTATION_PLAN.md
2. **Search first** — Don't assume not implemented. Use finder to verify behavior doesn't already exist
3. **Implement** — ONE task only. Implement completely — no placeholders or stubs
4. **Validate** — Run `[VALIDATION_COMMAND]`, must pass before continuing

If stuck, use Oracle to debug. Add extra logging if needed.

## Phase 2: Update & Learn

**Update IMPLEMENTATION_PLAN.md:**
- Mark task `- [x] Completed`
- Add discovered bugs or issues (even if unrelated to current task)
- Note any new tasks discovered
- Periodically clean out completed items when file gets large

**Update AGENTS.md** (if you learned something new):
- Add correct commands discovered through trial and error
- Keep it brief and operational only — no status updates or progress notes

## Phase 3: Commit & Exit

```bash
git add -A && git commit -m "feat([scope]): [description]

Thread: $AMP_THREAD_URL"
```

Check remaining:
```bash
grep -c "^\- \[ \]" IMPLEMENTATION_PLAN.md || echo 0
```

- If > 0: Say "X tasks remaining" and EXIT
- If = 0: Output **RALPH_COMPLETE**

## Guardrails

99999. When authoring documentation, capture the why — tests and implementation importance.
999999. Single sources of truth, no migrations/adapters. If tests unrelated to your work fail, resolve them as part of the increment.
9999999. Implement functionality completely. Placeholders and stubs waste time redoing the same work.
99999999. Keep @IMPLEMENTATION_PLAN.md current with learnings — future iterations depend on this to avoid duplicating efforts.
999999999. Keep @AGENTS.md operational only — status updates and progress notes pollute every future loop's context.
9999999999. For any bugs you notice, resolve them or document them in @IMPLEMENTATION_PLAN.md even if unrelated to current work.
99999999999. ONE task per iteration. Search before implementing. Validation MUST pass. Never output RALPH_COMPLETE if tasks remain.
```

### 4. `loop.sh`

Generate with this content (replace `[FEATURE_NAME]` with a short kebab-case feature name like `auth-system` or `api-refactor`):

```bash
#!/bin/bash

# Ralph Wiggum Build Loop (Amp)
# Runs build iterations until RALPH_COMPLETE

set -e

FEATURE_NAME="[FEATURE_NAME]"
MAX_ITERATIONS=0
ITERATION=0
CONSECUTIVE_FAILURES=0
PARENT_THREAD_FILE=$(mktemp)

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

for arg in "$@"; do
  if [[ "$arg" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=$arg
  fi
done

PROMPT_FILE="PROMPT.md"

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo -e "${RED}Error: $PROMPT_FILE not found${NC}"
  echo "Run the ralph skill first to generate the required files."
  exit 1
fi

cleanup() {
  rm -f "$PARENT_THREAD_FILE"
}
trap cleanup EXIT

seconds_until_next_hour() {
  local now=$(date +%s)
  local current_minute=$(date +%M)
  local current_second=$(date +%S)
  local seconds_past_hour=$((10#$current_minute * 60 + 10#$current_second))
  local seconds_until=$((3600 - seconds_past_hour))
  echo $seconds_until
}

seconds_until_daily_reset() {
  local reset_hour=5
  local now=$(date +%s)
  local today_reset=$(date -v${reset_hour}H -v0M -v0S +%s 2>/dev/null || date -d "today ${reset_hour}:00:00" +%s)

  if [[ $now -ge $today_reset ]]; then
    local tomorrow_reset=$((today_reset + 86400))
    echo $((tomorrow_reset - now))
  else
    echo $((today_reset - now))
  fi
}

countdown() {
  local seconds=$1
  local message=$2

  while [[ $seconds -gt 0 ]]; do
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "\r${CYAN}%s${NC} Time remaining: %02d:%02d:%02d " "$message" $hours $minutes $secs
    sleep 1
    ((seconds--))
  done
  printf "\r%-80s\r" " "
}

is_recoverable_error() {
  local output="$1"

  # Check JSON error field from stream-json output
  if [[ "$output" =~ \"error\":\"rate_limit\" ]]; then
    return 0
  fi
  if [[ "$output" =~ "You've hit your limit" ]]; then
    return 0
  fi
  if [[ "$output" =~ Error:\ 429 ]] || [[ "$output" =~ Error:\ 529 ]]; then
    return 0
  fi
  return 1
}

get_sleep_duration() {
  local output="$1"

  local json_reset=$(echo "$output" | grep -oE '"resetsAt"\s*:\s*"[^"]+"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  if [[ -n "$json_reset" ]]; then
    local reset_epoch=$(date -jf "%Y-%m-%dT%H:%M:%S%z" "$json_reset" +%s 2>/dev/null || \
                        date -d "$json_reset" +%s 2>/dev/null)
    if [[ -n "$reset_epoch" ]]; then
      local now=$(date +%s)
      local diff=$((reset_epoch - now))
      if [[ $diff -gt 0 ]]; then
        echo $((diff + 60))
        return
      fi
    fi
  fi

  if [[ "$output" =~ retry.after[[:space:]]*:?[[:space:]]*([0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
    return
  fi

  if [[ "$output" =~ "try again in "([0-9]+)" minute" ]]; then
    echo $(( ${BASH_REMATCH[1]} * 60 + 60 ))
    return
  fi

  if [[ "$output" =~ "try again in "([0-9]+)" hour" ]]; then
    echo $(( ${BASH_REMATCH[1]} * 3600 + 60 ))
    return
  fi

  if [[ "$output" =~ (daily|day|24.?hour) ]]; then
    seconds_until_daily_reset
    return
  fi

  # Parse "resets Xpm" or "resets Xam" with optional timezone
  if [[ "$output" =~ resets[[:space:]]+([0-9]+)(am|pm) ]]; then
    local reset_hour="${BASH_REMATCH[1]}"
    local ampm="${BASH_REMATCH[2]}"
    local tz="UTC"
    if [[ "$output" =~ \(([A-Za-z_/]+)\) ]]; then
      tz="${BASH_REMATCH[1]}"
    fi
    
    # Convert to 24-hour format
    if [[ "$ampm" == "pm" && "$reset_hour" -ne 12 ]]; then
      reset_hour=$((reset_hour + 12))
    elif [[ "$ampm" == "am" && "$reset_hour" -eq 12 ]]; then
      reset_hour=0
    fi
    
    local now=$(date +%s)
    local target=$(TZ="$tz" date -v${reset_hour}H -v0M -v0S +%s 2>/dev/null || TZ="$tz" date -d "today ${reset_hour}:00:00" +%s)
    
    if [[ $now -ge $target ]]; then
      target=$((target + 86400))
    fi
    
    echo $((target - now + 60))
    return
  fi

  echo 300
}

handle_recoverable_error() {
  local output="$1"
  local sleep_duration=$(get_sleep_duration "$output")

  echo ""
  echo -e "${YELLOW}=== Recoverable Error Detected ===${NC}"
  echo -e "${YELLOW}Waiting before retry...${NC}"
  echo ""

  local tz="UTC"
  if [[ "$output" =~ \(([A-Za-z_/]+)\) ]]; then
    tz="${BASH_REMATCH[1]}"
  fi
  local resume_time=$(TZ="$tz" date -v+${sleep_duration}S "+%Y-%m-%d %H:%M:%S" 2>/dev/null || TZ="$tz" date -d "+${sleep_duration} seconds" "+%Y-%m-%d %H:%M:%S")
  echo -e "Expected resume: ${CYAN}${resume_time}${NC}"
  echo ""

  countdown $sleep_duration "Waiting..."

  echo ""
  echo -e "${GREEN}Resuming...${NC}"
  echo ""

  CONSECUTIVE_FAILURES=0
}

echo -e "${GREEN}Ralph Build Loop (Amp)${NC}"
[[ $MAX_ITERATIONS -gt 0 ]] && echo "Max iterations: $MAX_ITERATIONS"
echo "Press Ctrl+C to stop"
echo "---"

while true; do
  ITERATION=$((ITERATION + 1))
  echo ""
  echo -e "${GREEN}=== Build Iteration $ITERATION ===${NC}"
  echo ""

  TEMP_OUTPUT=$(mktemp)
  PARENT_THREAD=$(cat "$PARENT_THREAD_FILE" 2>/dev/null || true)
  set +e

  if [[ -n "$PARENT_THREAD" ]]; then
    # Create child thread via handoff from parent
    echo -e "${CYAN}Creating handoff from parent ${PARENT_THREAD}...${NC}"
    
    cat "$PROMPT_FILE" | amp threads handoff "$PARENT_THREAD" \
      --goal "$(cat "$PROMPT_FILE")" \
      -x \
      --dangerously-allow-all \
      --stream-json > "$TEMP_OUTPUT" 2>&1
  else
    # First iteration: create parent thread
    amp -x --dangerously-allow-all --stream-json < "$PROMPT_FILE" > "$TEMP_OUTPUT" 2>&1
  fi

  # Extract thread ID from JSON output
  THREAD_ID=$(jq -r 'select(.type == "system") | .session_id' "$TEMP_OUTPUT" 2>/dev/null | head -1)

  # Display progress
  cat "$TEMP_OUTPUT" | jq -r '
      def tool_info:
        if .name == "edit_file" or .name == "create_file" or .name == "Read" then
          (.input.path | split("/") | last | .[0:60])
        elif .name == "todo_write" then
          ((.input.todos // []) | map(.content) | join(", ") | if contains("\n") then .[0:60] else . end)
        elif .name == "Bash" then
          (.input.cmd | if contains("\n") then split("\n") | first | .[0:50] else .[0:80] end)
        elif .name == "Grep" then
          (.input.pattern | .[0:40])
        elif .name == "glob" then
          (.input.filePattern | .[0:40])
        elif .name == "finder" then
          (.input.query | if contains("\n") then .[0:40] else . end)
        elif .name == "oracle" then
          (.input.task | if contains("\n") then .[0:40] else .[0:80] end)
        elif .name == "Task" then
          (.input.description // .input.prompt | if contains("\n") then .[0:40] else .[0:80] end)
        else null end;
      if .type == "assistant" then
        .message.content[] |
        if .type == "text" then
          if (.text | split("\n") | length) <= 3 then .text else empty end
        elif .type == "tool_use" then
          "    [" + .name + "]" + (tool_info | if . then " " + . else "" end)
        else empty end
      elif .type == "result" then
        "--- " + ((.duration_ms / 1000 * 10 | floor / 10) | tostring) + "s, " + (.num_turns | tostring) + " turns ---"
      else empty end
    ' 2>/dev/null

  EXIT_CODE=$?
  OUTPUT=$(cat "$TEMP_OUTPUT")
  RESULT_MSG=$(jq -r 'select(.type == "result") | .result // empty' "$TEMP_OUTPUT" 2>/dev/null | tail -1)
  rm -f "$TEMP_OUTPUT"
  set -e

  # Name/rename thread
  if [[ -n "$THREAD_ID" ]]; then
    if [[ -z "$PARENT_THREAD" ]]; then
      # First iteration: save as parent, name it
      echo "$THREAD_ID" > "$PARENT_THREAD_FILE"
      amp threads rename "$THREAD_ID" "ralph: ${FEATURE_NAME} (parent)" 2>/dev/null || true
      echo -e "${CYAN}Parent thread: $THREAD_ID${NC}"
    else
      # Child iteration: name it
      amp threads rename "$THREAD_ID" "ralph: ${FEATURE_NAME} #${ITERATION}" 2>/dev/null || true
      echo -e "${CYAN}Child thread: $THREAD_ID${NC}"
    fi
  fi

  if is_recoverable_error "$OUTPUT" "$EXIT_CODE"; then
    handle_recoverable_error "$OUTPUT"
    ITERATION=$((ITERATION - 1))
    continue
  fi

  if [[ $EXIT_CODE -ne 0 ]]; then
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    echo ""
    echo -e "${RED}=== Error (exit code: $EXIT_CODE) ===${NC}"

    # Exponential backoff: 30s, 60s, 120s, 240s, max 300s (5min)
    BACKOFF=$((30 * (2 ** (CONSECUTIVE_FAILURES - 1))))
    [[ $BACKOFF -gt 300 ]] && BACKOFF=300

    echo -e "${YELLOW}Retrying in ${BACKOFF}s... (consecutive failures: $CONSECUTIVE_FAILURES)${NC}"
    countdown $BACKOFF "Waiting..."
    ITERATION=$((ITERATION - 1))
    continue
  fi

  CONSECUTIVE_FAILURES=0

  if [[ "$RESULT_MSG" =~ "RALPH_COMPLETE" ]]; then
    echo ""
    echo -e "${GREEN}=== Ralph Complete ===${NC}"
    echo -e "${GREEN}All tasks finished.${NC}"
    break
  fi

  if [[ $MAX_ITERATIONS -gt 0 && $ITERATION -ge $MAX_ITERATIONS ]]; then
    echo ""
    echo -e "${GREEN}Reached max iterations ($MAX_ITERATIONS).${NC}"
    break
  fi

  sleep 2
done

echo ""
echo -e "${GREEN}Ralph loop complete. Iterations: $ITERATION${NC}"
```

Make the script executable:
```bash
chmod +x loop.sh
```

---

## End: Next Steps

After generating all files, tell the user:

> **Files generated:**
> - `specs/<feature-slug>.md` - Requirements specification
> - `IMPLEMENTATION_PLAN.md` - Task list with checkboxes
> - `PROMPT.md` - Build mode instructions
> - `loop.sh` - Build loop script
>
> **Thread organization:**
> - First iteration creates parent thread: `ralph: <feature-name> (parent)`
> - Subsequent iterations use `amp threads handoff` to create linked children
> - Child threads named: `ralph: <feature-name> #N`
> - View thread hierarchy at https://ampcode.com/threads
>
> **Next step:** Run `./loop.sh` to start the build loop.
