---
description: Complete current work. Runs quality checks, commits, creates PR in app repo, syncs story status.
argument-hint: [--no-pr] [--draft]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(make:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh:*)
---

# /done - Complete Work

Finish current work with full workflow: quality checks → commit → PR → sync story.
**Operates in the current app's repository.**

## Usage

```
/done              # Complete current work
/done --no-pr      # Commit only, no PR
/done --draft      # Create draft PR
```

## Workflow

### 0. Load Session Context

```bash
# Get current work context
session=$(cat .claude/session.json)
active_story=$(echo "$session" | jq -r '.active_story')
active_app=$(echo "$session" | jq -r '.active_app')
active_ticket=$(echo "$session" | jq -r '.active_ticket')
app_path=$(echo "$session" | jq -r '.app_path')

if [ -z "$active_app" ]; then
    echo "No active work. Start with /work S-XXX"
    exit 1
fi
```

### 1. Quality Checks (BLOCKING)

```bash
cd $app_path

# Load quality requirements
quality_file=".claude/quality.json"
if [ -f "$quality_file" ]; then
    min_coverage=$(jq -r '.coverage.minimum // 0' "$quality_file")
    lint_warnings=$(jq -r '.lint.warnings_allowed // 0' "$quality_file")
    tests_required=$(jq -r '.tests.required // true' "$quality_file")
    security_block=$(jq -r '.security.block_secrets // true' "$quality_file")
fi
```

#### 1.1 Lint Check
```bash
npm run lint 2>&1
lint_exit=$?

if [ $lint_exit -ne 0 ]; then
    echo "❌ Lint failed. Fix issues before completing."
    exit 1
fi
```

#### 1.2 Tests
```bash
if [ "$tests_required" = "true" ]; then
    npm test 2>&1
    test_exit=$?

    if [ $test_exit -ne 0 ]; then
        echo "❌ Tests failed. Fix before completing."
        exit 1
    fi
fi
```

#### 1.3 Coverage Check
```bash
if [ "$min_coverage" -gt 0 ]; then
    # Run coverage and extract percentage
    coverage=$(npm run coverage --json 2>/dev/null | jq -r '.total.lines.pct // 0')

    if [ "$coverage" -lt "$min_coverage" ]; then
        echo "❌ Coverage $coverage% < required $min_coverage%"
        exit 1
    fi
fi
```

#### 1.4 Type Check (TypeScript)
```bash
if [ -f "tsconfig.json" ]; then
    npx tsc --noEmit
    if [ $? -ne 0 ]; then
        echo "❌ TypeScript errors. Fix before completing."
        exit 1
    fi
fi
```

### 2. Get Repo Conventions

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
main_branch=$(echo "$config" | jq -r '.main_branch')
commit_format=$(echo "$config" | jq -r '.commit_format')
```

### 3. Stage Changes

```bash
git add -A
git status --short
```

Show summary of changes.

### 4. Generate Commit Message

Adapt to repo's format with ticket reference:

| Format | Example |
|--------|---------|
| `conventional` | `feat(auth): add OAuth login (#15)` |
| `brackets` | `[feature] add OAuth login [#15]` |
| `ticket-ref` | `add OAuth login #15` |

### 5. Commit & Push

```bash
git commit -m "[formatted-message]"
git push origin $(git branch --show-current)
```

### 6. Create PR in App Repo (unless --no-pr)

```bash
# Get app's remote info
app_remote=$(git remote get-url origin)
app_owner=$(echo $app_remote | sed -E 's/.*[:/]([^/]+)\/([^/]+)(\.git)?$/\1/')
app_repo=$(echo $app_remote | sed -E 's/.*[:/]([^/]+)\/([^/]+)(\.git)?$/\2/' | sed 's/\.git$//')

# Create PR
gh pr create \
  --repo "$app_owner/$app_repo" \
  --base "$main_branch" \
  --title "[S-${active_story}] Title (#${active_ticket})" \
  --body "$(cat <<EOF
## Summary
[Brief description of changes]

## Related
- Story: S-${active_story}
- Ticket: #${active_ticket}

## Changes
[List of main changes]

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing done

## Checklist
- [ ] Code follows conventions
- [ ] Tests added/updated
- [ ] Documentation updated
EOF
)"
```

If `--draft`, add `--draft` flag.

### 7. Close Ticket Issue

```bash
gh issue close $active_ticket --repo "$app_owner/$app_repo"
```

### 8. Update Story File

Go back to principal repo and update story:

```bash
cd ../..  # Back to root

story_file=$(ls project/backlog/S-${active_story}-*.md | head -1)

# Update ticket row in table: add PR link, set status to Done
# | api | #15 | #20 | Done |
```

### 9. Check if Story Complete

```bash
# Count pending tickets
pending=$(grep -E '\| .+ \| #[0-9]+ \| .* \| (Pending|In Progress) \|' "$story_file" | wc -l)

if [ "$pending" -eq 0 ]; then
    # All tickets done → Story done
    sed -i '' 's/## Status\n.*/## Status\nDone/' "$story_file"

    # Close principal GitHub issue
    principal_issue=$(grep "GitHub Issue:" "$story_file" | grep -oE '#[0-9]+' | tr -d '#')
    if [ -n "$principal_issue" ]; then
        gh issue close $principal_issue
    fi

    echo "✅ All tickets complete! Story S-${active_story} → Done"
fi
```

### 10. Clear Session (for this app)

```bash
# Update session - remove active work
jq 'del(.active_app, .active_ticket, .active_branch, .app_path)' .claude/session.json > tmp.json
mv tmp.json .claude/session.json
```

### 11. Summary

```
✅ Work completed!

📦 App: api
📝 Commit: feat(auth): add OAuth (#15)
🔗 PR #20: https://github.com/org/api/pull/20
🎫 Ticket #15: Closed

📋 Story S-042: 1/2 apps done
   ✅ api: PR #20
   ⏳ web: Pending

Quality:
   ✅ Lint: 0 warnings
   ✅ Tests: 47/47 passed
   ✅ Coverage: 85% (min: 80%)
   ✅ TypeScript: No errors

Next:
• /work S-042 --app web  (continue story)
• /work S-XXX            (start new story)
```

## Quality Gates Summary

| Check | Source | Blocking |
|-------|--------|----------|
| Lint | `npm run lint` | Yes |
| Tests | `npm test` | Configurable |
| Coverage | `.claude/quality.json` | Configurable |
| TypeScript | `tsc --noEmit` | Yes (if TS) |
| Secrets | `guard-secrets.sh` | Warning only |

## Guards

**No active work:**
> "No active work session. Start with /work S-XXX"

**Quality checks fail:**
> "❌ Quality checks failed. Fix issues before completing."

**No changes to commit:**
> "No changes to commit. Make changes first or use /work to start."

**PR creation fails:**
> "Failed to create PR. Check gh auth and remote configuration."
