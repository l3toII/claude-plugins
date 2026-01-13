#!/bin/bash
# session-save.sh - Save session state before exiting
# Non-blocking

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CLAUDE_DIR="$PROJECT_DIR/.claude"
SESSION_FILE="$CLAUDE_DIR/session.json"

mkdir -p "$CLAUDE_DIR"

branch=$(git branch --show-current 2>/dev/null || echo "")
last_commit=$(git log -1 --format="%h %s" 2>/dev/null || echo "")

ticket=""
if [[ "$branch" =~ ^(feature|fix|tech)/#([0-9]+) ]]; then
  ticket="${BASH_REMATCH[2]}"
fi

cat > "$SESSION_FILE" << EOF
{
  "last_updated": "$(date -Iseconds)",
  "active_branch": "$branch",
  "active_ticket": "$ticket",
  "last_commit": "$last_commit",
  "working_directory": "$PROJECT_DIR"
}
EOF

if [[ -d "$PROJECT_DIR/docs/backlog/technical" ]]; then
  debt_count=$(find "$PROJECT_DIR/docs/backlog/technical" -name "TD-*.md" 2>/dev/null | wc -l)
  if [[ $debt_count -gt 8 ]]; then
    echo ""
    echo "💡 Reminder: $debt_count technical debt tickets pending"
    echo "   Consider planning a debt sprint soon."
  fi
fi

exit 0
