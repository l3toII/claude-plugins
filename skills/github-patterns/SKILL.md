---
name: github-patterns
description: GitHub integration patterns for issues, PRs, releases, and milestones. Use when interacting with GitHub.
---

# GitHub Patterns

Patterns for GitHub CLI integration.

## GitHub CLI Commands

### Issues

```bash
# Create issue from story
gh issue create \
  --title "US-042: OAuth Login" \
  --body "$(cat docs/backlog/functional/US-042-*.md)" \
  --label "feature" \
  --milestone "Sprint 3"

# List open issues
gh issue list --state open

# Close issue
gh issue close 42 --comment "Completed in PR #123"
```

### Pull Requests

```bash
# Create PR
gh pr create \
  --title "feat(auth): OAuth login (#42)" \
  --body-file PR_BODY.md \
  --base main

# List PRs
gh pr list

# View PR
gh pr view 123

# Get diff
gh pr diff 123

# Review PR
gh pr review 123 --approve
gh pr review 123 --request-changes --body "Fix X"

# Merge PR
gh pr merge 123 --squash --delete-branch
```

### Releases

```bash
# Create release
gh release create v1.3.0 \
  --title "v1.3.0" \
  --notes-file CHANGELOG_SECTION.md

# List releases
gh release list

# Download release
gh release download v1.3.0
```

### Milestones

```bash
# Create milestone
gh api repos/{owner}/{repo}/milestones \
  --method POST \
  --field title="Sprint 3" \
  --field due_on="2025-01-20T00:00:00Z"

# List milestones
gh api repos/{owner}/{repo}/milestones
```

### Workflows

```bash
# List workflow runs
gh run list

# View run
gh run view 12345

# Watch run
gh run watch 12345

# Rerun failed
gh run rerun 12345 --failed
```

## Issue Templates

Create `.github/ISSUE_TEMPLATE/`:

### bug_report.md
```markdown
---
name: Bug Report
about: Report a bug
labels: bug
---

## Description

## Steps to Reproduce
1.
2.
3.

## Expected Behavior

## Actual Behavior

## Environment
- OS:
- Browser:
- Version:
```

### feature_request.md
```markdown
---
name: Feature Request
about: Suggest a feature
labels: enhancement
---

## Problem
What problem does this solve?

## Solution
What's your proposed solution?

## Alternatives
What alternatives did you consider?
```

## Labels

Standard labels:
- `bug`, `feature`, `enhancement`
- `documentation`, `refactor`
- `high-priority`, `low-priority`
- `good-first-issue`, `help-wanted`
- `blocked`, `needs-review`
