---
description: Track architectural decisions. Create, list, and resolve decisions. Generate ADRs.
argument-hint: [action] [D-XXX]
allowed-tools: Read, Write, Edit, Glob, Grep
---

# /decision - Decision Tracking

Track and document architectural decisions.

## Usage

```
/decision              # List pending decisions
/decision list         # Same as above
/decision new "topic"  # Create new decision
/decision take D-001   # Make a decision
/decision adr D-001    # Generate ADR from decision
```

## /decision list

```
📋 Pending Decisions

D-001: State Management Library (12 days pending)
├── Options: Redux, Zustand, Jotai
├── Impact: High
└── Deadline: 2025-01-15

D-002: API Versioning Strategy (5 days pending)
├── Options: URL path, Header, Query param
├── Impact: Medium
└── Deadline: 2025-01-20

💡 D-001 is overdue. Consider making a decision today.
```

## /decision new "topic"

Create decision in `records/decisions/`:

```markdown
# D-003: Database Migration Strategy

## Status: Pending

## Context
Need to decide how to handle database schema migrations.

## Options

### Option A: Prisma Migrate
- Pros: Integrated with ORM, type-safe
- Cons: Vendor lock-in

### Option B: Raw SQL migrations
- Pros: Full control, portable
- Cons: More manual work

### Option C: Flyway
- Pros: Industry standard, CI-friendly
- Cons: Java dependency

## Impact: High
## Deadline: 2025-01-20
## Decision: (pending)
## Rationale: (pending)
```

## /decision take D-001

Interactive decision-making:

1. Review options
2. Discuss trade-offs
3. Make decision
4. Document rationale
5. Update status to "Decided"

## /decision adr D-001

Generate Architecture Decision Record:

```markdown
# ADR-001: Use Zustand for State Management

## Status: Accepted

## Context
Need lightweight state management for React app.

## Decision
Use Zustand for state management.

## Rationale
- Minimal boilerplate
- Good TypeScript support
- Small bundle size
- Simple API

## Consequences
- Team needs to learn Zustand patterns
- Less ecosystem than Redux
- Consider Redux for very complex state

## Date: 2025-01-12
```

Save to `records/decisions/adr/ADR-XXX-*.md`
