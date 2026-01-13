---
name: git-flow
description: Git branching strategy and workflow. Use when creating branches, merging, or managing git operations. Adapts to repository conventions.
---

# Git Flow (Adaptive)

This skill adapts to the repository's Git conventions. Always check repo config first.

## Get Current Repo Conventions

```bash
# ALWAYS run this first to get the repo's conventions
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
echo "$config" | jq .
```

## Adapting to Repo Conventions

### Branch Creation

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
flow_type=$(echo "$config" | jq -r '.flow_type')
main_branch=$(echo "$config" | jq -r '.main_branch')
feature_pattern=$(echo "$config" | jq -r '.branch_patterns.feature // "feature/*"')

# Start from the repo's main branch (might be main, develop, trunk, etc.)
git checkout "$main_branch"
git pull origin "$main_branch"

# Create branch using repo's pattern
# Examples based on detected pattern:
# - feature/*     → feature/oauth-login
# - feat/*        → feat/oauth-login
# - feature/#*    → feature/#42-oauth-login (plugin default)
# - PROJ-*        → PROJ-42-oauth-login (Jira style)
```

### Commit Format

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
commit_format=$(echo "$config" | jq -r '.commit_format')
ticket_pattern=$(echo "$config" | jq -r '.ticket_pattern')

case "$commit_format" in
  conventional)
    # feat(scope): message (#42) or feat(scope): message PROJ-42
    ;;
  brackets)
    # [feature] message or [PROJ-42] message
    ;;
  ticket-ref)
    # message #42 or message PROJ-42
    ;;
  freeform)
    # Any format - follow existing repo style
    ;;
esac
```

## Plugin Defaults (Fallback Only)

These are used ONLY when:
- No `.claude/repos.json` exists AND
- Auto-detection finds no patterns AND
- `use_plugin_defaults: true` is set

| Branch | Pattern | Mergeable | Ticket |
|--------|---------|-----------|--------|
| `main` | `main` | N/A | N/A |
| `feature` | `feature/#XX-desc` | ✅ Yes | ✅ Required |
| `fix` | `fix/#XX-desc` | ✅ Yes | ✅ Required |
| `tech` | `tech/#XX-desc` | ✅ Yes | ✅ Required |
| `poc` | `poc/desc` | ❌ No | ❌ No |
| `vibe` | `vibe/desc` | ❌ No | ❌ No |

## Flow Type Workflows

### github-flow (most common)

```bash
# Direct to main, feature branches
git checkout main && git pull
git checkout -b feature/description
# ... work ...
git push -u origin feature/description
gh pr create --base main
```

### gitflow

```bash
# develop is integration branch
git checkout develop && git pull
git checkout -b feature/description
# ... work ...
git push -u origin feature/description
gh pr create --base develop

# Releases go through release branch
git checkout -b release/v1.2.0
# ... final fixes ...
gh pr create --base main
```

### trunk-based

```bash
# Short-lived branches, frequent merges
git checkout main && git pull
git checkout -b short-description
# ... small change ...
git push -u origin short-description
gh pr create --base main
# Merge same day if possible
```

## Protected Branches

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
protected=$(echo "$config" | jq -r '.protected_branches[]')

# Never force push to protected branches
# Always use PRs for protected branches
```

## Non-Mergeable Branches

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
non_mergeable=$(echo "$config" | jq -r '.non_mergeable // ["poc/*", "vibe/*"]')

# These branches are for exploration only
# Must reimplement in proper branch if successful
```

## Cleanup

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
main_branch=$(echo "$config" | jq -r '.main_branch')

# Delete merged branches
git branch --merged "$main_branch" | grep -v "$main_branch" | xargs git branch -d

# Prune remote tracking
git fetch --prune
```
