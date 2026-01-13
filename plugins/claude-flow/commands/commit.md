---
description: Create a commit using repository's conventions. Adapts format based on detected or configured patterns.
argument-hint: [message] [--amend]
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh:*)
---

# /commit - Create Commit

Create a commit using the **repository's commit conventions**.

## Usage

```
/commit                    # Auto-generate message
/commit "custom message"   # With custom message
/commit --amend            # Amend last commit
```

## Workflow

### 0. Get Repo Conventions (FIRST!)

```bash
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
commit_format=$(echo "$config" | jq -r '.commit_format')
ticket_pattern=$(echo "$config" | jq -r '.ticket_pattern')
```

### 1. Check Changes

```bash
git status
git diff --stat
```

If no changes:
> "No changes to commit."

### 2. Pre-commit Checks

- Format code (auto-fix)
- Lint check
- Run affected tests

### 3. Generate Message (Using Repo Format)

**Adapt to detected commit format:**

| Format | Pattern | Example |
|--------|---------|---------|
| `conventional` | `type(scope): msg (#ticket)` | `feat(auth): add OAuth (#42)` |
| `brackets` | `[type] msg` | `[feature] add OAuth login` |
| `ticket-ref` | `msg #ticket` | `add OAuth login #42` |
| `freeform` | Follow repo style | Match existing commits |

**Adapt ticket reference:**

| Pattern | Format | Example |
|---------|--------|---------|
| `#NUMBER` | `(#42)` or `#42` | `feat: login (#42)` |
| `JIRA` | `PROJ-42` | `feat: login PROJ-42` |
| `BRACKETS` | `[42]` | `[42] add login` |
| `none` | No ticket | `feat: add login` |

### 4. Commit

```bash
git add -A
git commit -m "[formatted-message]"
```

### 5. Show Result

```
✅ Committed: [message in repo's format]

Files changed: 5
Insertions: +142
Deletions: -23
Convention: conventional (detected)
```

## Format Examples by Repo Type

### Conventional Commits (most common)
```
feat(auth): add OAuth login flow (#42)
fix(api): handle null response (#43)
docs(readme): update installation
refactor(ui): extract Button component
```

### Brackets Style
```
[feature] add OAuth login flow
[fix] handle null response in API
[docs] update installation guide
```

### Ticket Reference Style
```
add OAuth login flow #42
handle null response in API #43
update installation guide
```

### Jira Style
```
PROJ-42 add OAuth login flow
PROJ-43 fix null response handling
```

## Commit Types (if conventional)

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting |
| `refactor` | Code refactoring |
| `test` | Adding tests |
| `chore` | Maintenance |
| `perf` | Performance |
| `ci` | CI/CD changes |

Scope: Derived from changed files (auth, api, ui...)
