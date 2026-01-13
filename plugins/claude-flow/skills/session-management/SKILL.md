---
name: session-management
description: Session state persistence and restoration. Use when starting sessions, saving progress, or managing context.
---

# Session Management

Persist and restore working context across sessions.

## Session File

Location: `.claude/session.json`

```json
{
  "last_updated": "2025-01-12T18:00:00Z",
  "active_branch": "feature/#42-oauth-login",
  "active_ticket": "42",
  "active_story": "US-042",
  "last_commit": "abc123 feat(auth): add OAuth service",
  "working_directory": "/path/to/project",
  "open_files": [
    "apps/api/src/auth/service.ts",
    "apps/api/src/auth/controller.ts"
  ],
  "notes": "Working on callback handler next"
}
```

## Session Start

On session start:

1. Check for existing session file
2. Load active context
3. Verify branch still exists
4. Show session summary
5. Display reminders

```
🔄 Previous session detected

Branch: feature/#42-oauth-login
Story: US-042 OAuth Login
Last commit: abc123 feat(auth): add OAuth service

Type /work to continue or /status for overview
```

## Session Save

On session end or periodically:

1. Capture current branch
2. Record last commit
3. Note any uncommitted changes
4. Save open file list
5. Update timestamp

## Context Loading

When resuming work:

```bash
# Verify we're on the right branch
git branch --show-current

# Check for uncommitted changes
git status

# Load story context
cat docs/backlog/functional/US-042-*.md
```

## Session Recovery

If session file exists but branch doesn't:

```
⚠️ Session branch not found

Stored: feature/#42-oauth-login
Available: main, feature/#43-profile

Options:
1. Switch to stored ticket: /work #42
2. Work on different ticket: /work #XX
3. View status: /status
```

## Multi-project

Session is per-project (stored in project's `.claude/`).
Each project maintains independent session state.
