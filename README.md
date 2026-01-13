# Claude Workflow

A complete development workflow plugin for Claude Code. Manage stories, sprints, commits, PRs, releases, and environments — all with anti-vibe-code guards to keep your project organized.

## Features

- **Story Management**: Create and track User Stories, Technical Stories, and UX Stories
- **Sprint Planning**: Plan, start, lock, and close sprints
- **Git Flow**: Structured branching with ticket tracking
- **Anti-Vibe-Code Guards**: Prevent untracked code from being written
- **Automated Commits**: Conventional commits with ticket references
- **PR Generation**: Rich PR descriptions with test plans
- **Release Management**: Changelog generation and GitHub releases
- **Environment Management**: Deploy to staging/production with safeguards
- **Technical Debt Tracking**: Budget-based debt management
- **Session Persistence**: Resume where you left off

## Installation

```bash
# From Claude Code (when available in marketplace)
claude plugin install workflow

# Manual installation
git clone https://github.com/leto/claude-workflow.git ~/.claude/plugins/workflow
```

## Quick Start

```bash
/init                    # Initialize project
/story "User login"      # Create story
/work #42                # Start working
/done                    # Complete (commit + PR)
/status                  # Check status
```

## Commands

| Command | Description |
|---------|-------------|
| `/init` | Initialize project with full workflow |
| `/story` | Create a new story (US/TS/UX) |
| `/sprint` | Manage sprints (plan/start/lock/close) |
| `/work #XX` | Start working on a ticket |
| `/done` | Complete work (commit + PR + update) |
| `/commit` | Create conventional commit |
| `/pr` | Create or review pull requests |
| `/release` | Create release with changelog |
| `/env` | Manage environments |
| `/status` | Show project status |
| `/sync` | Verify code ↔ docs sync |
| `/debt` | Manage technical debt |
| `/decision` | Track architectural decisions |
| `/ux` | Manage UX artifacts |
| `/bye` | End session gracefully |

## Anti-Vibe-Code Guards

Automatic guards prevent workflow violations:

- **Story Guard**: Blocks code in `apps/` without ticket branch
- **Merge Guard**: Prevents merging `poc/*` and `vibe/*` branches
- **Sprint Lock**: Only fixes allowed during sprint lock

## Branch Strategy

| Type | Pattern | Mergeable | Ticket |
|------|---------|-----------|--------|
| Feature | `feature/#XX-desc` | ✅ | ✅ |
| Fix | `fix/#XX-desc` | ✅ | ✅ |
| Technical | `tech/#XX-desc` | ✅ | ✅ |
| POC | `poc/desc` | ❌ | ❌ |
| Vibe | `vibe/desc` | ❌ | ❌ |

## Project Structure

```
project/
├── docs/
│   ├── backlog/
│   │   ├── functional/     # US-XXX
│   │   ├── technical/      # TS-XXX
│   │   └── ux/             # UX-XXX
│   ├── sprints/
│   ├── PROJECT.md
│   ├── PERSONAS.md
│   └── UX.md
├── records/decisions/
├── apps/
├── .claude/
│   ├── session.json
│   └── environments.json
└── CLAUDE.md
```

## Requirements

- Claude Code CLI
- Git
- GitHub CLI (`gh`)

## License

MIT
