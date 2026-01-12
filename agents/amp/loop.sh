#!/bin/bash

# Ralph Wiggum Loop (Amp Edition)
# Reference: https://github.com/ghuntley/how-to-ralph-wiggum
#
# Features:
#   - Uses Amp CLI with --execute and --stream-json
#   - Automatic error detection and recovery
#   - Graceful retry after rate limits
#
# Usage:
#   ./loop.sh           # Auto mode: plan first, then build (default)
#   ./loop.sh plan      # Planning mode only
#   ./loop.sh build     # Build mode only
#   ./loop.sh 10        # Auto mode, max 10 build iterations
#   ./loop.sh build 5   # Build mode, max 5 iterations

set -e

MODE="plan"
AUTO_MODE=true
MAX_ITERATIONS=0
MAX_PLAN_ITERATIONS=3
ITERATION=0
CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=3

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

for arg in "$@"; do
  if [[ "$arg" == "plan" ]]; then
    MODE="plan"
    AUTO_MODE=false
  elif [[ "$arg" == "build" ]]; then
    MODE="build"
    AUTO_MODE=false
  elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=$arg
  fi
done

PROMPT_FILE="PROMPT_${MODE}.md"

# Check if prompt file exists
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo -e "${RED}Error: $PROMPT_FILE not found${NC}"
  echo "Run the ralph skill first to generate the required files."
  exit 1
fi

# Function to switch from plan to build mode
switch_to_build_mode() {
  echo ""
  echo -e "${CYAN}=== Switching to Build Mode ===${NC}"
  echo ""
  MODE="build"
  PROMPT_FILE="PROMPT_${MODE}.md"
  ITERATION=0  # Reset iteration counter for build phase
}

# Calculate seconds until next hour boundary
seconds_until_next_hour() {
  local now=$(date +%s)
  local current_minute=$(date +%M)
  local current_second=$(date +%S)
  local seconds_past_hour=$((10#$current_minute * 60 + 10#$current_second))
  local seconds_until=$((3600 - seconds_past_hour))
  echo $seconds_until
}

# Calculate seconds until specific reset time (e.g., midnight UTC, 5am local)
seconds_until_daily_reset() {
  # Assuming daily reset at 5:00 AM local time (adjust as needed)
  local reset_hour=5
  local now=$(date +%s)
  local today_reset=$(date -v${reset_hour}H -v0M -v0S +%s 2>/dev/null || date -d "today ${reset_hour}:00:00" +%s)

  if [[ $now -ge $today_reset ]]; then
    # Reset already passed today, calculate for tomorrow
    local tomorrow_reset=$((today_reset + 86400))
    echo $((tomorrow_reset - now))
  else
    echo $((today_reset - now))
  fi
}

# Display countdown timer
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
  printf "\r%-80s\r" " "  # Clear the line
}

# Check if error indicates recoverable error (currently disabled for Amp)
is_recoverable_error() {
  return 1
}

# Determine sleep duration based on error type
get_sleep_duration() {
  local output="$1"

  # Try to extract reset time from JSON payload (resetsAt field)
  local json_reset=$(echo "$output" | grep -oE '"resetsAt"\s*:\s*"[^"]+"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  if [[ -n "$json_reset" ]]; then
    local reset_epoch=$(date -jf "%Y-%m-%dT%H:%M:%S%z" "$json_reset" +%s 2>/dev/null || \
                        date -d "$json_reset" +%s 2>/dev/null)
    if [[ -n "$reset_epoch" ]]; then
      local now=$(date +%s)
      local diff=$((reset_epoch - now))
      if [[ $diff -gt 0 ]]; then
        echo $((diff + 60))  # Add 1 minute buffer
        return
      fi
    fi
  fi

  # Try to extract retry-after from output
  if [[ "$output" =~ retry.after[[:space:]]*:?[[:space:]]*([0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
    return
  fi

  # Try "try again in X minutes/hours"
  if [[ "$output" =~ "try again in "([0-9]+)" minute" ]]; then
    echo $(( ${BASH_REMATCH[1]} * 60 + 60 ))
    return
  fi

  if [[ "$output" =~ "try again in "([0-9]+)" hour" ]]; then
    echo $(( ${BASH_REMATCH[1]} * 3600 + 60 ))
    return
  fi

  # Check for daily limit
  if [[ "$output" =~ (daily|day|24.?hour) ]]; then
    seconds_until_daily_reset
    return
  fi

  # Default: wait 5 minutes
  echo 300
}

# Handle recoverable error
handle_recoverable_error() {
  local output="$1"
  local sleep_duration=$(get_sleep_duration "$output")

  echo ""
  echo -e "${YELLOW}=== Recoverable Error Detected ===${NC}"
  echo -e "${YELLOW}Waiting before retry...${NC}"
  echo ""

  local resume_time=$(date -v+${sleep_duration}S "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -d "+${sleep_duration} seconds" "+%Y-%m-%d %H:%M:%S")
  echo -e "Expected resume: ${CYAN}${resume_time}${NC}"
  echo ""

  countdown $sleep_duration "Waiting..."

  echo ""
  echo -e "${GREEN}Resuming...${NC}"
  echo ""

  CONSECUTIVE_FAILURES=0
}

if [[ "$AUTO_MODE" == true ]]; then
  echo -e "${GREEN}Ralph loop (Amp): AUTO mode (plan → build)${NC}"
  [[ $MAX_ITERATIONS -gt 0 ]] && echo "Max build iterations: $MAX_ITERATIONS"
else
  echo -e "${GREEN}Ralph loop (Amp): $(echo "$MODE" | tr '[:lower:]' '[:upper:]') mode${NC}"
  [[ $MAX_ITERATIONS -gt 0 ]] && echo "Max iterations: $MAX_ITERATIONS"
fi
echo "Press Ctrl+C to stop"
echo "---"

while true; do
  ITERATION=$((ITERATION + 1))
  echo ""
  MODE_DISPLAY=$(echo "$MODE" | tr '[:lower:]' '[:upper:]')
  if [[ "$AUTO_MODE" == true ]]; then
    echo -e "${GREEN}=== ${MODE_DISPLAY} Iteration $ITERATION ===${NC}"
  else
    echo -e "${GREEN}=== Iteration $ITERATION ===${NC}"
  fi
  echo ""

  TEMP_OUTPUT=$(mktemp)
  set +e

  # Run Amp in execute mode with stream-json output
  # -x: non-interactive execute mode
  # --stream-json: output in Claude Code-compatible stream JSON format
  # --dangerously-allow-all: auto-approve tool calls
  amp -x \
    --dangerously-allow-all \
    --stream-json \
    < "$PROMPT_FILE" 2>&1 | tee "$TEMP_OUTPUT" | jq -r '
      def tool_info:
        if .name == "edit_file" or .name == "create_file" or .name == "Read" then
          (.input.path | split("/") | last | .[0:40])
        elif .name == "todo_write" then
          ((.input.todos // []) | map(.content) | join(", ") | .[0:60])
        elif .name == "Bash" then
          (.input.cmd | split("\n") | first | .[0:50])
        elif .name == "Grep" then
          (.input.pattern | .[0:30])
        elif .name == "glob" then
          (.input.filePattern | .[0:30])
        elif .name == "finder" then
          (.input.query | .[0:40])
        elif .name == "oracle" then
          (.input.task | .[0:40])
        elif .name == "Task" then
          (.input.description // .input.prompt | .[0:40])
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
  rm -f "$TEMP_OUTPUT"
  set -e

  # Check for recoverable errors
  if is_recoverable_error "$OUTPUT" "$EXIT_CODE"; then
    handle_recoverable_error "$OUTPUT"
    ITERATION=$((ITERATION - 1))
    continue
  fi

  # Check for other errors
  if [[ $EXIT_CODE -ne 0 ]]; then
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    echo ""
    echo -e "${RED}=== Error (exit code: $EXIT_CODE) ===${NC}"

    if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
      echo -e "${RED}Too many consecutive failures ($CONSECUTIVE_FAILURES). Stopping.${NC}"
      exit 1
    fi

    echo -e "${YELLOW}Retrying in 30 seconds... (failure $CONSECUTIVE_FAILURES/$MAX_CONSECUTIVE_FAILURES)${NC}"
    sleep 30
    ITERATION=$((ITERATION - 1))
    continue
  fi

  CONSECUTIVE_FAILURES=0

  # Check for completion signal
  if [[ "$OUTPUT" =~ "RALPH_COMPLETE" ]]; then
    echo ""
    echo -e "${GREEN}=== Ralph Complete ===${NC}"
    echo -e "${GREEN}Amp has signaled that the ${MODE} loop is finished.${NC}"

    if [[ "$AUTO_MODE" == true && "$MODE" == "plan" ]]; then
      switch_to_build_mode
      continue
    fi
    break
  fi

  # Max iterations check
  if [[ "$MODE" == "plan" && $ITERATION -ge $MAX_PLAN_ITERATIONS ]]; then
    echo ""
    echo -e "${YELLOW}Reached max plan iterations ($MAX_PLAN_ITERATIONS). Switching to build mode.${NC}"
    if [[ "$AUTO_MODE" == true ]]; then
      switch_to_build_mode
      continue
    fi
    break
  fi

  if [[ $MAX_ITERATIONS -gt 0 && $ITERATION -ge $MAX_ITERATIONS ]]; then
    if [[ "$AUTO_MODE" == true && "$MODE" == "plan" ]]; then
      switch_to_build_mode
      continue
    fi
    echo ""
    echo -e "${GREEN}Reached max iterations ($MAX_ITERATIONS).${NC}"
    break
  fi

  sleep 2
done

echo ""
echo -e "${GREEN}Ralph loop complete. Iterations: $ITERATION${NC}"
