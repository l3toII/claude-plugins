---
description: Initialize a new project with the complete workflow. Creates structure, questionnaires, and initial backlog.
allowed-tools: Read, Write, Edit, Bash(git:*), Bash(mkdir:*), Bash(npm:*), Glob, Grep
---

# /init - Project Initialization

Guide the user through complete project initialization.

## Phase 1: Base Structure

Create the monorepo structure:
```
project/
├── docs/
│   ├── backlog/
│   │   ├── functional/
│   │   ├── technical/
│   │   └── ux/
│   ├── sprints/
│   └── architecture/
├── apps/
├── records/
│   └── decisions/
└── .claude/
```

Create CLAUDE.md as entry point.

## Phase 2: Questionnaires

Ask questions to create:

1. **PROJECT.md**: name, vision, objectives, constraints
2. **PERSONAS.md**: users, context, frustrations, goals
3. **UX.md**: visual mood, inspirations, brand guidelines

## Phase 3: V1 Milestone

1. Identify ALL User Stories for V1
2. Organize into estimated sprints
3. Define dependencies
4. Set Sprint 1 stories to Ready

## Phase 4: Tech Stack

Create **STACK.md** based on needs and `.claude/environments.json`.

## Phase 5: Finalization

1. Create Makefile
2. Create README.md
3. Create GitHub templates
4. Git init + first commit

## Rule

> ⚠️ **Complete V1 Milestone BEFORE any code**
