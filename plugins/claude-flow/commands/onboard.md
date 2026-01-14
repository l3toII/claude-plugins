---
description: Onboard an existing project into the workflow. Cleans pilot repo with whitelist approach, creates apps/devops/, and produces structure identical to /init.
argument-hint: [--full]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
---

# /onboard - Onboard Existing Project

**Transform an existing codebase** into a clean claude-flow project, identical to a fresh `/init`.

## Usage

```
/onboard              # Standard onboarding
/onboard --full       # Full onboarding with backlog generation
```

## Core Principles

> ⚠️ **WHITELIST APPROACH**: Only files in the whitelist stay at root. Everything else must be moved or deleted.

> 🎯 **apps/devops/**: All DevOps files (Docker, .env, scripts) go in `apps/devops/`

> 🚫 **NO CONFIG AT ROOT**: All `.eslintrc`, `tsconfig.json`, `.prettierrc`, etc. go with their apps

---

## ROOT WHITELIST (Strict)

**ONLY these files/folders are allowed at root:**

```
✅ ALLOWED AT ROOT:
├── apps/                    # All application code
├── project/                 # Project management (backlog, sprints)
├── engineering/             # Technical docs (architecture, decisions)
├── docs/                    # Public documentation
├── .claude/                 # Plugin configuration
├── .git/                    # Git repository
├── .gitignore               # Git ignore rules
├── .github/                 # GitHub workflows (optional)
├── CLAUDE.md                # Entry point for Claude
├── README.md                # Project overview
├── LICENSE                  # License file
├── Makefile                 # Root orchestration commands
└── package.json             # Workspace only (NO dependencies)

❌ EVERYTHING ELSE MUST BE MOVED OR DELETED
```

### Explicitly FORBIDDEN at root:

```
❌ FORBIDDEN AT ROOT (must move to apps/[name]/):
├── tsconfig.json            # → apps/[name]/
├── tsconfig.*.json          # → apps/[name]/
├── .eslintrc*               # → apps/[name]/
├── .prettierrc*             # → apps/[name]/
├── prettier.config.*        # → apps/[name]/
├── jest.config.*            # → apps/[name]/
├── vitest.config.*          # → apps/[name]/
├── vite.config.*            # → apps/[name]/
├── next.config.*            # → apps/[name]/
├── tailwind.config.*        # → apps/[name]/
├── postcss.config.*         # → apps/[name]/
├── babel.config.*           # → apps/[name]/
├── webpack.config.*         # → apps/[name]/
├── rollup.config.*          # → apps/[name]/
├── esbuild.config.*         # → apps/[name]/
├── turbo.json               # → DELETE (use Makefile)
├── nx.json                  # → DELETE (use Makefile)
├── lerna.json               # → DELETE (use Makefile)
├── pnpm-workspace.yaml      # → DELETE (use package.json workspaces)
└── src/, lib/, index.*      # → apps/[name]/

❌ FORBIDDEN AT ROOT (must move to apps/devops/):
├── Dockerfile*              # → apps/devops/docker/ or apps/[name]/
├── docker-compose*.yml      # → apps/devops/docker/
├── .env                     # → apps/devops/env/
├── .env.local               # → apps/devops/env/
├── .env.development         # → apps/devops/env/
├── .env.production          # → apps/devops/env/
└── deploy.*, k8s/, terraform/ # → apps/devops/

❌ FORBIDDEN AT ROOT (must DELETE):
├── node_modules/            # Regenerable
├── package-lock.json        # Regenerable
├── yarn.lock                # Regenerable
├── pnpm-lock.yaml           # Regenerable
├── .pnpm-store/             # Regenerable
├── .yarn/                   # Regenerable
├── dist/, build/, .next/    # Build artifacts
└── coverage/                # Test artifacts
```

---

## Phase 0: Create Dedicated Branch

```bash
git status
git checkout -b tech/onboard-workflow
```

---

## Phase 1: Full Root Scan & Categorization

### 1.1 Scan Everything at Root

```bash
# List ALL files and folders at root
ls -la
ls -la .*  # Hidden files too
```

### 1.2 Categorize Each Item

For each file/folder at root, categorize:

| Category | Examples | Default Action |
|----------|----------|----------------|
| **CODE** | `src/`, `lib/`, `*.ts`, `*.js`, `*.py` | → Move to `apps/[name]/` |
| **CONFIG-APP** | `tsconfig.json`, `.eslintrc*`, `.prettierrc*`, `jest.config.*`, `vite.config.*`, `tailwind.config.*`, `postcss.config.*`, `next.config.*`, `babel.config.*` | → Move with code to `apps/[name]/` |
| **CONFIG-DEVOPS** | `Dockerfile*`, `docker-compose.*`, `.env*` | → Move to `apps/devops/` |
| **CONFIG-MONOREPO** | `turbo.json`, `nx.json`, `lerna.json`, `pnpm-workspace.yaml` | → DELETE (use Makefile) |
| **DEPS** | `node_modules/`, `*.lock`, `.pnpm-store/`, `.yarn/` | → Delete (regenerable) |
| **BUILD** | `dist/`, `build/`, `.next/`, `coverage/` | → Delete (regenerable) |
| **CI/CD** | `.github/`, `.gitlab-ci.yml` | → Keep (whitelist) |
| **DOCS-LEGACY** | `CHANGELOG.md`, `CONTRIBUTING.md`, old `*.md` | → Archive to `docs/archive/` |
| **WHITELIST** | `README.md`, `LICENSE`, `.gitignore`, `Makefile` | → Keep |
| **UNKNOWN** | Anything else | → Ask user |

### 1.3 Generate Cleanup Report

```
🔍 ROOT CLEANUP REPORT

📁 Scanned: 42 items at root

✅ WHITELIST (keep as-is): 5 items
├── .git/
├── .gitignore
├── .github/
├── README.md
└── LICENSE

🚚 CODE → apps/[name]/: 3 items
├── src/ (→ apps/core/)
├── lib/ (→ apps/core/)
└── index.ts (→ apps/core/)

⚙️ CONFIG-APP → move with code: 8 items
├── tsconfig.json (→ apps/core/)
├── tsconfig.node.json (→ apps/core/)
├── .eslintrc.cjs (→ apps/core/)
├── .prettierrc (→ apps/core/)
├── jest.config.js (→ apps/core/)
├── vite.config.ts (→ apps/core/)
├── tailwind.config.js (→ apps/core/)
└── postcss.config.js (→ apps/core/)

🐳 DEVOPS → apps/devops/: 6 items
├── Dockerfile (→ apps/devops/docker/)
├── docker-compose.yml (→ apps/devops/docker/)
├── docker-compose.dev.yml (→ apps/devops/docker/)
├── .env (→ apps/devops/env/)
├── .env.example (→ apps/devops/env/)
└── .env.local (→ apps/devops/env/)

🗑️ DELETE (monorepo tools - use Makefile): 3 items
├── turbo.json
├── pnpm-workspace.yaml
└── nx.json

🗑️ DELETE (regenerable): 6 items
├── node_modules/
├── package-lock.json
├── pnpm-lock.yaml
├── .pnpm-store/
├── dist/
└── coverage/

📦 ARCHIVE → docs/archive/: 2 items
├── CHANGELOG.md
└── CONTRIBUTING.md

❓ UNKNOWN → need decision: 2 items
├── random-file.txt
└── temp/

─────────────────────────────────
Total actions: 35 items to process
```

### 1.4 User Confirmation (MANDATORY)

> ⚠️ **MUST use AskUserQuestion before ANY action**

```
⚠️ CLEANUP CONFIRMATION REQUIRED

I've categorized 34 items. Proposed actions:

1. AUTO-CLEAN (recommended):
   - Move code to apps/core/
   - Move DevOps to apps/devops/
   - Delete node_modules/ and lock files
   - Archive old docs

2. REVIEW ONE BY ONE:
   - Confirm each item individually

3. SKIP CLEANUP:
   - Not recommended - pilot repo will remain dirty

Your choice?
```

**If user chooses "REVIEW ONE BY ONE"**, ask for each category:
- Code destination app name
- Which DevOps files to keep
- Which docs to archive vs delete
- What to do with unknown files

---

## Phase 2: Execute Cleanup

### 2.1 Create Target Structure

```bash
# Create apps structure
mkdir -p apps/devops/docker
mkdir -p apps/devops/env
mkdir -p apps/devops/scripts

# Create project management structure
mkdir -p project/backlog/functional
mkdir -p project/backlog/technical
mkdir -p project/backlog/ux
mkdir -p project/sprints

# Create engineering structure
mkdir -p engineering/decisions

# Create docs structure (public documentation)
mkdir -p docs/api
mkdir -p docs/archive

# Create config
mkdir -p .claude
```

### 2.2 Move Code to apps/

```bash
# Example: Move src/ to apps/core/
mkdir -p apps/core
mv src/ apps/core/
mv lib/ apps/core/
mv index.ts apps/core/

# Move ALL associated config with the code
mv tsconfig.json apps/core/
mv tsconfig.node.json apps/core/ 2>/dev/null
mv .eslintrc* apps/core/
mv .prettierrc* apps/core/
mv prettier.config.* apps/core/ 2>/dev/null
mv jest.config.* apps/core/ 2>/dev/null
mv vitest.config.* apps/core/ 2>/dev/null
mv vite.config.* apps/core/ 2>/dev/null
mv next.config.* apps/core/ 2>/dev/null
mv tailwind.config.* apps/core/ 2>/dev/null
mv postcss.config.* apps/core/ 2>/dev/null
mv babel.config.* apps/core/ 2>/dev/null
```

> ⚠️ **CRITICAL**: Config files MUST move with the code. No config at root.

### 2.3 Move DevOps to apps/devops/

```bash
# Docker files
mv Dockerfile apps/devops/docker/
mv docker-compose*.yml apps/devops/docker/

# Environment files
mv .env* apps/devops/env/

# Create .env.example if not exists
touch apps/devops/env/.env.example
```

### 2.4 Delete Regenerable Files

```bash
# Remove deps (will be regenerated)
rm -rf node_modules/
rm -f package-lock.json yarn.lock pnpm-lock.yaml
rm -rf .pnpm-store/ .yarn/

# Remove build artifacts
rm -rf dist/ build/ .next/ out/
rm -rf coverage/ .nyc_output/

# Remove monorepo tools (replaced by Makefile)
rm -f turbo.json nx.json lerna.json
rm -f pnpm-workspace.yaml
```

### 2.5 Archive Legacy Docs

```bash
mv CHANGELOG.md docs/archive/
mv CONTRIBUTING.md docs/archive/
mv old-notes.md docs/archive/
```

---

## Phase 3: Setup apps/devops/

### 3.1 Create apps/devops/ Structure

```
apps/devops/
├── docker/
│   ├── docker-compose.yml      # Main compose (orchestrates all apps)
│   ├── docker-compose.dev.yml  # Dev overrides
│   ├── docker-compose.prod.yml # Prod overrides
│   └── Dockerfile.base         # Shared base image (optional)
├── env/
│   ├── .env.example            # Template for all env vars
│   ├── .env.dev                # Dev defaults (no secrets)
│   └── .env.prod.example       # Prod template (no secrets)
├── scripts/
│   ├── setup.sh                # Initial setup script
│   ├── dev.sh                  # Start dev environment
│   └── deploy.sh               # Deployment script
├── package.json                # For any Node.js tooling
└── README.md                   # DevOps documentation
```

### 3.2 Create docker-compose.yml

```yaml
# apps/devops/docker/docker-compose.yml
version: '3.8'

services:
  # Add services based on detected apps
  # Example:
  api:
    build:
      context: ../../api
      dockerfile: Dockerfile
    env_file:
      - ../env/.env
    ports:
      - "3000:3000"
    volumes:
      - ../../api:/app
      - /app/node_modules

  web:
    build:
      context: ../../web
      dockerfile: Dockerfile
    env_file:
      - ../env/.env
    ports:
      - "5173:5173"
    volumes:
      - ../../web:/app
      - /app/node_modules
```

### 3.3 Create apps/devops/README.md

```markdown
# DevOps

Infrastructure and deployment configuration for the project.

## Quick Start

From project root:
```bash
make up      # Start all services
make down    # Stop all services
make logs    # View logs
```

## Structure

- `docker/` - Docker Compose configurations
- `env/` - Environment variable templates
- `scripts/` - Automation scripts

## Environment Variables

Copy the example file and fill in values:
```bash
cp apps/devops/env/.env.example apps/devops/env/.env
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| api | 3000 | Backend API |
| web | 5173 | Frontend app |
```

---

## Phase 4: Apps Validation

### 4.1 Identify All Apps

```bash
ls -d apps/*/ 2>/dev/null
```

### 4.2 Validate Each App

Each app in `apps/` (except devops) MUST have:
- [ ] `package.json` (or equivalent)
- [ ] `README.md`
- [ ] `src/` or entry point

### 4.3 Create Missing Essentials

```
📦 App: apps/api/

Missing:
├── ❌ README.md

Create README.md? [Y/n]
```

---

## Phase 5: Create Workflow Documents

### 5.1 Create Root Makefile

```makefile
# Makefile - Project orchestration

.PHONY: help up down logs build test lint

help:
	@echo "Available commands:"
	@echo "  make up       - Start all services"
	@echo "  make down     - Stop all services"
	@echo "  make logs     - View logs (use app=api for specific)"
	@echo "  make build    - Build all apps"
	@echo "  make test     - Run all tests"
	@echo "  make lint     - Lint all apps"

# DevOps commands (delegate to apps/devops)
up:
	cd apps/devops/docker && docker-compose up -d

down:
	cd apps/devops/docker && docker-compose down

logs:
	cd apps/devops/docker && docker-compose logs -f $(app)

# Build commands
build:
	@for dir in apps/*/; do \
		if [ -f "$$dir/package.json" ] && [ "$${dir}" != "apps/devops/" ]; then \
			echo "Building $$dir..."; \
			cd "$$dir" && npm run build && cd ../..; \
		fi \
	done

# Test commands
test:
	@for dir in apps/*/; do \
		if [ -f "$$dir/package.json" ] && [ "$${dir}" != "apps/devops/" ]; then \
			echo "Testing $$dir..."; \
			cd "$$dir" && npm test && cd ../..; \
		fi \
	done

# Per-app commands
test-%:
	cd apps/$* && npm test

lint-%:
	cd apps/$* && npm run lint

build-%:
	cd apps/$* && npm run build
```

### 5.2 Create Workflow Documents

| File | Content |
|------|---------|
| `project/vision.md` | Project vision, objectives (from analysis) |
| `project/personas.md` | User personas deduced from code |
| `project/ux.md` | UI/UX analysis |
| `project/roadmap.md` | High-level roadmap |
| `engineering/stack.md` | Detected tech stack |
| `engineering/architecture.md` | System architecture |
| `engineering/conventions.md` | Code conventions |
| `.claude/repos.json` | Git conventions |
| `CLAUDE.md` | Entry point |

### 5.3 Create/Update package.json (Workspace Only)

```json
{
  "name": "project-workspace",
  "private": true,
  "workspaces": ["apps/*"],
  "scripts": {
    "dev": "make up",
    "build": "make build",
    "test": "make test"
  }
}
```

**Rules:**
- ❌ No `dependencies` at root
- ❌ No `devDependencies` at root (except workspace tools)
- ✅ Only workspace configuration

---

## Phase 6: Document Reconciliation

> ⚠️ **CRITICAL**: If documents already exist, they MUST be reconciled with the code.

### 6.1 Detect Existing Documents

```bash
# Check for existing project docs
existing_docs=()
[ -f "README.md" ] && existing_docs+=("README.md")
[ -f "docs/PROJECT.md" ] && existing_docs+=("docs/PROJECT.md")
[ -f "docs/ARCHITECTURE.md" ] && existing_docs+=("docs/ARCHITECTURE.md")
[ -f "CONTRIBUTING.md" ] && existing_docs+=("CONTRIBUTING.md")
[ -d "docs/" ] && existing_docs+=("docs/*")
```

### 6.2 Analyze Code vs Documentation

For each existing document, compare with actual code state:

```
📋 DOCUMENT RECONCILIATION REPORT

┌─────────────────────────────────────────────────────────────────────────────┐
│ EXISTING DOCUMENTS FOUND                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📄 README.md                                                                │
│  ├── Claims: "React + Node.js + PostgreSQL"                                 │
│  ├── Code:   React ✅ │ Node.js ✅ │ PostgreSQL ❌ (MongoDB found)          │
│  └── Action: ⚠️ INCONSISTENCY - needs update                                │
│                                                                              │
│  📄 docs/ARCHITECTURE.md                                                     │
│  ├── Claims: "Microservices architecture"                                   │
│  ├── Code:   Monolith detected (single apps/api/)                           │
│  └── Action: ⚠️ INCONSISTENCY - needs rewrite                               │
│                                                                              │
│  📄 docs/API.md                                                              │
│  ├── Claims: 15 endpoints documented                                        │
│  ├── Code:   23 endpoints found                                             │
│  └── Action: ⚠️ OUTDATED - 8 undocumented endpoints                         │
│                                                                              │
│  📄 CONTRIBUTING.md                                                          │
│  ├── Status: Generic template                                               │
│  └── Action: 📦 ARCHIVE to docs/archive/                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 User Reconciliation Dialog

> ⚠️ **MUST use AskUserQuestion for each inconsistency**

```
⚠️ DOCUMENT INCONSISTENCY DETECTED

README.md claims PostgreSQL, but code uses MongoDB.

Options:
1. UPDATE DOCS: Change README to reflect MongoDB (code is truth)
2. FLAG AS TECH DEBT: Keep note, plan migration to PostgreSQL
3. ASK FOR CLARIFICATION: Which is the intended database?
4. SKIP: Keep inconsistency (not recommended)

Your choice?
```

### 6.4 Reconciliation Actions

| Situation | Action |
|-----------|--------|
| Doc matches code | ✅ Migrate to new location |
| Doc outdated | 🔄 Regenerate from code analysis |
| Doc incorrect | ⚠️ Ask user which is truth |
| Doc missing | 📝 Generate from code |
| Doc generic/template | 📦 Archive |

### 6.5 Document Migration Map

```
EXISTING → NEW LOCATION

docs/PROJECT.md        → project/vision.md (merge/update)
docs/ARCHITECTURE.md   → engineering/architecture.md (reconcile)
docs/STACK.md          → engineering/stack.md (verify)
docs/PERSONAS.md       → project/personas.md (keep)
docs/backlog/          → project/backlog/ (migrate)
docs/sprints/          → project/sprints/ (migrate)
records/decisions/     → engineering/decisions/ (migrate)
CHANGELOG.md           → docs/archive/CHANGELOG.md
CONTRIBUTING.md        → docs/archive/CONTRIBUTING.md
```

### 6.6 Code Analysis for Document Generation

When generating/updating documents, analyze:

```bash
# Stack detection
package_jsons=$(find apps -name "package.json" -not -path "*/node_modules/*")
for pkg in $package_jsons; do
  # Extract dependencies
  jq -r '.dependencies | keys[]' "$pkg" 2>/dev/null
done

# Database detection
grep -r "mongoose\|mongodb" apps/ --include="*.ts" --include="*.js"
grep -r "prisma\|@prisma" apps/ --include="*.ts" --include="*.js"
grep -r "pg\|postgres" apps/ --include="*.ts" --include="*.js"

# Framework detection
grep -r "express\|fastify\|nest" apps/ --include="*.ts" --include="*.js"
grep -r "react\|vue\|angular\|svelte" apps/ --include="*.ts" --include="*.js"

# API endpoints
grep -rE "app\.(get|post|put|delete|patch)\(" apps/ --include="*.ts" --include="*.js"
grep -rE "@(Get|Post|Put|Delete|Patch)\(" apps/ --include="*.ts" --include="*.js"
```

### 6.7 Reconciliation Report

```
✅ DOCUMENT RECONCILIATION COMPLETE

📄 Documents Processed: 8

├── ✅ Migrated (unchanged): 3
│   ├── project/personas.md (from docs/PERSONAS.md)
│   ├── project/backlog/* (from docs/backlog/*)
│   └── project/sprints/* (from docs/sprints/*)
│
├── 🔄 Updated (reconciled): 2
│   ├── project/vision.md (merged from docs/PROJECT.md + code analysis)
│   └── engineering/stack.md (corrected: PostgreSQL → MongoDB)
│
├── 📝 Generated (new): 2
│   ├── engineering/architecture.md (from code structure)
│   └── engineering/conventions.md (from config files)
│
└── 📦 Archived: 1
    └── docs/archive/CONTRIBUTING.md

⚠️ User Decisions Made:
├── Stack: MongoDB confirmed (PostgreSQL was legacy reference)
└── Architecture: Monolith confirmed (microservices was future plan)
```

---

## Phase 7: Generate Initial Backlog (if --full)

### 7.1 Technical Stories (TS-XXX)

- TODO/FIXME comments found
- Outdated dependencies
- Missing tests
- Missing Dockerfiles in apps
- **Document inconsistencies flagged as tech debt**

### 7.2 User Stories (US-XXX)

- Incomplete features
- Stubbed functions

### 7.3 DevOps Stories (TS-XXX)

- Missing CI/CD pipelines
- No staging environment
- Missing health checks

---

## Phase 8: Final Validation

### 8.1 Pilot Repo Checklist

```
✅ PILOT REPO VALIDATION

Root (whitelist only):
├── ✅ apps/
├── ✅ project/
├── ✅ engineering/
├── ✅ docs/
├── ✅ .claude/
├── ✅ .git/
├── ✅ .gitignore
├── ✅ .github/ (if exists)
├── ✅ CLAUDE.md
├── ✅ README.md
├── ✅ Makefile
├── ✅ LICENSE (if exists)
├── ⚠️ package.json (workspace only, NO deps)
└── ❌ Nothing else at root

❌ MUST NOT EXIST at root:
├── ❌ tsconfig.json
├── ❌ .eslintrc*
├── ❌ .prettierrc*
├── ❌ vite.config.*
├── ❌ tailwind.config.*
├── ❌ turbo.json
├── ❌ node_modules/
└── ❌ Any other config file

Apps:
├── ✅ apps/devops/ (docker, env, scripts)
├── ✅ apps/[name]/ (with its own config files)
└── ✅ Each app has: package.json, README.md, tsconfig.json (if TS)
```

### 8.2 Summary Report

```
✅ Project Onboarded: [name]

🧹 Cleanup Performed:
├── Moved: src/, lib/ → apps/core/
├── Moved: tsconfig.json, .eslintrc, .prettierrc → apps/core/
├── Moved: Dockerfile, docker-compose.yml → apps/devops/docker/
├── Moved: .env* → apps/devops/env/
├── Deleted: node_modules/, package-lock.json
├── Deleted: turbo.json, pnpm-workspace.yaml
├── Archived: CHANGELOG.md → docs/archive/
└── Created: apps/devops/README.md

📄 Documents Reconciled:
├── Migrated: 3 (unchanged)
├── Updated: 2 (reconciled with code)
├── Generated: 2 (from code analysis)
└── Archived: 1

📁 Final Structure:
├── apps/
│   ├── devops/ (docker, env, scripts)
│   ├── core/ (with tsconfig.json, .eslintrc, etc.)
│   └── web/
├── project/ (vision, personas, backlog/, sprints/)
├── engineering/ (stack, architecture, decisions/)
├── docs/ (public docs, api/, archive/)
├── .claude/
├── CLAUDE.md
├── README.md
└── Makefile

📊 Analysis:
├── Apps: 3 (devops, core, web)
├── Tech: [stack summary]
├── Git Flow: [detected]
└── Tech Debt: [count] items
```

---

## Phase 9: Commit and Create PR

```bash
git add .

git commit -m "tech: onboard project to claude-flow workflow

- Clean pilot repo (whitelist approach)
- Create apps/devops/ for Docker and environment management
- Move all code to apps/ with their config files
- Reconcile existing docs with code (project/, engineering/)
- Add backlog structure
- Create root Makefile for orchestration

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin tech/onboard-workflow
```

---

## Key Rules

| Rule | Enforcement |
|------|-------------|
| Whitelist only at root | ❌ Everything else must move/delete |
| DevOps in apps/devops/ | 🐳 Docker, .env, scripts centralized |
| No deps at root | 🗑️ Delete node_modules, lock files |
| User confirmation | ⚠️ MANDATORY for all actions |
| Archive over delete | 📁 Prefer docs/archive/ for docs |
| Clean = like /init | 🎯 Final state identical to fresh init |

---

## apps/devops/ Manages

| What | Location | Purpose |
|------|----------|---------|
| Docker Compose | `docker/` | Orchestrate all apps locally |
| Dockerfiles | `docker/` or per-app | Build images |
| Environment vars | `env/` | Templates and defaults |
| Scripts | `scripts/` | Automation (setup, deploy) |
| CI/CD configs | Here or `.github/` | Pipelines |
| Terraform/K8s | `infra/` (optional) | Cloud infrastructure |
