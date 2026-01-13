---
description: Create a new story (User Story, Technical Story, or UX Story). Use when adding features to the backlog.
argument-hint: [type] [title]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh issue:*)
---

# /story - Create Story

Create a new story in the backlog.

## Usage

```
/story                     # Interactive mode
/story "Login with Google" # Quick creation
/story tech "Migrate to Fastify"  # Technical story
/story ux "Redesign onboarding"   # UX story
```

## Workflow

### 1. Determine Story Type

- **User Story (US-XXX)**: User-facing feature
- **Technical Story (TS-XXX)**: Technical work (refactor, migration, setup)
- **UX Story (UX-XXX)**: Design/UX changes

### 2. Gather Information

For User Story:
- "As a [persona], I want [action] so that [benefit]"
- Acceptance criteria
- Affected apps

For Technical Story:
- Objective
- Scope and impact
- Justification (may create ADR)

For UX Story:
- Current state
- Proposed changes
- Impacted user stories

### 3. Create Files

Create in `docs/backlog/[type]/`:
```markdown
# [TYPE]-XXX: Title

## Description
...

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Status: Draft

## Metadata
- Created: YYYY-MM-DD
- Sprint: (unassigned)
- Estimate: (unestimated)
```

### 4. Update Index

Add to `docs/backlog/_INDEX.md`

### 5. Propose Next Steps

- "Create GitHub issue?"
- "Add to current sprint?"
- "Define technical tasks?"

## Auto-numbering

Read existing stories to determine next number:
- US-001, US-002, US-003...
- TS-001, TS-002...
- UX-001, UX-002...
