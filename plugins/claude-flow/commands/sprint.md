---
description: Manage sprints - plan, start, lock, close. View sprint status and progress.
argument-hint: [action]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh:*)
---

# /sprint - Sprint Management

Manage development sprints.

## Usage

```
/sprint                # Show current sprint status
/sprint plan          # Plan next sprint
/sprint start         # Start planned sprint
/sprint lock          # Lock sprint (fixes only)
/sprint unlock        # Unlock sprint
/sprint close         # Close sprint
```

## Commands

### /sprint (status)

Display current sprint:
- Sprint name and dates
- Stories with status (To Do, In Progress, Review, Done)
- Progress percentage
- Blockers and risks

### /sprint plan

1. Show Ready stories from backlog
2. Select stories for sprint
3. Verify dependencies
4. Create sprint file: `docs/sprints/SPRINT-XXX.md`
5. Create GitHub Milestone

### /sprint start

1. Verify sprint is planned
2. Set status to Active
3. Update story statuses to "To Do"
4. Announce sprint start

### /sprint lock

1. Set status to Locked
2. Only fix/ branches allowed
3. Announce lock (pre-release)

### /sprint unlock

1. Remove Locked status
2. Return to Active

### /sprint close

1. Verify all stories Done
2. Move incomplete stories back to backlog
3. Set status to Closed
4. Generate sprint summary
5. Propose release

## Sprint File Structure

```markdown
# SPRINT-XXX: Name

## Duration
- Start: YYYY-MM-DD
- End: YYYY-MM-DD

## Status: Planned | Active | Locked | Closed

## Stories
| ID | Title | Status | Assignee |
|----|-------|--------|----------|
| US-042 | Login OAuth | In Progress | - |

## Goals
1. Goal 1
2. Goal 2

## Retrospective
(filled at close)
```
