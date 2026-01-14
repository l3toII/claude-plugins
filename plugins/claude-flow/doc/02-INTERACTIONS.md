# 02 - Interactions

Complete user flows and command interactions.

## Main Workflow

```
/init → /story → /sprint plan → /work #XX → [code] → /done → /release
```

## Command Reference

### /init - Project Initialization

**Purpose**: Set up a new project with full workflow structure.

**Flow**:
```
User: /init

Claude: [Creates branch: tech/init-project]
        "Let's initialize your project.
        What is the project name and vision?"

User: "TaskFlow - a task management app for teams"

Claude: [Creates structure]
        [Asks about personas]
        [Asks about UX direction]
        [Identifies V1 stories]
        [Creates sprint plan]
        [Asks about tech stack]
        [Generates files]
        [Commits on tech/init-project]
        [Creates PR → main]

Output:
├── apps/
│   └── devops/ (docker, env, scripts)
├── project/
│   ├── vision.md
│   ├── personas.md
│   ├── ux.md
│   ├── backlog/functional/US-001.md ... US-012.md
│   └── sprints/SPRINT-001.md
├── engineering/
│   ├── stack.md
│   ├── architecture.md
│   └── decisions/
├── docs/
├── .gitignore
├── CLAUDE.md
├── Makefile
└── package.json (workspace only, NO deps)

Branch: tech/init-project → main (PR)
```

> ⚠️ Changes are on a dedicated branch. Merge the PR after reviewing the structure.
> 🐳 apps/devops/ is always created with Docker, env, and scripts folders.

---

### /onboard - Onboard Existing Project

**Purpose**: Transform existing codebase into clean workflow structure (identical to /init result).

**Usage**:
```bash
/onboard              # Standard onboarding
/onboard --full       # Full onboarding with backlog generation
```

**Core Principle**: Whitelist approach - only specific files allowed at root.

**Flow**:
```
User: /onboard

Claude: [Creates branch: tech/onboard-workflow]

        "🔍 ROOT CLEANUP REPORT

         ✅ WHITELIST (keep): .git/, README.md, LICENSE, .github/

         🚚 CODE → apps/core/: src/, lib/, index.ts
         ⚙️ CONFIG-APP → apps/core/: tsconfig.json, .eslintrc, .prettierrc, vite.config.ts
         🐳 DEVOPS → apps/devops/: Dockerfile, docker-compose.yml, .env*
         🗑️ DELETE (monorepo): turbo.json, pnpm-workspace.yaml
         🗑️ DELETE (regenerable): node_modules/, package-lock.json, dist/
         📦 ARCHIVE → docs/archive/: CHANGELOG.md

         1. AUTO-CLEAN (recommended)
         2. REVIEW ONE BY ONE
         3. SKIP"

User: "1"

Claude: [Creates apps/devops/ structure]
        [Moves code to apps/core/]
        [Moves Docker/.env to apps/devops/]
        [Deletes node_modules/]
        [Archives old docs]
        [Creates workflow docs from analysis]
        [Commits on tech/onboard-workflow]
        [Creates PR → main]

Output (CLEAN pilot repo):
├── apps/
│   ├── devops/ (docker/, env/, scripts/)
│   ├── core/ (moved from root, with tsconfig, eslint, etc.)
│   └── api/
├── project/ (vision, personas, ux, backlog/, sprints/)
├── engineering/ (stack, architecture, decisions/)
├── docs/ (public docs, archive/)
├── .claude/
├── .gitignore
├── CLAUDE.md
├── README.md
├── Makefile
└── package.json (workspace only, NO deps)

Branch: tech/onboard-workflow → main (PR)
```

**Key Rules**:
- ✅ Whitelist approach: only allowed files stay at root
- 🐳 DevOps files → apps/devops/ (Docker, .env, scripts)
- 🚚 Code files → apps/[name]/
- ⚙️ Config files → apps/[name]/ (tsconfig, eslint, prettier, vite, etc.)
- 🗑️ Regenerable files deleted (node_modules, locks, dist)
- 🗑️ Monorepo tools deleted (turbo.json, nx.json - use Makefile)
- 📁 Legacy docs archived to docs/archive/
- ⚠️ User confirmation MANDATORY for all actions
- 🎯 End result identical to fresh /init

> ⚠️ Review carefully - structural changes included.

---

### /story - Create Story

**Purpose**: Add a new story to the backlog.

**Usage**:
```bash
/story                          # Interactive
/story "Add user login"         # Quick user story
/story tech "Migrate to v2"     # Technical story
/story ux "Redesign dashboard"  # UX story
```

**Flow**:
```
User: /story "OAuth login with Google"

Claude: [Determines type: User Story]
        [Asks for acceptance criteria]
        [Creates US-042-oauth-login.md]
        [Updates backlog index]

Output: docs/backlog/functional/US-042-oauth-login.md
```

---

### /sprint - Sprint Management

**Purpose**: Plan, start, lock, and close sprints.

**Usage**:
```bash
/sprint              # Show current status
/sprint plan         # Plan next sprint
/sprint start        # Activate planned sprint
/sprint lock         # Lock for release (fixes only)
/sprint close        # Close and retrospect
```

**Flow**:
```
User: /sprint plan

Claude: [Shows Ready stories]
        "Select stories for Sprint 4:
         □ US-042 OAuth Login (5 pts)
         □ US-043 User Profile (3 pts)
         □ US-044 Settings Page (2 pts)"

User: "42, 43, 44"

Claude: [Creates SPRINT-004.md]
        [Sets stories to sprint]
        [Creates GitHub milestone]
```

---

### /work - Start Working

**Purpose**: Begin work on a specific ticket.

**Usage**:
```bash
/work #42            # Work on ticket 42
/work US-042         # Work on user story
/work                # Continue previous work
```

**Flow**:
```
User: /work #42

Claude: [Reads US-042 from backlog]
        [Creates branch: feature/#42-oauth-login]
        [Updates session.json]
        [Shows acceptance criteria]

        "Ready to work on US-042: OAuth Login

         Acceptance Criteria:
         □ User can click 'Login with Google'
         □ OAuth flow completes successfully
         □ User session is created
         □ Profile shows Google avatar

         Suggested approach:
         1. Add GoogleAuthService
         2. Create OAuth callback route
         3. Update login page"
```

---

### /done - Complete Work

**Purpose**: Finish current work with commit, PR, and story update.

**Usage**:
```bash
/done                # Full workflow
/done --no-pr        # Commit only
/done --draft        # Create draft PR
```

**Flow**:
```
User: /done

Claude: [Runs: make lint-api && make test-api]
        ✅ Lint passed
        ✅ Tests passed (47/47)

        [Applies commit-conventions skill]
        [Generates: feat(auth): add OAuth login (#42)]

        [Commits and pushes]
        ✅ Committed: feat(auth): add OAuth login (#42)

        [Applies pr-template skill]
        [Creates PR via gh]
        ✅ PR #123 created

        [Updates story status]
        ✅ US-042: In Progress → Review

        "Work completed!
         📝 Commit: feat(auth): add OAuth login (#42)
         🔗 PR #123: https://github.com/.../pull/123
         📋 Story US-042 now in Review"
```

---

### /commit - Create Commit

**Purpose**: Create a conventional commit (intermediate commits).

**Usage**:
```bash
/commit                  # Auto-generate message
/commit "custom msg"     # With message
/commit --amend          # Amend last commit
```

---

### /pr - Pull Request Management

**Purpose**: Create or review pull requests.

**Usage**:
```bash
/pr                      # Create PR for current branch
/pr review #123          # Review PR
/pr merge #123           # Merge PR
```

---

### /release - Create Release

**Purpose**: Create versioned release with changelog.

**Usage**:
```bash
/release                 # Release all apps
/release api             # Release specific app
/release --dry-run       # Preview only
```

**Flow**:
```
User: /release

Claude: [Checks all stories Done]
        [Determines version: 1.2.0 → 1.3.0 (minor)]
        [Updates CHANGELOG.md]
        [Creates tag: v1.3.0]
        [Creates GitHub release]
        [Deploys to staging]

        "Release v1.3.0 created!
         📝 Changelog updated
         🏷️ Tag: v1.3.0
         🚀 Staging: https://api-staging.example.com"
```

---

### /env - Environment Management

**Purpose**: Manage local and remote environments using apps/devops/.

**Usage**:
```bash
/env                          # Show all status
/env local                    # Start local dev (docker-compose)
/env local down               # Stop local dev
/env deploy api staging       # Deploy to staging
/env deploy api production    # Deploy to prod (confirmation)
/env logs api staging         # View logs
/env rollback api staging     # Rollback
```

**Local Development Flow**:
```
User: /env local

Claude: [Runs: cd apps/devops/docker && docker-compose up -d]

        "📊 Local Environment Started

         LOCAL (apps/devops/docker)
         ├── api:  running ✅ (localhost:3000)
         ├── web:  running ✅ (localhost:5173)
         └── db:   running ✅ (localhost:5432)

         Use 'make logs' to view logs
         Use '/env local down' to stop"
```

**Makefile Integration**:
```bash
make up       # → cd apps/devops/docker && docker-compose up -d
make down     # → cd apps/devops/docker && docker-compose down
make logs     # → cd apps/devops/docker && docker-compose logs -f
```

---

### /status - Project Status

**Purpose**: Show comprehensive project status.

**Output**:
```
📊 Project Status

🏃 Sprint: SPRINT-003 (Day 5/10)
├── Progress: 60% (6/10 stories)
├── In Progress: 2
├── Review: 1
└── Done: 5

📋 Current Work
├── Branch: feature/#42-oauth-login
└── Story: US-042 OAuth Login

🔄 Pull Requests
├── #123 OAuth login - Awaiting review
└── #120 Session fix - Approved ✅

⚠️ Technical Debt: 6/10
```

---

### /sync - Verify Synchronization

**Purpose**: Check code ↔ docs consistency.

**Output**:
```
🔍 Sync Report

✅ Stories ↔ Code: 12/12 synced
⚠️ Architecture drift: 2 discrepancies
🔴 Untracked code: 1 module (apps/payments/)

Run /sync --fix to auto-fix.
```

---

### /debt - Technical Debt

**Purpose**: Manage technical debt budget.

**Usage**:
```bash
/debt                    # Show status
/debt add "reason"       # Add debt ticket
/debt plan               # Plan debt sprint
```

---

### /decision - Decision Tracking

**Purpose**: Track architectural decisions.

**Usage**:
```bash
/decision                # List pending
/decision new "topic"    # Create decision
/decision take D-001     # Make decision
/decision adr D-001      # Generate ADR
```

---

### /ux - UX Management

**Purpose**: Manage UX artifacts.

**Usage**:
```bash
/ux                      # Show UX status
/ux persona              # Create/edit persona
/ux journey              # Create user journey
/ux review               # Anti-slop review
```

---

### /bye - End Session

**Purpose**: End session gracefully.

**Flow**:
```
User: /bye

Claude: [Checks uncommitted changes]
        [Saves session.json]

        "Session Summary
         Duration: 2h 15m
         Completed: US-042 OAuth Login
         PR #123 awaiting review

         Next session:
         1. Check PR feedback
         2. Continue US-043

         See you! 👋"
```

## Guard Interactions

### Story Guard (Blocking)

```
User: [Edits apps/api/src/payments/service.ts]
      [On branch: my-feature (no ticket)]

Hook: guard-story-exists.sh
      Exit code: 2

Claude: "❌ BLOCKED: Code modified without ticket

         You're on branch 'my-feature'.
         Options:
         1. /story 'Add payments'
         2. /work #XX
         3. Create poc/ branch for exploration"
```

### Merge Guard (Blocking)

```
User: "Merge my POC branch"

Claude: [Runs: git merge poc/test-graphql]

Hook: guard-branch-check.sh
      Exit code: 2

Claude: "❌ BLOCKED: poc/ branches cannot be merged

         If the POC is successful:
         /story 'Integrate GraphQL API'"
```

### Sprint Lock (Warning)

```
User: [On feature/#45-*, sprint is Locked]

Claude: "⚠️ Sprint is locked for release.
         Only fix/ branches can commit.

         For urgent fix: /work #XX (fix ticket)"
```
