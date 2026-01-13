---
description: Onboard an existing repository. Detects Git conventions, analyzes structure, and configures workflow settings.
argument-hint: [repo-path]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/detect-git-conventions.sh:*)
---

# /onboard - Repository Onboarding

Analyze an existing repository and configure the workflow to match its conventions.

## Usage

```
/onboard                    # Onboard current directory
/onboard ./apps/api         # Onboard specific repo
/onboard --all              # Onboard all repos in project
```

## Workflow

### 1. Detect Git Conventions

Run detection script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/detect-git-conventions.sh [repo-path]
```

This detects:
- **Flow type**: gitflow, github-flow, trunk-based, simple
- **Main branch**: main, master, develop, trunk
- **Branch patterns**: feature/*, feat/*, fix/*, etc.
- **Commit format**: conventional, brackets, ticket-ref, freeform
- **Ticket pattern**: #NUMBER, JIRA (PROJ-123), BRACKETS, none
- **PR template**: github, gitlab, root, none

### 2. Analyze Project Structure

Check for:
- Monorepo vs single repo
- Package manager (npm, yarn, pnpm, cargo, etc.)
- Test framework
- CI/CD setup (GitHub Actions, GitLab CI, etc.)
- Existing documentation

### 3. Review with User

Present detected conventions:

```
📦 Repository: api

Detected Conventions:
├── Flow: github-flow
├── Main branch: main
├── Branches: feature/*, fix/*, chore/*
├── Commits: conventional (feat, fix, etc.)
├── Tickets: #NUMBER format
└── PR Template: .github/pull_request_template.md

Is this correct? (y/n/edit)
```

### 4. Save Configuration

Create/update `.claude/repos.json`:

```json
{
  "repos": {
    "api": {
      "path": "./apps/api",
      "flow_type": "github-flow",
      "main_branch": "main",
      "branch_patterns": {
        "feature": "feature/*",
        "fix": "fix/*",
        "tech": "chore/*"
      },
      "commit_format": "conventional",
      "ticket_pattern": "#NUMBER",
      "protected_branches": ["main"]
    }
  },
  "default_repo": "api",
  "use_plugin_defaults": false
}
```

### 5. Generate Compatibility Layer

If conventions differ from plugin defaults, note the mappings:

```json
{
  "mappings": {
    "tech/*": "chore/*",      // Plugin says tech/, repo uses chore/
    "US-XXX": "#XXX"          // Plugin says US-XXX, repo uses #XXX
  }
}
```

## Multi-Repo Projects

For monorepos or multi-repo setups:

```
/onboard --all
```

Scans:
- `apps/*/`
- `packages/*/`
- `services/*/`
- Root if single repo

Each repo gets its own config entry.

## Fallback Behavior

If no conventions detected:
1. Ask user preference
2. Or use plugin defaults
3. Store choice in `.claude/repos.json`

## Output

```
✅ Repository onboarded: api

Conventions configured:
- Branch: feature/#XX → feature/XX (adapted)
- Commits: conventional commits ✓
- Tickets: #NUMBER format ✓

Next steps:
1. Review .claude/repos.json
2. Use /work #42 to start (will use detected conventions)
3. Or /story to create backlog (optional)
```

## Re-onboarding

Running `/onboard` again on a configured repo:
- Shows current config
- Offers to re-detect
- Allows manual edits
