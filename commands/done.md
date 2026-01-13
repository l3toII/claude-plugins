---
description: Complete current work. Runs checks, commits, creates PR, updates story status. Adapts to repo conventions.
argument-hint: [--no-pr] [--draft]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(make:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh:*)
---

# /done - Complete Work

Finish current work with full workflow: checks → commit → PR → story update.
**Adapts to repository conventions.**

## Usage

```
/done              # Complete current work
/done --no-pr      # Commit only, no PR
/done --draft      # Create draft PR
```

## Workflow

### 0. Get Repo Conventions (FIRST!)

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
main_branch=$(echo "$config" | jq -r '.main_branch')
commit_format=$(echo "$config" | jq -r '.commit_format')
flow_type=$(echo "$config" | jq -r '.flow_type')
```

### 1. Pre-flight Checks

Run all checks:
```bash
# Lint
make lint-[app] || npm run lint

# Tests
make test-[app] || npm test

# Type check (if TypeScript)
npx tsc --noEmit
```

If checks fail:
> "❌ Checks failed. Fix issues before completing."

### 2. Stage Changes

```bash
git add -A
git status
```

Show summary of changes.

### 3. Generate Commit Message (Using Repo Format)

**Adapt to repo's commit convention:**

| Format | Example |
|--------|---------|
| `conventional` | `feat(auth): add OAuth (#42)` |
| `brackets` | `[feature] add OAuth login` |
| `ticket-ref` | `add OAuth login #42` |
| `JIRA` | `PROJ-42 add OAuth login` |
| `freeform` | Match existing style |

### 4. Commit & Push

```bash
git commit -m "[formatted-message]"
git push origin [branch]
```

### 5. Create PR (unless --no-pr)

**Adapt PR base branch to flow type:**

| Flow Type | PR Base |
|-----------|---------|
| `github-flow` | `main` |
| `gitflow` | `develop` |
| `trunk-based` | `main` |

Generate PR with:
- Title from commit (using repo format)
- Description with:
  - Summary of changes
  - Link to story/ticket (if using backlog)
  - Acceptance criteria checklist
  - "To Test" section
  - "Potential Regression" section

```bash
gh pr create --base "$main_branch" --title "..." --body "..."
```

### 6. Update Story Status (if using backlog)

Change story status:
- From "In Progress" to "Review"
- Add PR link to story file

### 7. Summary

Display:
```
✅ Work completed!

📝 Commit: [message in repo's format]
🔗 PR #123: https://github.com/.../pull/123
📋 Story: In Progress → Review (if using backlog)
🔧 Convention: [commit_format] (source: configured|detected)

Next: Wait for review or /work #XX for next task
```

## Checks Before PR

- [ ] All tests pass
- [ ] Lint clean (0 warnings)
- [ ] Coverage >= threshold (if configured)
- [ ] No secrets in code
- [ ] Ticket referenced (based on repo convention)
