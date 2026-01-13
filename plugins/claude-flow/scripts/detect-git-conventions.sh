#!/bin/bash
# detect-git-conventions.sh - Detect Git conventions from existing repo
# Outputs JSON config for the repo

set -euo pipefail

REPO_PATH="${1:-.}"
cd "$REPO_PATH"

# Check if git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo '{"error": "Not a git repository"}'
  exit 1
fi

# === Detect main branch ===
detect_main_branch() {
  # Check remote HEAD
  local remote_head=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "")

  if [[ -n "$remote_head" ]]; then
    echo "$remote_head"
    return
  fi

  # Check common names
  for branch in main master develop trunk; do
    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null || \
       git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
      echo "$branch"
      return
    fi
  done

  # Fallback to current branch
  git branch --show-current 2>/dev/null || echo "main"
}

# === Detect branch patterns ===
detect_branch_patterns() {
  local branches=$(git branch -r 2>/dev/null | grep -v HEAD | sed 's/origin\///' | head -50)
  local patterns=()

  # Analyze existing branches
  if echo "$branches" | grep -qE '^[[:space:]]*(feature|feat)/'; then
    patterns+=("feature/*")
  fi
  if echo "$branches" | grep -qE '^[[:space:]]*(fix|bugfix|hotfix)/'; then
    patterns+=("fix/*")
  fi
  if echo "$branches" | grep -qE '^[[:space:]]*release/'; then
    patterns+=("release/*")
  fi
  if echo "$branches" | grep -qE '^[[:space:]]*develop'; then
    patterns+=("develop")
  fi
  if echo "$branches" | grep -qE '^[[:space:]]*(chore|tech)/'; then
    patterns+=("tech/*")
  fi

  # Output as JSON array
  printf '%s\n' "${patterns[@]}" | jq -R . | jq -s .
}

# === Detect commit format ===
detect_commit_format() {
  local commits=$(git log --oneline -50 2>/dev/null || echo "")
  local conventional_count=$(echo "$commits" | grep -cE '^[a-f0-9]+ (feat|fix|docs|style|refactor|test|chore|perf|ci)(\(.+\))?:' || echo 0)
  local total=$(echo "$commits" | wc -l | tr -d ' ')

  if [[ $total -gt 0 ]] && [[ $conventional_count -gt $((total / 2)) ]]; then
    echo "conventional"
  elif echo "$commits" | grep -qE '\[.+\]'; then
    echo "brackets"  # [feature] message
  elif echo "$commits" | grep -qE '#[0-9]+'; then
    echo "ticket-ref"  # message #123
  else
    echo "freeform"
  fi
}

# === Detect Git flow type ===
detect_flow_type() {
  local branches=$(git branch -r 2>/dev/null | grep -v HEAD || echo "")

  if echo "$branches" | grep -qE 'origin/develop' && echo "$branches" | grep -qE 'origin/release/'; then
    echo "gitflow"
  elif echo "$branches" | grep -qE 'origin/(feature|feat)/' && ! echo "$branches" | grep -qE 'origin/develop'; then
    echo "github-flow"
  elif echo "$branches" | grep -qE 'origin/release/' && ! echo "$branches" | grep -qE 'origin/develop'; then
    echo "trunk-based"
  else
    echo "simple"
  fi
}

# === Detect PR/MR template ===
detect_pr_template() {
  if [[ -f ".github/pull_request_template.md" ]]; then
    echo "github"
  elif [[ -f ".gitlab/merge_request_templates" ]] || [[ -d ".gitlab/merge_request_templates" ]]; then
    echo "gitlab"
  elif [[ -f "PULL_REQUEST_TEMPLATE.md" ]]; then
    echo "root"
  else
    echo "none"
  fi
}

# === Detect protected branches ===
detect_protected_branches() {
  local protected=()
  local main=$(detect_main_branch)

  protected+=("$main")

  if git show-ref --verify --quiet "refs/remotes/origin/develop" 2>/dev/null; then
    protected+=("develop")
  fi

  printf '%s\n' "${protected[@]}" | jq -R . | jq -s .
}

# === Detect ticket pattern ===
detect_ticket_pattern() {
  local commits=$(git log --oneline -50 2>/dev/null || echo "")

  if echo "$commits" | grep -qE '#[0-9]+'; then
    echo "#NUMBER"
  elif echo "$commits" | grep -qE '[A-Z]+-[0-9]+'; then
    echo "JIRA"  # PROJ-123
  elif echo "$commits" | grep -qE '\[#?[0-9]+\]'; then
    echo "BRACKETS"  # [123] or [#123]
  else
    echo "none"
  fi
}

# === Build JSON output ===
MAIN_BRANCH=$(detect_main_branch)
BRANCH_PATTERNS=$(detect_branch_patterns)
COMMIT_FORMAT=$(detect_commit_format)
FLOW_TYPE=$(detect_flow_type)
PR_TEMPLATE=$(detect_pr_template)
PROTECTED=$(detect_protected_branches)
TICKET_PATTERN=$(detect_ticket_pattern)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

cat << EOF
{
  "repo": "$REPO_NAME",
  "detected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "flow_type": "$FLOW_TYPE",
  "main_branch": "$MAIN_BRANCH",
  "branch_patterns": $BRANCH_PATTERNS,
  "commit_format": "$COMMIT_FORMAT",
  "ticket_pattern": "$TICKET_PATTERN",
  "pr_template": "$PR_TEMPLATE",
  "protected_branches": $PROTECTED
}
EOF
