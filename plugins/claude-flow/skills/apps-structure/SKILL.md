---
name: apps-structure
description: Structure and conventions for apps/ directory. Each app has its own git and is fully autonomous. Use when managing apps or understanding project structure.
---

# Apps Structure

Conventions for the `apps/` directory. **Each app is autonomous and has its own git repository.**

## Core Principles

1. **Each app has its own .git** (except devops)
2. **Each app is 100% autonomous** - can be cloned and run independently
3. **No shared config** - all config files are self-contained within each app
4. **No extends** - tsconfig, eslint, etc. don't reference parent configs

## Directory Structure

```
apps/
├── devops/                  # Infrastructure (NO .git - stays in principal repo)
│   ├── docker/
│   │   ├── docker-compose.yml
│   │   └── docker-compose.dev.yml
│   ├── env/
│   │   ├── .env.example
│   │   └── .env.dev
│   ├── scripts/
│   │   ├── setup.sh
│   │   └── dev.sh
│   └── README.md
│
├── api/                     # Backend app
│   ├── .git/                # ✅ REQUIRED - independent repo
│   ├── .claude/
│   │   └── quality.json     # App-specific quality gates
│   ├── src/
│   ├── tests/
│   ├── package.json         # Self-contained, all deps included
│   ├── tsconfig.json        # Complete config, NO extends
│   ├── .eslintrc.cjs        # Complete config, NO extends
│   ├── jest.config.js
│   ├── Dockerfile
│   ├── .gitignore
│   └── README.md
│
├── web/                     # Frontend app
│   ├── .git/                # ✅ REQUIRED - independent repo
│   ├── .claude/
│   │   └── quality.json
│   ├── src/
│   ├── package.json         # Self-contained
│   ├── tsconfig.json        # Complete config
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   ├── Dockerfile
│   ├── .gitignore
│   └── README.md
│
└── [other-app]/
    ├── .git/                # ✅ REQUIRED
    └── ...
```

## Required Files Per App

| File | Required | Purpose |
|------|----------|---------|
| `.git/` | ✅ Yes | Independent version control |
| `package.json` | ✅ Yes | Dependencies, scripts (self-contained) |
| `README.md` | ✅ Yes | Documentation |
| `.claude/quality.json` | ✅ Yes | Quality gates |
| `.gitignore` | ✅ Yes | Git ignore rules |
| `tsconfig.json` | If TypeScript | TypeScript config (complete, no extends) |
| `Dockerfile` | Recommended | Container build |

## Git Architecture

```
PRINCIPAL REPO (orchestration)
├── .git/                    # Main project git
├── project/                 # Stories, sprints, vision
├── engineering/             # Architecture, stack, ADRs
├── apps/
│   ├── devops/             # Part of principal repo (no .git)
│   │
│   ├── api/
│   │   └── .git/ ──────────▶ github.com/org/project-api
│   │
│   └── web/
│       └── .git/ ──────────▶ github.com/org/project-web
│
└── docs/
```

### Why Independent Git Per App?

1. **Autonomy**: Clone `apps/api` alone and it works
2. **Independent PRs**: Each app has its own PR lifecycle
3. **Team separation**: Different teams can own different apps
4. **Clear ownership**: Issues and PRs are per-app
5. **Story → Tickets**: One story creates tickets per app (see story-format)

### Exception: devops/

`apps/devops/` does **NOT** have its own git because:
- It orchestrates other apps (docker-compose references them)
- Contains env files that may reference multiple apps
- Releases are coordinated at project level

## .claude/apps.json

Configuration file tracking all apps:

```json
{
  "apps": {
    "api": {
      "path": "apps/api",
      "type": "backend",
      "stack": ["node", "typescript", "fastify"],
      "remote": "git@github.com:org/project-api.git",
      "main_branch": "main"
    },
    "web": {
      "path": "apps/web",
      "type": "frontend",
      "stack": ["typescript", "react", "vite"],
      "remote": "git@github.com:org/project-web.git",
      "main_branch": "main"
    },
    "devops": {
      "path": "apps/devops",
      "type": "devops",
      "git": "principal"
    }
  }
}
```

## Config Files - No Shared Config

**RULE: Each app has complete, self-contained config files.**

### ❌ WRONG - Shared Config
```
project/
├── tsconfig.base.json       # ❌ Shared at root
├── .eslintrc.base.js        # ❌ Shared at root
└── apps/
    └── api/
        └── tsconfig.json    # extends: "../../tsconfig.base.json" ❌
```

### ✅ CORRECT - Self-Contained
```
project/
└── apps/
    ├── api/
    │   ├── tsconfig.json    # Complete config, no extends
    │   └── .eslintrc.cjs    # Complete config, no extends
    └── web/
        ├── tsconfig.json    # Complete config, no extends
        └── .eslintrc.cjs    # Complete config, no extends
```

### Example: Self-Contained tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

No `extends`, no references to parent directories.

## Quality Gates Per App

Each app has `.claude/quality.json`:

```json
{
  "coverage": {
    "minimum": 80,
    "enforce": true
  },
  "lint": {
    "warnings_allowed": 0
  },
  "tests": {
    "required": true
  },
  "security": {
    "block_secrets": false
  }
}
```

This is read by `/done` to enforce quality before PR creation.

## App Types

| Type | Description | Has .git | Typical Stack |
|------|-------------|----------|---------------|
| `devops` | Infrastructure | ❌ No | Docker, scripts |
| `backend` | API/Server | ✅ Yes | Node, Python, Go |
| `frontend` | UI | ✅ Yes | React, Vue, Svelte |
| `service` | Background worker | ✅ Yes | Node, Python |
| `library` | Shared code | ✅ Yes | TypeScript |
| `cli` | Command-line tool | ✅ Yes | Node, Go |

## Workflow Integration

### Story → Tickets → PRs

```
Story S-042 (principal repo)
├── Ticket api#15 → PR in apps/api repo
└── Ticket web#23 → PR in apps/web repo
```

### Commands Context

| Command | Context | Git Operations |
|---------|---------|----------------|
| `/story` | Principal repo | Creates issues in principal + app repos |
| `/work S-042 --app api` | `apps/api/` | Creates branch in api repo |
| `/done` | Current app | PR in current app repo |
| `/release` | Principal repo | Tags principal, coordinates apps |

## Detection Script

```bash
#!/bin/bash
# Verify apps structure

for app_dir in apps/*/; do
    app=$(basename "$app_dir")
    echo "=== $app ==="

    if [ "$app" = "devops" ]; then
        if [ -d "$app_dir/.git" ]; then
            echo "❌ devops should NOT have .git"
        else
            echo "✅ devops: part of principal repo"
        fi
        continue
    fi

    # All other apps must have .git
    if [ -d "$app_dir/.git" ]; then
        echo "✅ Has .git"
        echo "   Remote: $(git -C "$app_dir" remote get-url origin 2>/dev/null || echo 'NONE - needs setup')"
    else
        echo "❌ Missing .git - run /onboard to fix"
    fi

    # Check required files
    for file in package.json README.md .claude/quality.json; do
        if [ -f "$app_dir/$file" ]; then
            echo "✅ $file"
        else
            echo "❌ $file (missing)"
        fi
    done

    # Check for forbidden extends
    if [ -f "$app_dir/tsconfig.json" ]; then
        if grep -q '"extends"' "$app_dir/tsconfig.json"; then
            echo "⚠️  tsconfig.json has extends - should be self-contained"
        fi
    fi

    echo ""
done
```

## Best Practices

1. **Each app is a complete project**
   - Can be cloned and run independently
   - Has all dependencies in its package.json
   - Has all config files self-contained

2. **Git per app (except devops)**
   - Enables independent PR workflows
   - Clear ownership and issue tracking
   - Matches story → ticket model

3. **Quality gates per app**
   - Different apps can have different thresholds
   - Enforced by `/done` before PR

4. **Consistent naming**
   - Repo name: `{project}-{app}` (e.g., `myproject-api`)
   - Branch pattern: `feature/#{ticket}-{slug}`
