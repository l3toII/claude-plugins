---
description: Create or review pull requests. Adapts to repo conventions for base branch and PR format.
argument-hint: [action] [#PR]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh:*)
---

# /pr - Pull Request Management

Create and review pull requests. **Adapts to repository conventions.**

## Usage

```
/pr                  # Create PR for current branch
/pr create           # Same as above
/pr review #123      # Review PR #123
/pr merge #123       # Merge PR #123
```

## /pr create

### 0. Get Repo Conventions (FIRST!)

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
main_branch=$(echo "$config" | jq -r '.main_branch')
flow_type=$(echo "$config" | jq -r '.flow_type')
commit_format=$(echo "$config" | jq -r '.commit_format')
```

### 1. Verify Branch

- Must be on a work branch (pattern depends on repo config)
- Must have commits ahead of base branch

### 2. Run Checks

```bash
make lint-[app]
make test-[app]
```

### 3. Determine Base Branch

**Based on flow type:**

| Flow Type | Base Branch |
|-----------|-------------|
| `github-flow` | `main` |
| `gitflow` | `develop` (features) or `main` (releases) |
| `trunk-based` | `main` |
| `simple` | Detected main branch |

### 4. Generate PR Content

**Title**: Using repo's commit format
```
# conventional
feat(auth): implement OAuth login (#42)

# brackets
[feature] implement OAuth login

# jira
PROJ-42 implement OAuth login
```

**Body**:
```markdown
## Summary
Brief description of changes.

## Related Issue
Closes #42 (or PROJ-42, depending on ticket pattern)

## Changes
- List of changes...

## To Test
1. Testing steps...

## Potential Regression
- Areas to watch...

## Checklist
- [ ] Tests pass
- [ ] Lint clean
- [ ] Documentation updated
- [ ] Screenshots (if UI changes)
```

### 5. Create PR

```bash
# Use the detected base branch
gh pr create --base "$main_branch" --title "..." --body "..."
```

## /pr review #123

### 1. Load PR

```bash
gh pr view 123
gh pr diff 123
```

### 2. Analyze

Check against:
- Code conventions (from repo config)
- Test coverage
- Security patterns
- Performance concerns
- Documentation

### 3. Generate Review

Inline comments on specific lines plus summary:
- What's good
- Suggestions
- Required changes (if any)

### 4. Submit

```bash
gh pr review 123 --approve
# or
gh pr review 123 --request-changes --body "..."
```

## /pr merge #123

### 0. Get Merge Strategy

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
# Some repos prefer squash, others merge commits
```

### 1. Verify

- CI passed
- Approved
- No conflicts

### 2. Merge

```bash
# Default to squash, but can adapt
gh pr merge 123 --squash --delete-branch
```

### 3. Post-merge

- Update story status to Done (if using backlog)
- Notify if unblocks other stories

## PR Base Branch by Flow

| Scenario | github-flow | gitflow | trunk-based |
|----------|------------|---------|-------------|
| Feature PR | → main | → develop | → main |
| Fix PR | → main | → develop | → main |
| Hotfix PR | → main | → main | → main |
| Release PR | N/A | → main | N/A |
