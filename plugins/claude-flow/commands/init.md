---
description: Initialize a new project with the complete workflow. Creates structure with apps/devops/, questionnaires, and initial backlog.
allowed-tools: Read, Write, Edit, Bash(git:*), Bash(mkdir:*), Bash(npm:*), Glob, Grep, AskUserQuestion
---

# /init - Project Initialization

Guide the user through complete project initialization.

## Phase 0: Setup Git and Branch

> ⚠️ **MANDATORY**: All initialization changes MUST be done on a dedicated branch.

### For new projects (no git):
```bash
git init
git checkout -b tech/init-project
```

### For existing repos:
```bash
git status
git checkout -b tech/init-project
```

---

## Phase 1: Base Structure

Create the complete monorepo structure:

```
project/
├── apps/
│   └── devops/
│       ├── docker/
│       │   └── docker-compose.yml
│       ├── env/
│       │   └── .env.example
│       ├── scripts/
│       │   └── setup.sh
│       └── README.md
├── project/                     # Project management
│   ├── vision.md
│   ├── personas.md
│   ├── ux.md
│   ├── roadmap.md
│   ├── backlog/
│   │   ├── functional/          # US-XXX
│   │   ├── technical/           # TS-XXX
│   │   └── ux/                  # UX-XXX
│   └── sprints/
├── engineering/                 # Technical documentation
│   ├── stack.md
│   ├── architecture.md
│   ├── conventions.md
│   └── decisions/               # ADRs
├── docs/                        # Public documentation
│   ├── api/                     # Generated API docs
│   └── archive/                 # Archived docs
├── .claude/
├── .gitignore
├── CLAUDE.md
├── README.md
├── Makefile
└── package.json (workspace only, NO dependencies)
```

### 1.1 Create Directories

```bash
# Apps structure
mkdir -p apps/devops/docker
mkdir -p apps/devops/env
mkdir -p apps/devops/scripts

# Project management structure
mkdir -p project/backlog/functional
mkdir -p project/backlog/technical
mkdir -p project/backlog/ux
mkdir -p project/sprints

# Engineering structure
mkdir -p engineering/decisions

# Public docs structure
mkdir -p docs/api
mkdir -p docs/archive

# Config
mkdir -p .claude
```

### 1.2 Create apps/devops/ Base Files

**apps/devops/docker/docker-compose.yml:**
```yaml
version: '3.8'

services:
  # Services will be added as apps are created
  # Example:
  # api:
  #   build:
  #     context: ../../api
  #   env_file:
  #     - ../env/.env
  #   ports:
  #     - "3000:3000"
```

**apps/devops/env/.env.example:**
```bash
# Environment variables template
# Copy to .env and fill in values

NODE_ENV=development
# Add app-specific variables below
```

**apps/devops/scripts/setup.sh:**
```bash
#!/bin/bash
# Initial project setup

echo "Setting up project..."

# Copy environment file
if [ ! -f apps/devops/env/.env ]; then
  cp apps/devops/env/.env.example apps/devops/env/.env
  echo "Created .env file - please fill in values"
fi

# Install dependencies for all apps
for dir in apps/*/; do
  if [ -f "$dir/package.json" ] && [ "$dir" != "apps/devops/" ]; then
    echo "Installing dependencies in $dir..."
    (cd "$dir" && npm install)
  fi
done

echo "Setup complete!"
```

**apps/devops/README.md:**
```markdown
# DevOps

Infrastructure and deployment configuration.

## Quick Start

From project root:
```bash
make setup   # Initial setup
make up      # Start all services
make down    # Stop all services
make logs    # View logs
```

## Structure

- `docker/` - Docker Compose configurations
- `env/` - Environment variable templates
- `scripts/` - Automation scripts

## Adding a New Service

1. Create app in `apps/[name]/`
2. Add service to `docker/docker-compose.yml`
3. Add environment variables to `env/.env.example`
```

### 1.3 Create Root Files

**Makefile:**
```makefile
.PHONY: help setup up down logs build test lint

help:
	@echo "Available commands:"
	@echo "  make setup    - Initial project setup"
	@echo "  make up       - Start all services"
	@echo "  make down     - Stop all services"
	@echo "  make logs     - View logs (app=name for specific)"
	@echo "  make build    - Build all apps"
	@echo "  make test     - Run all tests"

setup:
	chmod +x apps/devops/scripts/*.sh
	./apps/devops/scripts/setup.sh

up:
	cd apps/devops/docker && docker-compose up -d

down:
	cd apps/devops/docker && docker-compose down

logs:
	cd apps/devops/docker && docker-compose logs -f $(app)

build:
	@for dir in apps/*/; do \
		if [ -f "$$dir/package.json" ] && [ "$$dir" != "apps/devops/" ]; then \
			echo "Building $$dir..."; \
			(cd "$$dir" && npm run build); \
		fi \
	done

test:
	@for dir in apps/*/; do \
		if [ -f "$$dir/package.json" ] && [ "$$dir" != "apps/devops/" ]; then \
			echo "Testing $$dir..."; \
			(cd "$$dir" && npm test); \
		fi \
	done

test-%:
	cd apps/$* && npm test

lint-%:
	cd apps/$* && npm run lint

build-%:
	cd apps/$* && npm run build
```

**package.json (workspace only):**
```json
{
  "name": "project-workspace",
  "private": true,
  "workspaces": ["apps/*"],
  "scripts": {
    "setup": "make setup",
    "dev": "make up",
    "build": "make build",
    "test": "make test"
  }
}
```

**.gitignore:**
```gitignore
# Dependencies
node_modules/
.pnpm-store/

# Build
dist/
build/
.next/

# Environment (keep examples)
apps/devops/env/.env
apps/devops/env/.env.local
apps/devops/env/.env.*.local
!apps/devops/env/.env.example

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Test
coverage/
```

**CLAUDE.md:**
```markdown
# [Project Name]

## Quick Start

```bash
make setup   # Initial setup
make up      # Start services
make test    # Run tests
```

## Structure

- `apps/` - Application code
  - `devops/` - Docker, env, scripts
  - `[name]/` - Each app with its own config (tsconfig, eslint, etc.)
- `project/` - Project management
  - `backlog/` - User/Tech/UX stories
  - `sprints/` - Sprint plans
  - `vision.md`, `personas.md`, `ux.md`
- `engineering/` - Technical documentation
  - `stack.md`, `architecture.md`
  - `decisions/` - ADRs
- `docs/` - Public documentation

## Workflow

This project uses claude-flow.

Commands: `/story`, `/sprint`, `/work`, `/done`, `/release`
```

---

## Phase 2: Questionnaires

Ask questions to create:

1. **project/vision.md**: name, vision, objectives, constraints
2. **project/personas.md**: users, context, frustrations, goals
3. **project/ux.md**: visual mood, inspirations, brand guidelines

---

## Phase 3: V1 Milestone

1. Identify ALL User Stories for V1
2. Organize into estimated sprints
3. Define dependencies
4. Set Sprint 1 stories to Ready
5. Create first app structure based on needs

### 3.1 Create First App (based on stack)

Ask user what the first app should be:
- API backend → `apps/api/`
- Web frontend → `apps/web/`
- CLI tool → `apps/cli/`
- Other → `apps/[name]/`

Create basic structure:
```bash
mkdir -p apps/[name]/src
```

Create `apps/[name]/package.json` and `apps/[name]/README.md`.

Update `apps/devops/docker/docker-compose.yml` with the new service.

---

## Phase 4: Tech Stack

Create **engineering/stack.md** based on:
- Chosen technologies
- Infrastructure needs
- Development tools

Create **engineering/architecture.md** with:
- System overview
- Component interactions
- Data flow

Create **engineering/conventions.md** with:
- Code style guidelines
- Naming conventions
- File organization

Update `.claude/environments.json` if deployment targets known.

---

## Phase 5: Finalization

1. Update README.md with project-specific info
2. Create .github/ templates if using GitHub
3. Verify all files are created

### Final Structure Check

```
✅ PROJECT INITIALIZATION COMPLETE

Root (whitelist only):
├── ✅ apps/
│   └── ✅ devops/ (docker, env, scripts)
├── ✅ project/ (vision, personas, ux, backlog/, sprints/)
├── ✅ engineering/ (stack, architecture, conventions, decisions/)
├── ✅ docs/ (public docs, api/, archive/)
├── ✅ .claude/
├── ✅ .gitignore
├── ✅ CLAUDE.md
├── ✅ README.md
├── ✅ Makefile
└── ✅ package.json (workspace only, NO deps)

❌ MUST NOT exist at root:
├── ❌ tsconfig.json (goes in apps/[name]/)
├── ❌ .eslintrc* (goes in apps/[name]/)
├── ❌ .prettierrc* (goes in apps/[name]/)
├── ❌ vite.config.* (goes in apps/[name]/)
└── ❌ Any other config file
```

---

## Phase 6: Commit and Create PR

```bash
git add .

git commit -m "tech: initialize project with claude-flow workflow

- Create apps/devops/ for Docker and environment management
- Add docs/ structure (PROJECT, PERSONAS, UX, STACK)
- Add backlog with V1 milestone stories
- Create root Makefile for orchestration
- Setup workspace package.json

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin tech/init-project
```

**Propose PR:**
```
📝 Ready to create PR?

Branch: tech/init-project → main
Title: "tech: initialize project with claude-flow workflow"

This PR sets up:
- Complete project structure with apps/devops/
- V1 milestone and sprint planning
- Documentation framework

Review before merging.
```

**After merge:** Ready for `/sprint plan` and `/work`.

---

## Root Whitelist

Only these files allowed at root:

| File/Folder | Purpose |
|-------------|---------|
| `apps/` | All application code + devops |
| `project/` | Project management (backlog, sprints, vision) |
| `engineering/` | Technical docs (stack, architecture, decisions) |
| `docs/` | Public documentation |
| `.claude/` | Plugin configuration |
| `.git/` | Git repository |
| `.gitignore` | Git ignore rules |
| `.github/` | GitHub workflows (optional) |
| `CLAUDE.md` | Entry point |
| `README.md` | Project overview |
| `LICENSE` | License (optional) |
| `Makefile` | Orchestration |
| `package.json` | Workspace only (NO dependencies) |

### Explicitly FORBIDDEN at root:

| File | Reason |
|------|--------|
| `tsconfig.json` | Goes in `apps/[name]/` |
| `.eslintrc*` | Goes in `apps/[name]/` |
| `.prettierrc*` | Goes in `apps/[name]/` |
| `vite.config.*` | Goes in `apps/[name]/` |
| `tailwind.config.*` | Goes in `apps/[name]/` |
| `turbo.json` | Use Makefile instead |
| `node_modules/` | Should not be committed |

---

## Rule

> ⚠️ **Complete V1 Milestone BEFORE any code**

> 🎯 **apps/devops/ is ALWAYS created** - even for new projects
