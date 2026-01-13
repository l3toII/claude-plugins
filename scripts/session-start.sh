#!/bin/bash
# session-start.sh - Load context at session start
# Displays reminders and project state

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SESSION_FILE="$PROJECT_DIR/.claude/session.json"
BACKLOG_DIR="$PROJECT_DIR/docs/backlog"

show_reminders() {
  local reminders=()
  
  # Check active sprint
  if [[ -d "$PROJECT_DIR/docs/sprints" ]]; then
    local current_sprint=$(find "$PROJECT_DIR/docs/sprints" -name "SPRINT-*.md" -type f 2>/dev/null | sort -r | head -1)
    if [[ -n "$current_sprint" ]]; then
      local sprint_name=$(basename "$current_sprint" .md)
      reminders+=("📋 Active sprint: $sprint_name")
    fi
  fi
  
  # Check technical debt
  if [[ -d "$BACKLOG_DIR/technical" ]]; then
    local debt_count=$(find "$BACKLOG_DIR/technical" -name "TD-*.md" 2>/dev/null | wc -l)
    if [[ $debt_count -gt 8 ]]; then
      reminders+=("⚠️ Technical debt: $debt_count tickets (budget exceeded)")
    elif [[ $debt_count -gt 5 ]]; then
      reminders+=("📊 Technical debt: $debt_count tickets")
    fi
  fi
  
  # Check Draft stories > 3 days
  if [[ -d "$BACKLOG_DIR" ]]; then
    local old_drafts=$(find "$BACKLOG_DIR" -name "*.md" -mtime +3 -exec grep -l "Status: Draft" {} \; 2>/dev/null | wc -l)
    if [[ $old_drafts -gt 0 ]]; then
      reminders+=("📝 $old_drafts Draft stories > 3 days old")
    fi
  fi
  
  if [[ ${#reminders[@]} -gt 0 ]]; then
    echo ""
    echo "📋 **Workflow Reminders**"
    for reminder in "${reminders[@]}"; do
      echo "  $reminder"
    done
    echo ""
  fi
}

restore_session() {
  if [[ -f "$SESSION_FILE" ]]; then
    local active_story=$(jq -r '.active_story // empty' "$SESSION_FILE" 2>/dev/null)
    local active_branch=$(jq -r '.active_branch // empty' "$SESSION_FILE" 2>/dev/null)
    
    if [[ -n "$active_story" ]] || [[ -n "$active_branch" ]]; then
      echo "🔄 **Previous session detected**"
      [[ -n "$active_story" ]] && echo "  Story: $active_story"
      [[ -n "$active_branch" ]] && echo "  Branch: $active_branch"
      echo "  Type /work to continue or /status to see current state"
      echo ""
    fi
  fi
}

if [[ -f "$PROJECT_DIR/CLAUDE.md" ]] || [[ -d "$PROJECT_DIR/docs/backlog" ]]; then
  restore_session
  show_reminders
fi

exit 0
