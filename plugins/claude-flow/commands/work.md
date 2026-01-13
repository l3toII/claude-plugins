---
description: Start working on a ticket. Creates branch, loads context, sets up environment. Adapts to repo conventions.
argument-hint: [#ticket]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh:*)
---

# /work - Start Working on Ticket

Begin work on a specific ticket. **Adapts to repository conventions.**

## Usage

```
/work #42           # Work on ticket #42
/work US-042        # Work on user story
/work PROJ-42       # Work on Jira ticket
/work               # Continue previous work
```

## Workflow

### 0. Get Repo Conventions (FIRST!)

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
echo "$config" | jq .
```

Extract key values:
```bash
main_branch=$(echo "$config" | jq -r '.main_branch')
flow_type=$(echo "$config" | jq -r '.flow_type')
feature_pattern=$(echo "$config" | jq -r '.branch_patterns.feature // "feature/*"')
ticket_pattern=$(echo "$config" | jq -r '.ticket_pattern')
```

### 1. Load Context

- Read story file from `docs/backlog/` (if exists)
- Load acceptance criteria
- Check dependencies (blocked by other stories?)
- Load relevant architecture docs

### 2. Create Branch (Using Repo Conventions)

**Adapt branch name to repo's pattern:**

| Repo Pattern | Example Branch |
|-------------|----------------|
| `feature/#*` | `feature/#42-oauth-login` |
| `feature/*` | `feature/42-oauth-login` |
| `feat/*` | `feat/oauth-login` |
| `PROJ-*` | `PROJ-42-oauth-login` |

```bash
# Get the repo's main branch
git checkout "$main_branch"
git pull origin "$main_branch"

# Create branch using detected pattern
git checkout -b [adapted-branch-name]
```

### 3. Update Session

Save to `.claude/session.json`:
```json
{
  "active_ticket": "42",
  "active_story": "US-042",
  "active_branch": "feature/42-oauth-login",
  "repo_config_source": "configured|auto_detected|plugin_defaults",
  "started_at": "2025-01-12T10:00:00Z"
}
```

### 4. Display Work Plan

Show:
- Story summary (if using backlog)
- Acceptance criteria as checklist
- Suggested approach
- Relevant files to modify
- **Repo conventions being used**

### 5. Update Story Status (if using backlog)

Change status from "To Do" to "In Progress"

## Branch Mapping Examples

| Story Type | Plugin Default | GitHub Flow | GitFlow | Jira Style |
|-----------|---------------|-------------|---------|------------|
| Feature | `feature/#42-desc` | `feat/42-desc` | `feature/desc` | `PROJ-42-desc` |
| Fix | `fix/#42-desc` | `fix/42-desc` | `hotfix/desc` | `PROJ-42-fix` |
| Tech | `tech/#42-desc` | `chore/42-desc` | `chore/desc` | `PROJ-42-tech` |

## Guards

If no ticket specified and no previous session:
> "Which ticket do you want to work on? Use /work #XX"

If using backlog and ticket doesn't exist:
> "Ticket #XX not found. Create it first with /story"

If repo not onboarded:
> "Run /onboard first to detect repo conventions"
