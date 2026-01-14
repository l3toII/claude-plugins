---
description: Start working on a story. Prompts for app selection, creates branch in app repo, loads context.
argument-hint: [S-XXX] [--app name]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh:*), AskUserQuestion
---

# /work - Start Working on Story

Begin work on a specific story, targeting one app at a time.

## Usage

```
/work S-042           # Work on story (will ask which app)
/work S-042 --app api # Work on story, api app specifically
/work                 # Resume previous work
```

## Workflow

### 0. Resume Previous Work (if no args)

```bash
# Check session
if [ -f ".claude/session.json" ]; then
    active_story=$(jq -r '.active_story // empty' .claude/session.json)
    active_app=$(jq -r '.active_app // empty' .claude/session.json)

    if [ -n "$active_story" ] && [ -n "$active_app" ]; then
        echo "Resume: $active_story on $active_app"
    fi
fi
```

If session exists, offer to resume or select new work.

### 1. Load Story

```bash
# Find story file
story_file=$(ls project/backlog/S-${number}-*.md 2>/dev/null | head -1)

if [ -z "$story_file" ]; then
    echo "Story S-$number not found. Create it with /story"
    exit 1
fi
```

Parse story to extract:
- Title
- Category
- Acceptance criteria
- Apps impacted
- Tickets status

### 2. Select App

If `--app` not provided, show apps from story:

```
Story S-042: OAuth Login

Apps impacted:
  1. api  - Ticket #15 (Pending)
  2. web  - Ticket #23 (Pending)

Which app to work on?
```

Use AskUserQuestion for selection.

### 3. Get App's Repo Config

```bash
app="api"
cd apps/$app

# Get conventions for this app's repo
config=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-repo-config.sh)
main_branch=$(echo "$config" | jq -r '.main_branch')
feature_pattern=$(echo "$config" | jq -r '.branch_patterns.feature // "feature/*"')
```

### 4. Get Ticket Number

Extract ticket issue number from story file for selected app:

```bash
# From story's Tickets table
ticket_number=$(grep "| $app |" "$story_file" | grep -oE '#[0-9]+' | head -1 | tr -d '#')
```

### 5. Create Branch in App Repo

```bash
cd apps/$app

# Ensure on main and up to date
git checkout $main_branch
git pull origin $main_branch

# Create feature branch with ticket reference
# Adapt to repo's pattern
branch_name="feature/#${ticket_number}-${slug}"
git checkout -b "$branch_name"
```

### 6. Update Session

Save to `.claude/session.json`:

```json
{
  "active_story": "S-042",
  "active_app": "api",
  "active_ticket": "15",
  "active_branch": "feature/#15-oauth-login",
  "app_path": "apps/api",
  "started_at": "2025-01-14T10:00:00Z",
  "repo_config_source": "auto_detected"
}
```

### 7. Update Story Status

If story was "Ready", change to "In Progress":

```bash
sed -i '' 's/## Status\nReady/## Status\nIn Progress/' "$story_file"
```

Update ticket status in story's table:
```
| api | #15 | - | In Progress |
```

### 8. Load Context & Display

Read and display:
- Story acceptance criteria
- Technical notes relevant to this app
- Related files (if mentioned)
- App's quality requirements (`.claude/quality.json`)

```
Ready to work on S-042: OAuth Login (api)

Branch: feature/#15-oauth-login
Ticket: api#15
Convention: conventional (auto-detected)

Acceptance Criteria:
□ User can click 'Login with Google'
□ OAuth flow completes successfully
□ User session is created

Technical Notes:
- New endpoint: POST /auth/google
- Use passport-google-oauth20

Quality Requirements (apps/api/.claude/quality.json):
- Coverage: >= 80%
- Lint: 0 warnings
- Tests: required

Suggested approach:
1. Create GoogleAuthService
2. Add /auth/google route
3. Write tests
4. Update API docs
```

### 9. Optionally Delegate to dev-agent

Ask user:
```
Start coding with dev-agent? [Y/n]
```

If yes, fork to dev-agent with full context.

## Session Commands

While working:
- `/work` - Show current work status
- `/work S-XXX` - Switch to different story
- `/work S-042 --app web` - Switch to different app on same story

## Guards

**Story not found:**
> "Story S-XXX not found. Create it with /story"

**App not in story:**
> "App 'X' is not impacted by this story. Apps: api, web"

**App has no .git:**
> "App 'X' has no git repository. Run /onboard or initialize git."

**Ticket not created:**
> "No ticket found for app 'X'. Create with /story or manually."

**Uncommitted changes in app:**
> "Uncommitted changes in apps/X. Commit or stash first."

## Multi-App Workflow

When working on a story that spans multiple apps:

```
/work S-042 --app api    # Start with API
[implement API changes]
/done                    # PR for API

/work S-042 --app web    # Continue with Web
[implement Web changes]
/done                    # PR for Web

# When all app PRs merged, story → Done
```
