#!/bin/bash
# guard-branch-check.sh - Check git commands based on branch and repo conventions
# Adapts to repo-specific conventions from .claude/repos.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$command" ]] && exit 0

branch=$(git branch --show-current 2>/dev/null || echo "")

# === Load repo config ===
get_config() {
  if [[ -x "$SCRIPT_DIR/get-repo-config.sh" ]]; then
    "$SCRIPT_DIR/get-repo-config.sh" 2>/dev/null || echo '{}'
  else
    echo '{}'
  fi
}

CONFIG=$(get_config)
MAIN_BRANCH=$(echo "$CONFIG" | jq -r '.main_branch // "main"')
PROTECTED=$(echo "$CONFIG" | jq -r '.protected_branches // ["main", "master"] | .[]' 2>/dev/null || echo -e "main\nmaster")
NON_MERGEABLE=$(echo "$CONFIG" | jq -r '.non_mergeable // ["poc/*", "vibe/*"] | .[]' 2>/dev/null || echo -e "poc/*\nvibe/*")

# === Helper: Check if branch matches pattern ===
matches_pattern() {
  local branch="$1"
  local pattern="$2"
  # Convert glob pattern to regex
  local regex=$(echo "$pattern" | sed 's/\*/.*/')
  [[ "$branch" =~ ^$regex$ ]]
}

# === GUARD 1: Prevent merge of non-mergeable branches ===
if [[ "$command" =~ git[[:space:]]+merge ]]; then
  merge_source=$(echo "$command" | grep -oE 'merge[[:space:]]+[^[:space:]]+' | awk '{print $2}' || echo "")

  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if matches_pattern "$merge_source" "$pattern"; then
      echo "❌ BLOCKED: Branch '$merge_source' cannot be merged" >&2
      echo "" >&2
      echo "Branches matching '$pattern' are for exploration only." >&2
      echo "If successful, create a proper branch and reimplement." >&2
      echo "" >&2
      exit 2
    fi
  done <<< "$NON_MERGEABLE"
fi

# === GUARD 2: Prevent direct push to protected branches ===
if [[ "$command" =~ git[[:space:]]+push ]]; then
  is_protected=false

  while IFS= read -r protected_branch; do
    [[ -z "$protected_branch" ]] && continue
    if [[ "$branch" == "$protected_branch" ]]; then
      is_protected=true
      break
    fi
  done <<< "$PROTECTED"

  if [[ "$is_protected" == "true" ]]; then
    if [[ "$command" =~ --force ]] || [[ "$command" =~ -f[[:space:]] ]]; then
      echo "❌ BLOCKED: Force push to protected branch '$branch' is forbidden" >&2
      exit 2
    fi
    echo "⚠️ Warning: Direct push to '$branch'. Prefer using PRs." >&2
  fi
fi

# === GUARD 3: Check sprint lock (if using sprints) ===
if [[ "$command" =~ git[[:space:]]+commit ]]; then
  if [[ -d "$PROJECT_DIR/docs/sprints" ]]; then
    current_sprint=$(find "$PROJECT_DIR/docs/sprints" -name "SPRINT-*.md" -type f 2>/dev/null | sort -r | head -1)

    if [[ -n "$current_sprint" ]] && grep -q "Status: Locked" "$current_sprint" 2>/dev/null; then
      # Allow fix branches
      fix_pattern=$(echo "$CONFIG" | jq -r '.branch_patterns.fix // "fix/*"')
      if matches_pattern "$branch" "$fix_pattern"; then
        exit 0
      fi

      echo "⚠️ Sprint is locked - only fixes are allowed" >&2
      echo "Current branch: $branch" >&2
      echo "For an urgent fix, use a fix branch." >&2
    fi
  fi
fi

# === GUARD 4: Warn about uncommitted changes when switching branches ===
if [[ "$command" =~ git[[:space:]]+checkout ]]; then
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    echo "⚠️ Warning: You have uncommitted changes" >&2
    echo "Consider committing or stashing before switching branches." >&2
  fi
fi

exit 0
