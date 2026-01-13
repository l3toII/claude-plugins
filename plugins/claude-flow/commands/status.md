---
description: Show complete project status - sprint, stories, PRs, environments, debt.
argument-hint: [section]
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(gh:*)
---

# /status - Project Status

Display comprehensive project status.

## Usage

```
/status              # Full status
/status sprint       # Sprint only
/status debt         # Technical debt only
```

## Output

```
📊 Project Status

🏃 Sprint: SPRINT-003 (Day 5/10)
├── Progress: 60% (6/10 stories)
├── To Do: 2
├── In Progress: 2
├── Review: 1
├── Done: 5
└── Blockers: None

📋 Current Work
├── Branch: feature/#42-oauth-login
├── Story: US-042 OAuth Login
└── Status: In Progress

🔄 Pull Requests
├── #123 feat(auth): OAuth login - Awaiting review
└── #120 fix(api): session timeout - Approved ✅

🌐 Environments
├── API
│   ├── staging: v1.3.0-beta.1 ✅
│   └── production: v1.2.0 ✅
└── Web
    ├── staging: v2.1.0-beta.2 ✅
    └── production: v2.0.0 ✅

⚠️ Technical Debt: 6/10
├── TD-001: Add input validation (medium)
├── TD-002: Refactor auth module (high)
└── 4 more...

📝 Pending Decisions
└── D-001: Choose state management (7 days)

💡 Suggested Next Actions
1. Complete US-042 OAuth Login
2. Review PR #123
3. Address TD-002 before next sprint
```

## Data Sources

- Sprint: `docs/sprints/SPRINT-*.md`
- Stories: `docs/backlog/**/*.md`
- Session: `.claude/session.json`
- PRs: `gh pr list`
- Environments: `.claude/environments.json`
- Debt: `docs/backlog/technical/TD-*.md`
- Decisions: `records/decisions/*.md`

## Sync Check

Also verify code ↔ docs sync:
- Code without stories?
- Stories without code?
- Outdated architecture docs?

Report discrepancies.
