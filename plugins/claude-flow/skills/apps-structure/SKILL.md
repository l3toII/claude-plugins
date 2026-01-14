---
name: apps-structure
description: Structure and conventions for apps/ directory and multi-git configuration. Use when managing apps, configuring git per app, or understanding monorepo structure.
---

# Apps Structure

Conventions for the `apps/` directory and multi-git configurations.

## Directory Structure

```
apps/
├── devops/                  # Infrastructure (always present)
│   ├── docker/
│   ├── env/
│   ├── scripts/
│   └── README.md
│
├── api/                     # Backend app (example)
│   ├── .git/                # If independent repo
│   ├── src/
│   ├── package.json
│   ├── tsconfig.json        # App-specific config
│   ├── .eslintrc.cjs        # App-specific config
│   ├── Dockerfile
│   └── README.md
│
├── web/                     # Frontend app (example)
│   ├── src/
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts       # App-specific config
│   ├── tailwind.config.js   # App-specific config
│   ├── Dockerfile
│   └── README.md
│
└── worker/                  # Service app (example)
    ├── src/
    ├── package.json
    └── README.md
```

## Required Files Per App

| File | Required | Purpose |
|------|----------|---------|
| `package.json` | ✅ Yes | Dependencies, scripts |
| `README.md` | ✅ Yes | Documentation |
| `tsconfig.json` | If TypeScript | TypeScript config |
| `Dockerfile` | Recommended | Container build |
| `.eslintrc.*` | Recommended | Linting rules |

## Git Types

### 1. Monorepo (Default) - Recommended

App is part of root git repository. **Follows root git-flow and versioning.**

```
project/
├── .git/                    # Single git for all
├── apps/
│   ├── api/                 # No .git here → follows root
│   └── web/                 # No .git here → follows root
```

**Behavior:**
- Branch strategy: **inherits from root** (defined in `.claude/repos.json`)
- Version: **unified** (defined in `project/roadmap.md` or root `package.json`)
- Commits: to root repo
- Releases: coordinated across all apps

**This is the DEFAULT and RECOMMENDED approach.**

### 2. Independent Repository (Legacy/Exception)

App has its own `.git` directory. **Preserves existing business rules.**

```
project/
├── .git/                    # Root repo
├── apps/
│   ├── api/
│   │   └── .git/            # Own git repo - KEEPS ITS RULES
│   └── web/
│       └── .git/            # Own git repo - KEEPS ITS RULES
```

**Behavior:**
- Branch strategy: **preserved from existing repo**
- Version: **independent** (app's own versioning)
- Commits: to app's own repo
- Releases: independent schedule

**Use ONLY when:**
- App existed before onboarding with its own git
- Different team/org manages the app
- Regulatory/compliance requires separation
- App is shared across multiple projects

> ⚠️ **IMPORTANT**: If an app has `.git/`, we PRESERVE its existing conventions.
> We do NOT override branch strategy or versioning rules.

### 3. Git Submodule (External)

App is a git submodule tracked by parent.

```
project/
├── .git/
├── .gitmodules              # Tracks submodules
├── apps/
│   ├── api/                 # Submodule
│   └── web/                 # Submodule
```

**Behavior:**
- Pinned to specific commit
- Updated explicitly
- Preserves external repo rules

**Use when:**
- External dependency
- Third-party code
- Shared library across projects

## .claude/apps.json

Configuration file for app management:

```json
{
  "apps": {
    "api": {
      "path": "apps/api",
      "type": "backend",
      "stack": ["node", "typescript", "express"],
      "git": {
        "type": "monorepo"
      },
      "docker": {
        "service": "api",
        "port": 3000
      }
    },
    "legacy-service": {
      "path": "apps/legacy-service",
      "type": "backend",
      "git": {
        "type": "independent",
        "preserve_rules": true,
        "detected_strategy": "gitflow",
        "detected_main": "master",
        "remote": "git@github.com:org/legacy-service.git"
      }
    }
  }
}
```

### Git Configuration Fields

| Field | Values | Description |
|-------|--------|-------------|
| `type` | `monorepo`, `independent`, `submodule` | Git relationship |
| `preserve_rules` | boolean | If true, keep existing repo conventions |
| `detected_strategy` | string | Auto-detected branch strategy |
| `detected_main` | string | Auto-detected main branch |
| `remote` | URL | Git remote URL (if independent) |

### Inheritance Rules

| App has `.git`? | Behavior |
|-----------------|----------|
| **No** | Inherits ALL from root: branch strategy, versioning, conventions |
| **Yes** | Preserves its own rules, detected and stored in apps.json |

### Branch Strategies

#### Trunk-Based
```
main ─────●─────●─────●─────●─────
          │     │     │     │
       feature branches (short-lived)
```

#### GitFlow
```
main    ─────────────●─────────────●───
                    ╱             ╱
develop ────●────●─╱───●────●───╱────
           ╱    ╱      ╱    ╱
        feature branches
```

#### GitHub Flow
```
main ─────●─────●─────●─────●─────
         ╱│    ╱│    ╱│    ╱│
      PR  │ PR  │ PR  │ PR  │
         feature branches
```

## App Types

| Type | Description | Typical Stack |
|------|-------------|---------------|
| `devops` | Infrastructure | Docker, scripts |
| `backend` | API/Server | Node, Python, Go |
| `frontend` | UI | React, Vue, Svelte |
| `service` | Background worker | Node, Python |
| `library` | Shared code | TypeScript |
| `cli` | Command-line tool | Node, Go |

## Config Files Location

**RULE: All config files belong IN the app, not at root.**

| Config | Location | NOT at root |
|--------|----------|-------------|
| `tsconfig.json` | `apps/[name]/` | ❌ |
| `.eslintrc.*` | `apps/[name]/` | ❌ |
| `.prettierrc.*` | `apps/[name]/` | ❌ |
| `vite.config.*` | `apps/[name]/` | ❌ |
| `tailwind.config.*` | `apps/[name]/` | ❌ |
| `jest.config.*` | `apps/[name]/` | ❌ |
| `Dockerfile` | `apps/[name]/` or `apps/devops/docker/` | ❌ |

## Detection Script

```bash
#!/bin/bash
# Detect git configuration for each app

for app_dir in apps/*/; do
    app=$(basename "$app_dir")
    echo "=== $app ==="

    # Check if has own git
    if [ -d "$app_dir/.git" ]; then
        echo "Type: independent"
        echo "Remote: $(git -C "$app_dir" remote get-url origin 2>/dev/null || echo 'none')"
        echo "Branch: $(git -C "$app_dir" branch --show-current)"
    elif git submodule status 2>/dev/null | grep -q "$app_dir"; then
        echo "Type: submodule"
    else
        echo "Type: monorepo"
    fi

    # Check required files
    for file in package.json README.md Dockerfile tsconfig.json; do
        if [ -f "$app_dir/$file" ]; then
            echo "✅ $file"
        else
            echo "❌ $file (missing)"
        fi
    done

    echo ""
done
```

## Best Practices

1. **One app = One responsibility**
   - Don't mix frontend and backend in one app
   - Separate services for different domains

2. **Config stays with code**
   - tsconfig.json in the app, not root
   - Each app is self-contained

3. **Consistent structure**
   - All apps have src/, package.json, README.md
   - DevOps has docker/, env/, scripts/

4. **Git strategy matches team**
   - Single team → monorepo
   - Multiple teams → independent repos
   - External deps → submodules

5. **Document in apps.json**
   - Track git config per app
   - Store stack information
   - Configure ports and services
