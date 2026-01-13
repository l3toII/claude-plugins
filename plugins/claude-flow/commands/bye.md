---
description: End session gracefully. Saves state, shows summary, reminds about pending items.
allowed-tools: Read, Write, Glob, Bash(git:*)
---

# /bye - End Session

End the current session gracefully.

## Usage

```
/bye              # End session with summary
```

## Workflow

### 1. Check Uncommitted Changes

If changes exist:
```
⚠️ You have uncommitted changes:
- apps/api/src/auth/service.ts
- apps/api/src/auth/controller.ts

Commit before leaving? (y/n)
```

If yes: Run /commit flow

### 2. Save Session State

Update `.claude/session.json`:
```json
{
  "last_updated": "2025-01-12T18:00:00Z",
  "active_branch": "feature/#42-oauth-login",
  "active_ticket": "42",
  "last_commit": "abc123 feat(auth): add OAuth service",
  "working_directory": "/path/to/project"
}
```

### 3. Show Session Summary

```
📊 Session Summary

Duration: 2h 15m

Completed:
✅ US-042: OAuth Login - PR created
✅ 3 commits pushed
✅ 142 lines added, 23 removed

Still In Progress:
🔄 US-043: User Profile (In Progress)

Pending Reviews:
👀 PR #123 awaiting review

Reminders:
⚠️ Technical debt: 7/10
⚠️ Decision D-001 overdue
```

### 4. Suggest Next Session

```
💡 Next session suggestions:
1. Continue US-043 User Profile
2. Address PR #123 feedback
3. Review TD-002 debt ticket

See you next time! 👋
```

## Auto-save

Even without /bye, session state is saved on:
- Claude Code exit
- Session timeout
- /clear command
