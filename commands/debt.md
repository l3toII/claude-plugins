---
description: Manage technical debt. View debt budget, create debt tickets, plan debt sprints.
argument-hint: [action] [reason]
allowed-tools: Read, Write, Edit, Glob, Grep
---

# /debt - Technical Debt Management

Track and manage technical debt.

## Usage

```
/debt                # Show debt status
/debt add "reason"   # Add debt ticket
/debt budget         # Show debt budget
/debt plan           # Plan debt sprint
```

## /debt (status)

```
⚠️ Technical Debt: 7/10 budget

High Priority (3)
├── TD-002: Refactor auth module (7 days old)
├── TD-005: Add input validation (5 days old)
└── TD-007: Fix N+1 queries (3 days old)

Medium Priority (2)
├── TD-003: Update deprecated packages
└── TD-006: Add error boundaries

Low Priority (2)
├── TD-001: Improve logging
└── TD-004: Add performance monitoring

⚠️ Budget at 70%. Consider planning debt sprint.
```

## /debt add "reason"

Create debt ticket when skipping best practices:

```
/debt add "Skipping tests for hotfix - needs tests added"
```

Creates `docs/backlog/technical/TD-XXX.md`:
```markdown
# TD-008: Add tests for hotfix

## Reason
Skipping tests for hotfix - needs tests added

## Created
- Date: 2025-01-12
- Context: Hotfix for production issue
- Related: US-042

## Priority: Medium

## Due: 2025-01-19 (7 days)

## Status: Open
```

## Debt Budget

**Budget: 10 tickets maximum**

| Level | Count | Action |
|-------|-------|--------|
| 0-5   | ✅ | Normal work |
| 6-8   | ⚠️ | Address in next sprint |
| 9-10  | 🔴 | Debt sprint required |
| >10   | 🛑 | BLOCKED - debt sprint mandatory |

## /debt plan

Plan a debt-focused sprint:

1. Prioritize debt tickets
2. Estimate effort
3. Create SPRINT-DEBT-XXX
4. No new features until debt < 5

## Auto-creation

Debt is auto-created when:
- Skipping tests (`/commit --skip-tests`)
- Skipping lint (`/commit --no-lint`)
- TODO/FIXME in code with deadline
- Deprecated package warnings
