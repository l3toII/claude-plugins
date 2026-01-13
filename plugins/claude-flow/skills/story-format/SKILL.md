---
name: story-format
description: Story templates for User Stories, Technical Stories, and UX Stories. Use when creating backlog items.
---

# Story Formats

Templates for different story types.

## User Story (US-XXX)

```markdown
# US-XXX: Short Title

## User Story
As a [persona],
I want [action/feature],
So that [benefit/value].

## Description
Additional context and details about the feature.

## Acceptance Criteria
- [ ] Criterion 1: Specific, testable condition
- [ ] Criterion 2: Another condition
- [ ] Criterion 3: Edge case handling

## Technical Notes
- Affected apps: api, web
- Dependencies: US-040 must be done first
- API changes: New endpoint needed

## UX Notes
- Wireframe: (link if available)
- Design tokens: Use primary button style

## Status: Draft | Ready | In Progress | Review | Done

## Metadata
- Created: YYYY-MM-DD
- Sprint: SPRINT-XXX (or unassigned)
- Estimate: S/M/L or story points
- Priority: High/Medium/Low
```

## Technical Story (TS-XXX)

```markdown
# TS-XXX: Short Title

## Objective
Clear statement of what needs to be done and why.

## Scope
- What's included
- What's explicitly excluded

## Justification
Why this work is necessary:
- Performance improvement
- Security fix
- Technical debt reduction
- Enabling future features

## Approach
High-level technical approach.

## Impact Analysis
- Affected modules: list them
- Breaking changes: yes/no
- Migration needed: yes/no

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Related ADR
(Link to ADR if architectural decision)

## Status: Draft | Ready | In Progress | Review | Done

## Metadata
- Created: YYYY-MM-DD
- Sprint: SPRINT-XXX
- Estimate: S/M/L
- Priority: High/Medium/Low
```

## UX Story (UX-XXX)

```markdown
# UX-XXX: Short Title

## Current State
Description of current UX and its problems.

## Proposed Change
What UX changes are proposed.

## Rationale
Why this change improves UX:
- User feedback
- Analytics data
- Best practices

## Affected User Stories
- US-XXX: Will need updates
- US-YYY: New story needed

## Design Assets
- Wireframe: (link)
- Mockup: (link)
- Prototype: (link)

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Status: Draft | Ready | In Progress | Review | Done

## Metadata
- Created: YYYY-MM-DD
- Persona affected: Primary/Secondary
```

## Status Transitions

```
Draft → Ready → In Progress → Review → Done
         ↑                        ↓
         └────────────────────────┘
              (if changes needed)
```

## Numbering

Auto-increment within type:
- US-001, US-002, US-003...
- TS-001, TS-002...
- UX-001, UX-002...
