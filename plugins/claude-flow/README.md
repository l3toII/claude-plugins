# Claude Flow

A complete development workflow plugin for Claude Code. Manage stories, sprints, commits, PRs, releases, and environments — all with anti-vibe-code guards to keep your project organized.

## Features

- **Unified Stories (S-XXX)**: Single format for functional, technical, and UX stories
- **Story → Tickets → PRs**: One story creates tickets per app, each becomes a PR
- **Independent Git Per App**: Each app is autonomous with its own repository
- **Quality Gates**: Coverage, lint, tests, security checks per app
- **dev-agent**: Autonomous agent to implement stories
- **Anti-Vibe-Code Guards**: Prevent untracked code from being written
- **Secret Detection**: Warns about potential secrets before writing files
- **Automated Commits**: Conventional commits with ticket references
- **PR Generation**: Rich PR descriptions with test plans
- **Release Management**: Changelog generation and GitHub releases
- **Environment Management**: Deploy to staging/production with safeguards

## Installation

```bash
# From Claude Code marketplace
claude plugin install claude-flow

# Manual installation
git clone https://github.com/l3toII/claude-flow.git ~/.claude/plugins/claude-flow
```

## Quick Start

```bash
/init                    # Initialize project
/story "User login"      # Create story → creates tickets per app
/work S-042 --app api    # Start working on API implementation
# dev-agent implements the ticket
/done                    # Complete (commit + PR in app repo)
/status                  # Check status
```

## Architecture

```
PRINCIPAL REPO (orchestration)
├── project/
│   ├── backlog/S-XXX.md     # Stories (unified format)
│   └── sprints/
├── apps/
│   ├── api/ (.git)          # Independent repo
│   │   └── .claude/quality.json
│   ├── web/ (.git)          # Independent repo
│   │   └── .claude/quality.json
│   └── devops/              # Part of principal repo
└── engineering/
```

## Story → Ticket → PR Flow

```
Story S-042 (principal repo, issue #42)
│
├── Ticket api#15 ──▶ /work S-042 --app api ──▶ PR in api repo
│
└── Ticket web#23 ──▶ /work S-042 --app web ──▶ PR in web repo
│
When all tickets done → Story S-042 = Done
```

## Commands

| Command | Description |
|---------|-------------|
| `/init` | Initialize new project (creates .git per app) |
| `/onboard` | Onboard existing project (cleans root, creates .git per app) |
| `/story` | Create story → GitHub issues in principal + app repos |
| `/sprint` | Manage sprints (plan/start/lock/close) |
| `/work S-XXX --app name` | Start working on ticket in specific app |
| `/done` | Complete work (quality checks + PR in app repo) |
| `/commit` | Create conventional commit |
| `/pr` | Create or review pull requests |
| `/release` | Create release with changelog |
| `/env` | Manage environments |
| `/status` | Show project status |
| `/sync` | Verify code ↔ docs sync |
| `/bye` | End session gracefully |

## Agents

| Agent | Trigger | Purpose |
|-------|---------|---------|
| `init-agent` | `/init` | Full project setup with questionnaire |
| `onboard-agent` | `/onboard` | Transform existing codebase |
| `dev-agent` | `/work` (optional) | Implement story ticket |
| `review-agent` | `/pr review` | Code review |
| `sync-agent` | `/sync` | Verify code ↔ docs |
| `release-agent` | `/release` | Manage releases |

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

`/done` enforces these before creating PR.

## Anti-Vibe-Code Guards

Automatic guards prevent workflow violations:

- **Story Guard**: Blocks commits without ticket branch
- **Merge Guard**: Prevents merging `poc/*` and `vibe/*` branches
- **Root Whitelist**: Blocks forbidden files at root
- **Secret Warning**: Warns about potential secrets in code

## Project Structure

After `/init` or `/onboard`:

```
project/
├── apps/
│   ├── [app-name]/          # Each app has .git
│   │   ├── .git/
│   │   ├── .claude/quality.json
│   │   ├── src/
│   │   ├── package.json     # Self-contained
│   │   ├── tsconfig.json    # No extends
│   │   └── README.md
│   └── devops/              # No .git (principal repo)
│       ├── docker/
│       ├── env/
│       └── scripts/
├── project/
│   ├── vision.md
│   ├── personas.md
│   ├── backlog/S-XXX.md     # Unified stories
│   └── sprints/
├── engineering/
│   ├── stack.md
│   ├── architecture.md
│   └── decisions/
├── .claude/
├── CLAUDE.md
├── README.md
├── Makefile
└── package.json             # Workspace only
```

## Root Whitelist

Only these files allowed at root:

| Allowed | Forbidden (must move) |
|---------|----------------------|
| `apps/` | `src/`, `lib/` → `apps/[name]/` |
| `project/` | `tsconfig.json` → `apps/[name]/` |
| `engineering/` | `.eslintrc*` → `apps/[name]/` |
| `docs/` | `Dockerfile` → `apps/devops/docker/` |
| `.claude/` | `.env*` → `apps/devops/env/` |
| `CLAUDE.md`, `README.md` | `node_modules/` → DELETE |
| `Makefile`, `package.json` | `*.lock` → DELETE |

## Requirements

- Claude Code CLI
- Git
- GitHub CLI (`gh`)
- Node.js (for npm projects)

## Documentation

See `doc/` folder:
- `00-FOUNDATIONS.md` - Core principles
- `01-ARCHITECTURE.md` - Plugin structure
- `02-INTERACTIONS.md` - Command flows

## License

MIT
