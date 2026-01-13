---
description: Onboard an existing project into the workflow. Analyzes codebase and creates all workflow documents (PROJECT.md, PERSONAS.md, UX.md, STACK.md, backlog structure).
argument-hint: [--full]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---

# /onboard - Onboard Existing Project

**Analyze an existing codebase** and create all workflow documents pre-filled with detected information.

## Usage

```
/onboard              # Standard onboarding
/onboard --full       # Full onboarding with backlog generation
```

## IMPORTANT

You MUST actively:
1. **Scan and read** the actual codebase
2. **Analyze** architecture, patterns, and conventions
3. **Create** all workflow documents with real data from the analysis
4. **NOT** just describe what to do - actually do it

---

## Phase 1: Deep Project Analysis

### 1.1 Scan Everything

```bash
# Project structure
tree -L 3 -I 'node_modules|.git|dist|build|__pycache__|venv' || ls -laR | head -100

# Find all important files
find . -type f \( -name "*.json" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -not -path "*/node_modules/*" | head -30
```

### 1.2 Read and Analyze Key Files

**MUST READ these files if they exist:**
- `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod`
- `README.md`
- `tsconfig.json` / `.eslintrc*` / `prettier*`
- `.github/workflows/*`
- `Dockerfile` / `docker-compose.yml`
- Main entry files (`src/index.*`, `src/main.*`, `app.*`)
- Config files (`*.config.js`, `*.config.ts`)

### 1.3 Understand the Application

**Actively read source code to understand:**
- What does this app do?
- Who are the users?
- What are the main features?
- What's the architecture?
- What external services does it use?

---

## Phase 2: Create Workflow Structure

```bash
mkdir -p docs/backlog/functional
mkdir -p docs/backlog/technical
mkdir -p docs/backlog/ux
mkdir -p docs/sprints
mkdir -p docs/architecture
mkdir -p records/decisions
mkdir -p .claude
```

---

## Phase 3: Create Workflow Documents

### 3.1 Create `docs/PROJECT.md`

**Pre-fill with detected information:**

```markdown
# [Project Name from package.json or folder]

## Vision
[Deduce from README or code analysis - what problem does this solve?]

## Objectives
- [Main objective 1 based on features found]
- [Main objective 2]
- [Main objective 3]

## Current State
[Describe what exists: features implemented, tech debt visible, etc.]

## Constraints
- Technical: [detected stack constraints]
- Timeline: [ask user if not clear]
- Resources: [ask user]

## Success Metrics
- [Suggest based on app type]
```

### 3.2 Create `docs/PERSONAS.md`

**Deduce from code analysis:**

```markdown
# User Personas

## Primary Persona: [Name]

### Demographics
- Role: [deduce from app type - admin? end user? developer?]
- Tech level: [deduce from UI complexity]

### Goals
- [What can users achieve with this app?]

### Frustrations
- [What problems might they have? Deduce from code complexity]

### Quote
"[Representative quote based on app purpose]"

---

## Secondary Persona: [If applicable]
...
```

### 3.3 Create `docs/UX.md`

**Analyze existing UI if present:**

```markdown
# UX Direction

## Current State
[Describe existing UI/UX based on code - React components? CLI? API only?]

## Visual Identity
- Colors: [extract from CSS/tailwind config if exists]
- Typography: [detect from config]
- Style: [modern/minimal/corporate/etc based on dependencies]

## UI Framework
[Detected: Tailwind, MUI, Chakra, etc.]

## Components
[List main UI components found in code]

## Improvements Needed
- [Suggest based on analysis]
```

### 3.4 Create `docs/STACK.md`

**Document detected tech stack:**

```markdown
# Tech Stack

## Languages
- [Detected from files: TypeScript, JavaScript, Python, etc.]
- Version: [from config files]

## Frontend
- Framework: [React, Vue, Svelte, etc.]
- UI Library: [Tailwind, MUI, etc.]
- State: [Redux, Zustand, etc.]

## Backend
- Runtime: [Node, Deno, Python, Go, etc.]
- Framework: [Express, Fastify, FastAPI, etc.]
- API Style: [REST, GraphQL, tRPC]

## Database
- [PostgreSQL, MongoDB, SQLite, etc.]
- ORM: [Prisma, TypeORM, SQLAlchemy, etc.]

## Infrastructure
- Hosting: [Vercel, Railway, AWS, etc. - detect from config]
- CI/CD: [GitHub Actions, GitLab CI, etc.]
- Containerization: [Docker if Dockerfile exists]

## Development
- Package Manager: [npm, yarn, pnpm, pip, cargo]
- Linter: [ESLint, Prettier, Black, etc.]
- Test Framework: [Jest, Vitest, pytest, etc.]

## Commands
```bash
# Install
[detected from package.json scripts]

# Dev
[detected]

# Build
[detected]

# Test
[detected]
```
```

### 3.5 Create `.claude/repos.json`

**Detect Git conventions:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/detect-git-conventions.sh .
```

Create config based on detection:

```json
{
  "repos": {
    "[repo-name]": {
      "path": ".",
      "flow_type": "[detected]",
      "main_branch": "[detected]",
      "branch_patterns": {
        "feature": "[detected]",
        "fix": "[detected]",
        "tech": "[detected]"
      },
      "commit_format": "[detected]",
      "ticket_pattern": "[detected]",
      "protected_branches": ["[detected]"]
    }
  },
  "default_repo": "[repo-name]",
  "use_plugin_defaults": false
}
```

### 3.6 Create/Update `CLAUDE.md`

```markdown
# [Project Name]

## Quick Reference

### Commands
```bash
[detected dev commands]
```

### Structure
[Brief structure description]

## Workflow
This project uses claude-flow workflow.
- Backlog: `docs/backlog/`
- Sprints: `docs/sprints/`
- Decisions: `records/decisions/`

## Conventions
- Git: [detected conventions]
- Commits: [detected format]
- Branches: [detected patterns]

## Key Files
- [Important file 1]: [purpose]
- [Important file 2]: [purpose]
```

---

## Phase 4: Generate Initial Backlog (if --full)

Analyze code for:

### 4.1 Technical Debt → TS-XXX stories

Look for:
- TODO/FIXME comments
- Outdated dependencies
- Missing tests
- Code duplication
- Security issues

Create `docs/backlog/technical/TS-001-*.md` for each.

### 4.2 Missing Features → US-XXX stories

Based on incomplete code:
- Stubbed functions
- Empty handlers
- Commented features

Create `docs/backlog/functional/US-001-*.md` for each.

### 4.3 UX Improvements → UX-XXX stories

If frontend exists:
- Accessibility issues
- Missing responsive design
- UI inconsistencies

Create `docs/backlog/ux/UX-001-*.md` for each.

---

## Phase 5: Summary Report

```
✅ Project Onboarded: [name]

📁 Structure Created:
├── docs/
│   ├── PROJECT.md (vision & objectives)
│   ├── PERSONAS.md (user profiles)
│   ├── UX.md (design direction)
│   ├── STACK.md (tech documentation)
│   └── backlog/ (story structure)
├── records/decisions/
├── .claude/repos.json (git conventions)
└── CLAUDE.md (quick reference)

📊 Analysis:
├── Tech: [stack summary]
├── Git Flow: [detected]
├── Features: [count] identified
└── Tech Debt: [count] items found

💡 Suggestions:
1. [Based on analysis]
2. [Based on analysis]
3. [Based on analysis]

🚀 Next Steps:
1. Review generated documents
2. Use /story to add more stories
3. Use /sprint plan to plan first sprint
4. Use /work #XX to start coding
```

---

## Key Difference from /init

| /init | /onboard |
|-------|----------|
| New project from scratch | Existing codebase |
| Asks questions | Analyzes code |
| User provides info | Detects info |
| Creates empty structure | Pre-fills documents |
