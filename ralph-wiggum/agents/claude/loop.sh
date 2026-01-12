#!/bin/bash

# Ralph Wiggum Loop (Claude Edition)
# Reference: https://github.com/ghuntley/how-to-ralph-wiggum
#
# Features:
#   - Automatic usage limit detection and recovery
#   - Sleep until reset with countdown
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
  echo "Run the ralph command first to generate the required files."
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

# Check if error indicates usage limit exceeded
is_usage_limit_error() {
  local output="$1"
  local exit_code="$2"

  # Check for Claude Max/Pro subscription limits
  if [[ "$output" =~ "You've hit your limit" ]]; then
    return 0
  fi

  # Check for API rate_limit_error
  if [[ "$output" =~ \"type\":\"rate_limit_error\" ]]; then
    return 0
  fi

  # Check for API overloaded_error (529 status)
  if [[ "$output" =~ \"type\":\"overloaded_error\" ]]; then
    return 0
  fi

  # Check for HTTP 429/529 status codes
  if [[ "$output" =~ Error:\ 429 ]] || [[ "$output" =~ Error:\ 529 ]]; then
    return 0
  fi

  return 1
}

# Determine sleep duration based on error type
get_sleep_duration() {
  local output="$1"

  # Try to extract reset time from JSON payload
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

  # Check for "resets Xam/pm (Timezone)" format
  if [[ "$output" =~ resets[[:space:]]+([0-9]+)(am|pm)[[:space:]]*\(([A-Za-z_/]+)\) ]]; then
    local hour="${BASH_REMATCH[1]}"
    local ampm="${BASH_REMATCH[2]}"
    local timezone="${BASH_REMATCH[3]}"

    if [[ "$ampm" == "pm" && "$hour" != "12" ]]; then
      hour=$((hour + 12))
    elif [[ "$ampm" == "am" && "$hour" == "12" ]]; then
      hour=0
    fi

    local now=$(date +%s)
    local today_date=$(TZ="$timezone" date +%Y-%m-%d)
    local reset_time=$(TZ="$timezone" date -jf "%Y-%m-%d %H:%M:%S" "$today_date $(printf '%02d' $hour):00:00" +%s 2>/dev/null || \
                       TZ="$timezone" date -d "$today_date $(printf '%02d' $hour):00:00" +%s 2>/dev/null)

    if [[ -n "$reset_time" ]]; then
      local diff=$((reset_time - now))
      if [[ $diff -lt 0 ]]; then
        diff=$((diff + 86400))
      fi
      echo $((diff + 60))
      return
    fi
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

  # Default: wait until next hour boundary + 1 minute buffer
  local wait_time=$(seconds_until_next_hour)
  echo $((wait_time + 60))
}

# Handle usage limit - sleep and retry
handle_usage_limit() {
  local output="$1"
  local sleep_duration=$(get_sleep_duration "$output")

  echo ""
  echo -e "${YELLOW}=== Usage Limit Detected ===${NC}"
  echo -e "${YELLOW}Claude usage limit exceeded. Waiting for reset...${NC}"
  echo ""

  local resume_time=$(date -v+${sleep_duration}S "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -d "+${sleep_duration} seconds" "+%Y-%m-%d %H:%M:%S")
  echo -e "Expected resume: ${CYAN}${resume_time}${NC}"
  echo ""

  countdown $sleep_duration "Waiting for usage reset..."

  echo ""
  echo -e "${GREEN}Usage limit should be reset. Resuming...${NC}"
  echo ""

  CONSECUTIVE_FAILURES=0
}

if [[ "$AUTO_MODE" == true ]]; then
  echo -e "${GREEN}Ralph loop (Claude): AUTO mode (plan → build)${NC}"
  [[ $MAX_ITERATIONS -gt 0 ]] && echo "Max build iterations: $MAX_ITERATIONS"
else
  echo -e "${GREEN}Ralph loop (Claude): $(echo "$MODE" | tr '[:lower:]' '[:upper:]') mode${NC}"
  [[ $MAX_ITERATIONS -gt 0 ]] && echo "Max iterations: $MAX_ITERATIONS"
fi
echo "Press Ctrl+C to stop"
echo "---"

while true; do
  ITERATION=$((ITERATION + 1))
  echo ""
  if [[ "$AUTO_MODE" == true ]]; then
    echo -e "${GREEN}=== ${MODE^} Iteration $ITERATION ===${NC}"
  else
    echo -e "${GREEN}=== Iteration $ITERATION ===${NC}"
  fi
  echo ""

  TEMP_OUTPUT=$(mktemp)
  set +e

  claude -p \
    --dangerously-skip-permissions \
    --model opus \
    --output-format stream-json \
    <<< "$(cat "$PROMPT_FILE")" 2>&1 | tee "$TEMP_OUTPUT" | jq -r 'select(.type == "assistant") | .message.content[]?.text // empty' 2>/dev/null

  EXIT_CODE=$?
  OUTPUT=$(cat "$TEMP_OUTPUT")
  rm -f "$TEMP_OUTPUT"
  set -e

  # Check for usage limit errors
  if is_usage_limit_error "$OUTPUT" "$EXIT_CODE"; then
    handle_usage_limit "$OUTPUT"
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
    echo -e "${GREEN}Claude has signaled that the ${MODE} loop is finished.${NC}"

    if [[ "$AUTO_MODE" == true && "$MODE" == "plan" ]]; then
      switch_to_build_mode
      continue
    fi
    break
  fi

  # Max iterations check
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
