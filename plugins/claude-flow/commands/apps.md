---
description: Manage apps in the monorepo - status, git configuration, initialization, and synchronization.
argument-hint: [action] [app-name]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(ls:*), Bash(mkdir:*), AskUserQuestion
---

# /apps - Apps Management

Manage applications in the monorepo, including multi-git configurations.

## Usage

```
/apps                    # List all apps with status
/apps status             # Detailed status of all apps
/apps status api         # Detailed status of specific app
/apps init [name]        # Initialize a new app
/apps git [app] [action] # Manage git for an app
/apps sync               # Synchronize all apps
/apps check              # Verify all apps are properly configured
```

---

## /apps (List)

Display quick overview of all apps:

```
╔══════════════════════════════════════════════════════════════════════╗
║  📦 APPS OVERVIEW                                                     ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  APP          GIT         BRANCH              STATUS                  ║
║  ─────────────────────────────────────────────────────────────────── ║
║  devops       monorepo    main                ✅ ok                   ║
║  api          independent feature/#42-auth    ✅ ok (3 ahead)        ║
║  web          submodule   develop             ⚠️ uncommitted          ║
║  worker       none        -                   ❌ no package.json      ║
║                                                                       ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

## /apps status [app]

### All Apps Status

```
╔══════════════════════════════════════════════════════════════════════╗
║  📦 DETAILED APPS STATUS                                              ║
╚══════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────┐
│ 📁 apps/devops                                                        │
├──────────────────────────────────────────────────────────────────────┤
│ Type:        DevOps (infrastructure)                                  │
│ Git:         Part of monorepo                                        │
│ Branch:      main (follows root)                                     │
│                                                                       │
│ Contents:                                                             │
│ ├── docker/           docker-compose.yml ✅                          │
│ ├── env/              .env.example ✅, .env ✅                       │
│ └── scripts/          setup.sh ✅, deploy.sh ✅                      │
│                                                                       │
│ Health:      ✅ Properly configured                                  │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ 📁 apps/api                                                           │
├──────────────────────────────────────────────────────────────────────┤
│ Type:        Backend API                                              │
│ Git:         Independent repository                                   │
│ Remote:      git@github.com:org/api.git                              │
│ Branch:      feature/#42-auth                                         │
│ Strategy:    GitFlow (main + develop)                                │
│                                                                       │
│ Status:                                                               │
│ ├── Local:   3 commits ahead of origin                               │
│ ├── Staged:  2 files                                                 │
│ └── Changed: 5 files                                                 │
│                                                                       │
│ Config Files:                                                         │
│ ├── package.json      ✅                                             │
│ ├── tsconfig.json     ✅                                             │
│ ├── .eslintrc.cjs     ✅                                             │
│ ├── Dockerfile        ✅                                             │
│ └── README.md         ✅                                             │
│                                                                       │
│ Health:      ✅ Properly configured                                  │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ 📁 apps/web                                                           │
├──────────────────────────────────────────────────────────────────────┤
│ Type:        Frontend (React)                                         │
│ Git:         Git submodule                                           │
│ Remote:      git@github.com:org/web.git                              │
│ Branch:      develop                                                  │
│ Strategy:    Trunk-based                                             │
│                                                                       │
│ Status:                                                               │
│ ├── ⚠️ Uncommitted changes (12 files)                                │
│ └── Submodule ref: abc123 (2 commits behind)                         │
│                                                                       │
│ Config Files:                                                         │
│ ├── package.json      ✅                                             │
│ ├── tsconfig.json     ✅                                             │
│ ├── vite.config.ts    ✅                                             │
│ ├── tailwind.config.js ✅                                            │
│ └── README.md         ❌ MISSING                                     │
│                                                                       │
│ Health:      ⚠️ Missing README.md                                    │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ 📁 apps/worker                                                        │
├──────────────────────────────────────────────────────────────────────┤
│ Type:        Unknown                                                  │
│ Git:         None (part of monorepo)                                 │
│                                                                       │
│ Issues:                                                               │
│ ├── ❌ No package.json                                               │
│ ├── ❌ No README.md                                                  │
│ └── ❌ No Dockerfile                                                 │
│                                                                       │
│ Health:      ❌ Needs configuration                                  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## /apps init [name]

Initialize a new app in the monorepo:

```
/apps init api           # Create apps/api with standard structure
/apps init web --react   # Create React app
/apps init worker --bare # Create minimal structure
```

### Flow

```
User: /apps init api

Claude: Creating apps/api...

        What type of app is this?
        1. Backend API (Node.js/Express)
        2. Frontend (React/Vue/Svelte)
        3. Worker/Service
        4. Library/Package
        5. Other

User: 1

Claude: [Creates structure]

        apps/api/
        ├── src/
        │   └── index.ts
        ├── package.json
        ├── tsconfig.json
        ├── .eslintrc.cjs
        ├── Dockerfile
        └── README.md

        Git configuration?
        1. Part of monorepo (default)
        2. Independent repository
        3. Git submodule

User: 1

Claude: ✅ apps/api created (monorepo)

        Next steps:
        - cd apps/api && npm install
        - Update apps/devops/docker/docker-compose.yml
        - /story "Setup API" to track the work
```

---

## /apps git [app] [action]

Manage git configuration for an app:

```
/apps git api status     # Show git status for api
/apps git api init       # Initialize independent git
/apps git api remote     # Configure remote
/apps git api sync       # Sync with remote
/apps git api detach     # Convert to independent repo
/apps git api attach     # Convert to monorepo
```

### Git Types

| Type | Description | Behavior |
|------|-------------|----------|
| **monorepo** | Part of root git (DEFAULT) | Inherits ALL root conventions |
| **independent** | Own .git in app folder | PRESERVES existing rules |
| **submodule** | Git submodule | External, pinned version |

> ⚠️ **RULE**: Apps WITHOUT `.git/` follow root git-flow. Apps WITH `.git/` keep their existing rules.

### /apps git [app] init

> ⚠️ **WARNING**: This separates the app from monorepo. Only do this if you have a specific reason.

```
User: /apps git api init

Claude: ⚠️ WARNING: This will make apps/api an independent repository.

        The app will NO LONGER follow root git conventions.
        It will have its own branches, versions, and release cycle.

        Are you sure? This is typically only needed for:
        - Different team/org ownership
        - Regulatory/compliance separation
        - Sharing across multiple projects

        Options:
        1. YES, make independent (will ask for remote)
        2. NO, keep in monorepo (recommended)

User: 1

Claude: Remote URL? (e.g., git@github.com:org/api.git)

User: git@github.com:myorg/api-service.git

Claude: [Executes]
        cd apps/api
        git init
        git remote add origin git@github.com:myorg/api-service.git

        Detecting existing branch conventions...
        (If existing repo, will preserve its rules)

        ✅ apps/api is now independent

        Updated .claude/apps.json:
        {
          "apps": {
            "api": {
              "git": {
                "type": "independent",
                "preserve_rules": true,
                "remote": "git@github.com:myorg/api-service.git"
              }
            }
          }
        }

        Note: This app now has its own git lifecycle.
        Root /work, /done commands will detect this automatically.
```

### /apps git [app] detect

For apps with existing `.git/`, detect and store their conventions:

```
User: /apps git legacy-api detect

Claude: Analyzing apps/legacy-api/.git...

        Detected:
        ├── Remote: git@github.com:org/legacy-api.git
        ├── Main branch: master (not main)
        ├── Has develop: yes
        ├── Strategy: GitFlow
        └── Protected: master, develop

        These rules will be PRESERVED.

        Saved to .claude/apps.json:
        {
          "legacy-api": {
            "git": {
              "type": "independent",
              "preserve_rules": true,
              "detected_strategy": "gitflow",
              "detected_main": "master",
              "detected_develop": "develop"
            }
          }
        }
```

---

## /apps sync

Synchronize all apps with their remotes:

```
User: /apps sync

Claude: Syncing all apps...

        apps/devops: Part of monorepo (skipped)

        apps/api (independent):
        ├── Fetching origin...
        ├── Current: feature/#42-auth
        ├── Status: 3 ahead, 0 behind
        └── ✅ Up to date

        apps/web (submodule):
        ├── Fetching origin...
        ├── Current: develop
        ├── Status: 0 ahead, 2 behind
        └── ⚠️ Behind remote
            Run: cd apps/web && git pull

        apps/worker: No git (skipped)

        Summary:
        ├── ✅ Synced: 1
        ├── ⚠️ Behind: 1
        └── ⏭️ Skipped: 2
```

---

## /apps check

Verify all apps are properly configured:

```
User: /apps check

Claude: Checking all apps...

╔══════════════════════════════════════════════════════════════════════╗
║  🔍 APPS HEALTH CHECK                                                 ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  REQUIRED FILES                                                       ║
║  ─────────────────────────────────────────────────────────────────── ║
║  APP        package.json  README.md  Dockerfile  tsconfig            ║
║  devops     n/a           ✅         n/a         n/a                 ║
║  api        ✅            ✅         ✅          ✅                  ║
║  web        ✅            ❌         ✅          ✅                  ║
║  worker     ❌            ❌         ❌          ❌                  ║
║                                                                       ║
║  GIT CONFIGURATION                                                    ║
║  ─────────────────────────────────────────────────────────────────── ║
║  APP        Type          Remote     Branch Strategy                  ║
║  devops     monorepo      -          -                                ║
║  api        independent   ✅         gitflow                          ║
║  web        submodule     ✅         trunk                            ║
║  worker     monorepo      -          -                                ║
║                                                                       ║
║  ISSUES FOUND                                                         ║
║  ─────────────────────────────────────────────────────────────────── ║
║  ❌ apps/web: Missing README.md                                      ║
║  ❌ apps/worker: Missing package.json                                ║
║  ❌ apps/worker: Missing README.md                                   ║
║  ❌ apps/worker: Missing Dockerfile                                  ║
║                                                                       ║
╚══════════════════════════════════════════════════════════════════════╝

        Fix issues?
        1. AUTO-FIX: Generate missing files
        2. SHOW COMMANDS: Display fix commands
        3. SKIP: Ignore for now
```

---

## .claude/apps.json

Configuration file for app management:

```json
{
  "apps": {
    "devops": {
      "path": "apps/devops",
      "type": "devops",
      "git": {
        "type": "monorepo"
      }
    },
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
    "web": {
      "path": "apps/web",
      "type": "frontend",
      "stack": ["react", "typescript", "vite"],
      "git": {
        "type": "monorepo"
      },
      "docker": {
        "service": "web",
        "port": 5173
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
        "detected_develop": "develop",
        "remote": "git@github.com:org/legacy-service.git"
      }
    }
  }
}
```

### Key Principle

| Has `.git/`? | `git.type` | Behavior |
|--------------|------------|----------|
| No | `monorepo` | Follows root conventions |
| Yes | `independent` | `preserve_rules: true`, keeps its own rules |

---

## Data Collection

```bash
# List all apps
ls -d apps/*/

# For each app, check:
# 1. Has own .git?
if [ -d "apps/$app/.git" ]; then
    git -C "apps/$app" remote -v
    git -C "apps/$app" branch --show-current
    git -C "apps/$app" status --short
fi

# 2. Is submodule?
git submodule status | grep "$app"

# 3. Required files
for file in package.json README.md Dockerfile tsconfig.json; do
    test -f "apps/$app/$file" && echo "✅ $file" || echo "❌ $file"
done
```

---

## Integration with Other Commands

| Command | Integration |
|---------|-------------|
| `/work #42` | Reads apps.json to determine which app's branch to create |
| `/done` | Commits to correct app repo based on changed files |
| `/dashboard` | Shows per-app git status |
| `/onboard` | Detects and configures multi-git |
| `/sync` | Uses apps.json to sync all repos |
