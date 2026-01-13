#!/bin/bash
# guard-story-exists.sh - Block commits without associated story (if using backlog)
# This hook runs on PreToolUse for Bash(git commit:*)
# Adapts to repo-specific conventions
# Exit 2 = blocking, Exit 0 = allowed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

input=$(cat)

# Only block git commit commands
command=$(echo "$input" | jq -r '.tool_input.command // empty')
if [[ ! "$command" =~ ^git\ commit ]]; then
  exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "")
[[ -z "$branch" ]] && exit 0

# === Load repo config ===
get_config() {
  if [[ -x "$SCRIPT_DIR/get-repo-config.sh" ]]; then
    "$SCRIPT_DIR/get-repo-config.sh" 2>/dev/null || echo '{}'
  else
    echo '{}'
  fi
}

CONFIG=$(get_config)
SOURCE=$(echo "$CONFIG" | jq -r '.source // "fallback"')

# If no backlog directory exists, this project doesn't use story tracking - allow all
if [[ ! -d "$PROJECT_DIR/docs/backlog" ]]; then
  exit 0
fi

# Get config values
MAIN_BRANCH=$(echo "$CONFIG" | jq -r '.main_branch // "main"')
NON_MERGEABLE=$(echo "$CONFIG" | jq -r '.non_mergeable // [] | .[]' 2>/dev/null || echo "")
TICKET_PATTERN=$(echo "$CONFIG" | jq -r '.ticket_pattern // "none"')

# === Helper: Check if branch matches pattern ===
matches_pattern() {
  local branch="$1"
  local pattern="$2"
  local regex=$(echo "$pattern" | sed 's/\*/.*/')
  [[ "$branch" =~ ^$regex$ ]]
}

# Exempt main/protected branches
if [[ "$branch" == "$MAIN_BRANCH" ]] || [[ "$branch" == "main" ]] || [[ "$branch" == "master" ]] || [[ "$branch" == "develop" ]]; then
  exit 0
fi

# Exempt non-mergeable branches (poc, vibe, experiment, etc.)
while IFS= read -r pattern; do
  [[ -z "$pattern" ]] && continue
  if matches_pattern "$branch" "$pattern"; then
    exit 0
  fi
done <<< "$NON_MERGEABLE"

# === Extract ticket number based on repo's ticket pattern ===
ticket_num=""

case "$TICKET_PATTERN" in
  "#NUMBER")
    # Expect branch like feature/#42-desc or feat/42-desc
    if [[ "$branch" =~ [/#]([0-9]+) ]]; then
      ticket_num="${BASH_REMATCH[1]}"
    fi
    ;;
  "JIRA")
    # Expect branch like feature/PROJ-42-desc
    if [[ "$branch" =~ ([A-Z]+-[0-9]+) ]]; then
      ticket_num="${BASH_REMATCH[1]}"
    fi
    ;;
  "BRACKETS")
    # Expect branch like feature/[42]-desc
    if [[ "$branch" =~ \[([0-9]+)\] ]]; then
      ticket_num="${BASH_REMATCH[1]}"
    fi
    ;;
  *)
    # Try common patterns
    if [[ "$branch" =~ [/#]([0-9]+) ]]; then
      ticket_num="${BASH_REMATCH[1]}"
    elif [[ "$branch" =~ ([A-Z]+-[0-9]+) ]]; then
      ticket_num="${BASH_REMATCH[1]}"
    fi
    ;;
esac

# If we found a ticket number, check for story
if [[ -n "$ticket_num" ]]; then
  if find "$PROJECT_DIR/docs/backlog" -name "*${ticket_num}*" 2>/dev/null | grep -q .; then
    exit 0
  fi
  # Story not found - BLOCK
  echo "❌ BLOCKED: No story found for ticket ${ticket_num}" >&2
  echo "" >&2
  echo "Create the story first: /story \"description\"" >&2
  exit 2
fi

# No ticket in branch name - check if repo requires tickets
if [[ "$SOURCE" == "configured" ]] || [[ "$SOURCE" == "plugin_defaults" ]]; then
  # Configured repos expect ticket references
  echo "❌ BLOCKED: Commit on branch without ticket reference" >&2
  echo "" >&2
  echo "Branch '$branch' doesn't include a ticket reference." >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  1. Create a story: /story \"description\"" >&2
  echo "  2. Work on a ticket: /work #XX" >&2
  echo "  3. Use an exploration branch (poc/, vibe/, etc.)" >&2
  echo "" >&2
  exit 2
fi

# Auto-detected or fallback - be permissive
exit 0
