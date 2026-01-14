# 01 - Architecture

Technical architecture of the Claude Flow plugin.

## Plugin Structure

```
claude-flow/
├── plugin.json               # Plugin manifest
├── .mcp.json                 # MCP servers (memory)
├── commands/                 # Slash commands
│   ├── init.md              # Project initialization
│   ├── onboard.md           # Existing project onboarding
│   ├── story.md             # Create story → tickets
│   ├── sprint.md
│   ├── work.md              # Start working on ticket
│   ├── done.md              # Complete with quality checks
│   ├── commit.md
│   ├── pr.md
│   ├── release.md
│   ├── env.md
│   ├── status.md
│   ├── sync.md
│   ├── debt.md
│   ├── decision.md
│   ├── ux.md
│   └── bye.md
├── agents/                   # Autonomous agents
│   ├── init-agent.md        # Project setup
│   ├── onboard-agent.md     # Transform existing code
│   ├── dev-agent.md         # Implement tickets
│   ├── review-agent.md      # Code review
│   ├── sync-agent.md        # Verify code ↔ docs
│   ├── release-agent.md     # Manage releases
│   └── migration-agent.md   # Complex migrations
├── skills/                   # Knowledge skills
│   ├── story-format/        # Unified S-XXX format
│   ├── quality-gates/       # Coverage, lint, tests
│   ├── apps-structure/      # Independent git per app
│   ├── git-conventions/     # Branch, commit patterns
│   ├── commit-conventions/
│   ├── pr-template/
│   ├── code-conventions/
│   ├── design-principles/
│   ├── github-patterns/
│   ├── devops-structure/
│   └── session-management/
├── hooks/
│   └── hooks.json           # Automatic guards
├── scripts/                  # Hook scripts
│   ├── session-start.sh
│   ├── session-save.sh
│   ├── guard-story-exists.sh
│   ├── guard-branch-check.sh
│   ├── guard-secrets.sh
│   ├── validate-root-whitelist.sh
│   ├── detect-git-conventions.sh
│   ├── get-repo-config.sh
│   └── post-edit-format.sh
└── doc/
    ├── 00-FOUNDATIONS.md
    ├── 01-ARCHITECTURE.md
    └── 02-INTERACTIONS.md
```

## Component Roles

### Commands (Orchestrators)

Commands are explicit entry points that delegate to agents:

```markdown
---
description: Complete current work
context: fork
agent: (none - direct execution)
allowed-tools: Read, Write, Edit, Bash(git:*), Bash(gh:*)
---
```

**Key insight**: Commands orchestrate; complex tasks delegate to agents via `context: fork`.

### Agents (Autonomous Execution)

Agents handle complex multi-step tasks:

```markdown
---
name: dev-agent
description: Implements story ticket
tools: [Read, Write, Edit, Bash, Glob, Grep]
model: sonnet
---

# Responsibilities
1. Understand context
2. Plan implementation
3. Write code and tests
4. Run quality checks
5. Report completion
```

### Skills (Knowledge)

Skills provide conventions and best practices:

```markdown
---
name: story-format
description: Unified S-XXX format
---

# Story (S-XXX)
- Category: functional | technical | ux
- Apps Impacted
- Tickets table
- Acceptance Criteria
```

**Key insight**: Skills are passive knowledge, activated by commands or Claude's judgment.

### Hooks (Automatic Guards)

Hooks run automatically on specific events:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write|Edit",
      "type": "command",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/guard-secrets.sh"
    }]
  }
}
```

**Exit codes**:
- `0`: Allow action
- `2`: Block action (guard triggered)

## Project Structure (Generated)

When `/init` or `/onboard` runs, it creates:

```
project/
├── apps/
│   ├── [app-name]/              # Each app has .git
│   │   ├── .git/                # ✅ REQUIRED - independent repo
│   │   ├── .claude/
│   │   │   └── quality.json     # App-specific quality gates
│   │   ├── src/
│   │   ├── package.json         # Self-contained (no extends)
│   │   ├── tsconfig.json        # Complete config (no extends)
│   │   ├── .eslintrc.cjs        # Complete config (no extends)
│   │   ├── Dockerfile
│   │   ├── .gitignore
│   │   └── README.md
│   │
│   └── devops/                  # NO .git (part of principal repo)
│       ├── docker/
│       │   ├── docker-compose.yml
│       │   └── docker-compose.dev.yml
│       ├── env/
│       │   ├── .env.example
│       │   └── .env.dev
│       └── scripts/
│           ├── setup.sh
│           └── deploy.sh
│
├── project/                     # Project management
│   ├── vision.md
│   ├── personas.md
│   ├── ux.md
│   ├── backlog/
│   │   └── S-XXX-slug.md        # Unified story format
│   └── sprints/
│       └── SPRINT-XXX.md
│
├── engineering/                 # Technical documentation
│   ├── stack.md
│   ├── architecture.md
│   └── decisions/               # ADRs
│
├── docs/
│   ├── api/
│   └── archive/
│
├── .claude/
│   ├── session.json
│   ├── apps.json               # App configurations
│   └── quality.json            # Global quality defaults
│
├── .git/                       # Principal repo
├── .gitignore
├── CLAUDE.md
├── README.md
├── Makefile
└── package.json                # Workspace only (NO deps)
```

## Git Architecture

```
PRINCIPAL REPO (.git/)
├── project/           ──▶ Stories, sprints, vision
├── engineering/       ──▶ Architecture, stack, ADRs
├── docs/
├── apps/
│   ├── devops/       ──▶ Part of principal repo (no .git)
│   │
│   ├── api/
│   │   └── .git/     ──▶ github.com/org/project-api
│   │
│   └── web/
│       └── .git/     ──▶ github.com/org/project-web
```

### Why Independent Git Per App?

1. **Autonomy**: Clone `apps/api` alone and it works
2. **Independent PRs**: Each app has its own PR lifecycle
3. **Story → Tickets**: One story creates tickets per app
4. **Clear ownership**: Issues and PRs are per-app

### Exception: devops/

`apps/devops/` stays in principal repo because:
- Orchestrates other apps
- Contains multi-app config (docker-compose)
- Releases are coordinated at project level

## Root Whitelist

**ONLY these files/folders allowed at root:**

| Item | Purpose |
|------|---------|
| `apps/` | Application code (each with .git) + devops |
| `project/` | Project management (backlog, sprints) |
| `engineering/` | Technical docs (architecture, decisions) |
| `docs/` | Public documentation |
| `.claude/` | Plugin config |
| `.git/` | Principal repository |
| `.gitignore` | Git ignore |
| `.github/` | CI/CD (optional) |
| `CLAUDE.md` | Entry point |
| `README.md` | Overview |
| `LICENSE` | License |
| `Makefile` | Orchestration |
| `package.json` | Workspace only (NO dependencies) |

## Forbidden at Root

| Item | Where it goes |
|------|---------------|
| `tsconfig.json` | `apps/[name]/` (self-contained) |
| `.eslintrc*` | `apps/[name]/` (self-contained) |
| `vite.config.*` | `apps/[name]/` |
| `tailwind.config.*` | `apps/[name]/` |
| `Dockerfile` | `apps/[name]/` or `apps/devops/docker/` |
| `docker-compose.*` | `apps/devops/docker/` |
| `.env*` | `apps/devops/env/` |
| `node_modules/` | DELETE |
| `*.lock` | DELETE |

## No Shared Config

**Each app is 100% autonomous:**

❌ WRONG:
```
apps/config/typescript/base.json  # Shared config
apps/api/tsconfig.json            # extends: "../config/..."
```

✅ CORRECT:
```
apps/api/tsconfig.json            # Complete config, no extends
apps/web/tsconfig.json            # Complete config, no extends
```

## Quality Gates

Each app has `.claude/quality.json`:

```json
{
  "coverage": { "minimum": 80, "enforce": true },
  "lint": { "warnings_allowed": 0 },
  "tests": { "required": true },
  "security": { "block_secrets": false }
}
```

Enforced by `/done` before PR creation.

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      /story "OAuth login"                    │
├─────────────────────────────────────────────────────────────┤
│  1. Create project/backlog/S-042-oauth-login.md             │
│  2. Create GitHub Issue #42 (principal repo)                │
│  3. Create tickets per app:                                  │
│     - api#15 (github.com/org/project-api)                   │
│     - web#23 (github.com/org/project-web)                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  /work S-042 --app api                       │
├─────────────────────────────────────────────────────────────┤
│  1. cd apps/api                                              │
│  2. git checkout -b feature/#15-oauth-login                 │
│  3. Update .claude/session.json                             │
│  4. Optional: delegate to dev-agent                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                         /done                                │
├─────────────────────────────────────────────────────────────┤
│  1. Read apps/api/.claude/quality.json                       │
│  2. Run quality checks (lint, tests, coverage)               │
│  3. Create commit in apps/api                                │
│  4. Create PR in github.com/org/project-api                 │
│  5. Close ticket api#15                                      │
│  6. Update story S-042 (ticket done)                         │
│  7. If all tickets done → Story done, close #42              │
└─────────────────────────────────────────────────────────────┘
```

## Technical Validation

| Component | Status | Notes |
|-----------|--------|-------|
| Hooks auto-merge | ✅ Works | Official docs |
| `${CLAUDE_PLUGIN_ROOT}` | ✅ Works | Variable available |
| Exit code 2 blocks | ✅ Works | Official docs |
| context: fork | ✅ Works | Agent delegation |
| Git per app | ✅ Works | Independent repos |
| Quality gates | ✅ Works | Per-app config |
