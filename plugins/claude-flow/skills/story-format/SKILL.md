---
name: story-format
description: Unified story format (S-XXX) for all story types. Use when creating backlog items.
---

# Story Format

Unified format for all stories. Category distinguishes functional, technical, and UX work.

## Story (S-XXX)

```markdown
# S-XXX: Short Title

## Category
functional | technical | ux

## Story
<!-- For functional -->
As a [persona],
I want [action/feature],
So that [benefit/value].

<!-- For technical -->
Objective: [what and why]

<!-- For ux -->
Current state → Proposed change

## Description
Additional context and details.

## Acceptance Criteria
- [ ] Criterion 1: Specific, testable condition
- [ ] Criterion 2: Another condition
- [ ] Criterion 3: Edge case handling

## Apps Impacted
- api
- web

## Tickets
| App | Issue | PR | Status |
|-----|-------|-----|--------|
| api | [#15](link) | [#20](link) | Done |
| web | [#23](link) | - | In Progress |

## Technical Notes
- Dependencies: S-040 must be done first
- API changes: New endpoint needed
- Breaking changes: No

## UX Notes
- Persona: primary-user
- Wireframe: (link if available)
- Design tokens: Use primary button style

## Related
- Parent: (epic if any)
- Blocks: S-045, S-046
- Related ADR: ADR-003

## Status
Draft | Ready | In Progress | Review | Done

## Metadata
- Created: YYYY-MM-DD
- Sprint: SPRINT-XXX (or unassigned)
- Estimate: S/M/L or story points
- Priority: High/Medium/Low
- GitHub Issue: #42 (repo principal)
```

## Status Flow

```
Draft ──▶ Ready ──▶ In Progress ──▶ Review ──▶ Done
                         │              │
                         │   (changes)  │
                         ◀──────────────┘
```

**Status Rules:**
- `Draft`: Story being defined, not ready for sprint
- `Ready`: Acceptance criteria complete, can be planned
- `In Progress`: At least one ticket started
- `Review`: All tickets have PRs, awaiting merge
- `Done`: All tickets merged, acceptance criteria met

## Tickets Lifecycle

```
Story S-042 created
    │
    ▼
/story identifies apps: [api, web]
    │
    ├──▶ Creates api#15 (GitHub Issue in apps/api repo)
    └──▶ Creates web#23 (GitHub Issue in apps/web repo)

/work S-042 (on api)
    │
    ▼
cd apps/api && git checkout -b feature/#15-oauth
    │
    ▼
[development]
    │
    ▼
/done
    │
    ├──▶ PR created in apps/api
    ├──▶ api#15 closed
    └──▶ S-042.md updated (ticket status)

When ALL tickets Done:
    │
    ▼
S-042 status → Done
GitHub Issue #42 (principal) → Closed
```

## Numbering

Single sequence for all stories:
- S-001, S-002, S-003...

No more separate US/TS/UX numbering.

## Category Guidelines

| Category | When to use | Example |
|----------|-------------|---------|
| `functional` | User-facing feature | "Add OAuth login" |
| `technical` | Infrastructure, refactor, perf | "Migrate to Fastify" |
| `ux` | Design, usability improvement | "Redesign onboarding flow" |

## Minimal Story (Quick Create)

For rapid creation, only these are required:
```markdown
# S-XXX: Title

## Category
functional

## Story
As a user, I want X so that Y.

## Acceptance Criteria
- [ ] Main criterion

## Apps Impacted
- api

## Status
Draft
```

Other sections can be added later.
