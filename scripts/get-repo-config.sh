#!/bin/bash
# get-repo-config.sh - Get Git conventions for current repo
# Returns JSON config (detected or from .claude/repos.json)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
REPO_PATH="${1:-$(pwd)}"

# Get repo name from git
get_repo_name() {
  cd "$REPO_PATH"
  if git rev-parse --git-dir > /dev/null 2>&1; then
    basename "$(git rev-parse --show-toplevel)"
  else
    basename "$REPO_PATH"
  fi
}

REPO_NAME=$(get_repo_name)
CONFIG_FILE="$PROJECT_DIR/.claude/repos.json"

# Check if config exists for this repo
if [[ -f "$CONFIG_FILE" ]]; then
  repo_config=$(jq -r ".repos[\"$REPO_NAME\"] // empty" "$CONFIG_FILE" 2>/dev/null || echo "")

  if [[ -n "$repo_config" && "$repo_config" != "null" ]]; then
    # Return stored config with source indicator
    echo "$repo_config" | jq '. + {"source": "configured"}'
    exit 0
  fi
fi

# No config found - check for use_plugin_defaults flag
if [[ -f "$CONFIG_FILE" ]]; then
  use_defaults=$(jq -r '.use_plugin_defaults // false' "$CONFIG_FILE" 2>/dev/null || echo "false")

  if [[ "$use_defaults" == "true" ]]; then
    # Return plugin defaults
    cat << 'EOF'
{
  "source": "plugin_defaults",
  "flow_type": "github-flow",
  "main_branch": "main",
  "branch_patterns": {
    "feature": "feature/#*",
    "fix": "fix/#*",
    "tech": "tech/#*",
    "poc": "poc/*",
    "vibe": "vibe/*"
  },
  "commit_format": "conventional",
  "ticket_pattern": "#NUMBER",
  "ticket_prefix": {
    "feature": "US",
    "fix": "BUG",
    "tech": "TS"
  },
  "protected_branches": ["main", "master"],
  "non_mergeable": ["poc/*", "vibe/*"]
}
EOF
    exit 0
  fi
fi

# No config, no defaults flag - run detection
if [[ -x "$SCRIPT_DIR/detect-git-conventions.sh" ]]; then
  detected=$("$SCRIPT_DIR/detect-git-conventions.sh" "$REPO_PATH" 2>/dev/null || echo "")

  if [[ -n "$detected" && ! "$detected" =~ "error" ]]; then
    echo "$detected" | jq '. + {"source": "auto_detected"}'
    exit 0
  fi
fi

# Fallback to minimal defaults
cat << 'EOF'
{
  "source": "fallback",
  "flow_type": "simple",
  "main_branch": "main",
  "branch_patterns": {},
  "commit_format": "freeform",
  "ticket_pattern": "none",
  "protected_branches": ["main"]
}
EOF
