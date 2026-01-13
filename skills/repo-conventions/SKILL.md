---
name: repo-conventions
description: Repository-specific Git conventions. Use when working with branches, commits, PRs to apply the correct conventions for the current repo.
allowed-tools: Read, Bash(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh:*)
---

# Repository Conventions

This skill provides adaptive Git conventions based on the current repository's configuration.

## How It Works

1. **Check `.claude/repos.json`** for configured conventions
2. **Auto-detect** if no config exists
3. **Apply plugin defaults** only if explicitly set or no conventions found

## Getting Current Conventions

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh [repo-path]
```

Returns JSON with `source` field:
- `configured` - From .claude/repos.json
- `auto_detected` - Detected from repo history
- `plugin_defaults` - Using workflow plugin defaults
- `fallback` - Minimal defaults

## Convention Priority

```
1. .claude/repos.json (explicit config)
      ↓
2. Auto-detection (from repo history)
      ↓
3. Plugin defaults (if use_plugin_defaults: true)
      ↓
4. Minimal fallback
```

## Using Conventions

### Before Creating a Branch

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
branch_pattern=$(echo "$config" | jq -r '.branch_patterns.feature // "feature/*"')
```

### Before Committing

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
commit_format=$(echo "$config" | jq -r '.commit_format')

case "$commit_format" in
  conventional) # feat(scope): message (#ticket)
    ;;
  brackets)     # [feature] message
    ;;
  ticket-ref)   # message #ticket
    ;;
  freeform)     # any format
    ;;
esac
```

### Before Pushing

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
main_branch=$(echo "$config" | jq -r '.main_branch')
protected=$(echo "$config" | jq -r '.protected_branches[]')
```

## Config Schema

```json
{
  "repos": {
    "repo-name": {
      "path": "./relative/path",
      "flow_type": "github-flow|gitflow|trunk-based|simple",
      "main_branch": "main|master|develop|trunk",
      "branch_patterns": {
        "feature": "feature/*|feat/*",
        "fix": "fix/*|bugfix/*|hotfix/*",
        "tech": "tech/*|chore/*|refactor/*",
        "release": "release/*",
        "poc": "poc/*|experiment/*",
        "vibe": "vibe/*|playground/*"
      },
      "commit_format": "conventional|brackets|ticket-ref|freeform",
      "ticket_pattern": "#NUMBER|JIRA|BRACKETS|none",
      "pr_template": "github|gitlab|root|none",
      "protected_branches": ["main", "develop"],
      "non_mergeable": ["poc/*", "vibe/*"]
    }
  },
  "default_repo": "repo-name",
  "use_plugin_defaults": false
}
```

## Flow Types Explained

### github-flow
- Single main branch
- Feature branches merge directly to main
- Deploy from main

### gitflow
- `main` for releases
- `develop` for integration
- `feature/*` → develop
- `release/*` → main + develop
- `hotfix/*` → main + develop

### trunk-based
- Short-lived feature branches
- Frequent merges to main
- Feature flags for incomplete work

### simple
- Basic branching, no specific pattern
- Flexible workflow

## Adapting Plugin Commands

When a command like `/work` runs, it should:

1. Get repo config
2. Map plugin concepts to repo conventions:
   - Plugin `feature/#42-desc` → Repo `feat/42-description`
   - Plugin `US-042` → Repo `#42`
3. Use repo's branch/commit patterns

## Example Mappings

| Plugin Default | GitHub Flow | GitFlow | Trunk-Based |
|---------------|-------------|---------|-------------|
| `feature/#42-*` | `feat/42-*` | `feature/PROJ-42-*` | `42-short-desc` |
| `main` | `main` | `develop` | `main` |
| `feat(x): msg (#42)` | `feat: msg #42` | `[PROJ-42] msg` | `msg` |
