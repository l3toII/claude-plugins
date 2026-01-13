---
description: Verify synchronization between code and documentation. Detect vibe code and outdated docs.
argument-hint: [--fix]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*)
---

# /sync - Code ↔ Docs Synchronization

Check and fix synchronization between code and documentation.

## Usage

```
/sync              # Full sync check
/sync --fix        # Auto-fix what can be fixed
```

## Checks Performed

### 1. Code Without Stories

Scan `apps/` for modules not tracked in backlog:

```
🔴 ALERT: Untracked Code

apps/api/src/payments/
├── No story references this module
├── Created: 5 days ago
└── Action: Create story or document as existing

Suggestion: /story tech "Document payments module"
```

### 2. Stories Without Code

Stories marked Done but no corresponding code:

```
🟠 WARNING: Stories Without Implementation

US-035: User notifications
├── Status: Done
├── Expected: apps/api/src/notifications/
└── Found: Nothing

Action: Verify implementation or reopen story
```

### 3. Architecture Drift

Compare ARCHITECTURE.md with actual structure:

```
🟠 WARNING: Architecture Drift

ARCHITECTURE.md says:
  apps/api/src/services/

Actual structure:
  apps/api/src/modules/
  
Action: Update ARCHITECTURE.md or refactor
```

### 4. Vibe Code Detection

Look for signs of unplanned code:
- Modules outside documented structure
- Files with no test coverage
- Large uncommitted changes

### 5. Story Status Accuracy

- PRs merged but story not Done?
- Story Done but PR still open?

## Output

```
🔍 Sync Report

✅ Stories ↔ Code: 12/12 synced
⚠️ Architecture drift: 2 discrepancies
🔴 Untracked code: 1 module
✅ Story status: All accurate

Issues to address:
1. [HIGH] apps/payments/ not in backlog
2. [MED] ARCHITECTURE.md outdated

Run /sync --fix to auto-fix what's possible.
```

## Auto-fix (--fix)

- Update story status from PR state
- Generate stub stories for untracked code
- Update ARCHITECTURE.md structure
