#!/bin/bash
# post-edit-format.sh - Auto-format after file edits
# Non-blocking (always exit 0)

set -uo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

[[ -z "$file_path" ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ext="${file_path##*.}"

case "$ext" in
  ts|tsx|js|jsx|json|css|scss|md|yaml|yml)
    if command -v npx &>/dev/null && [[ -f "$PROJECT_DIR/node_modules/.bin/prettier" ]]; then
      npx prettier --write "$file_path" 2>/dev/null || true
    elif command -v prettier &>/dev/null; then
      prettier --write "$file_path" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v black &>/dev/null; then
      black --quiet "$file_path" 2>/dev/null || true
    elif command -v autopep8 &>/dev/null; then
      autopep8 --in-place "$file_path" 2>/dev/null || true
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$file_path" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$file_path" 2>/dev/null || true
    fi
    ;;
esac

exit 0
