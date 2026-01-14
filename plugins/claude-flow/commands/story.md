---
description: Create a new story (S-XXX). Automatically creates GitHub issues in principal repo and per-app repos.
argument-hint: [title] [--category functional|technical|ux]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh:*), AskUserQuestion
---

# /story - Create Story

Create a new unified story with automatic GitHub issue creation.

## Usage

```
/story                              # Interactive mode
/story "OAuth login"                # Quick functional story
/story "Migrate DB" --category tech # Technical story
/story "Redesign nav" --category ux # UX story
```

## Workflow

### 1. Gather Basic Info

If no title provided, ask:
- Story title
- Category (functional/technical/ux)

### 2. Determine Category

```
functional (default) → User-facing feature
technical           → Infrastructure, refactor, migration
ux                  → Design, usability changes
```

### 3. Get Story Details (based on category)

**For functional:**
- "As a [persona], I want [X] so that [Y]"
- Acceptance criteria

**For technical:**
- Objective
- Justification (perf/security/debt/enabler)

**For ux:**
- Current state problem
- Proposed change

### 4. Identify Impacted Apps

```bash
# List available apps (those with .git)
for app in apps/*/; do
    if [ -d "$app/.git" ]; then
        echo "$(basename $app)"
    fi
done
```

Ask user: "Which apps are impacted?" with multi-select.

### 5. Auto-number Story

```bash
# Find next story number
last=$(ls project/backlog/S-*.md 2>/dev/null | sort -V | tail -1 | grep -oE '[0-9]+')
next=$((${last:-0} + 1))
printf "S-%03d" $next
```

### 6. Create Story File

Create `project/backlog/S-XXX-slug.md`:

```markdown
# S-XXX: Title

## Category
[functional|technical|ux]

## Story
[content based on category]

## Description
[additional context]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Apps Impacted
- app1
- app2

## Tickets
| App | Issue | PR | Status |
|-----|-------|-----|--------|
| app1 | - | - | Pending |
| app2 | - | - | Pending |

## Status
Draft

## Metadata
- Created: [today]
- Sprint: unassigned
- Estimate: unestimated
- Priority: Medium
- GitHub Issue: (pending)
```

### 7. Create GitHub Issue (Principal Repo)

```bash
# Get principal repo info
principal_remote=$(git remote get-url origin)
principal_owner=$(echo $principal_remote | sed -E 's/.*[:/]([^/]+)\/([^/]+)(\.git)?$/\1/')
principal_repo=$(echo $principal_remote | sed -E 's/.*[:/]([^/]+)\/([^/]+)(\.git)?$/\2/' | sed 's/\.git$//')

# Create issue
gh issue create \
  --repo "$principal_owner/$principal_repo" \
  --title "S-XXX: Title" \
  --body "## Story

[story content]

## Acceptance Criteria
- [ ] Criterion 1

## Apps
- [ ] app1
- [ ] app2

---
Story file: \`project/backlog/S-XXX-slug.md\`" \
  --label "story,${category}"
```

Save issue number to story file.

### 8. Create Tickets (Per-App Issues)

For each impacted app:

```bash
app="api"
cd apps/$app

# Get app's remote
app_remote=$(git remote get-url origin)
app_owner=$(echo $app_remote | sed -E 's/.*[:/]([^/]+)\/([^/]+)(\.git)?$/\1/')
app_repo=$(echo $app_remote | sed -E 's/.*[:/]([^/]+)\/([^/]+)(\.git)?$/\2/' | sed 's/\.git$//')

# Create issue in app repo
gh issue create \
  --repo "$app_owner/$app_repo" \
  --title "[S-XXX] Title - $app implementation" \
  --body "## Parent Story
S-XXX in principal repo (issue #YY)

## Scope for $app
[app-specific scope]

## Acceptance Criteria (for this app)
- [ ] App-specific criterion

---
Part of: S-XXX" \
  --label "story-ticket"

cd ../..
```

Update story file with ticket issue numbers.

### 9. Update Story with Links

Edit `project/backlog/S-XXX-slug.md`:
- Add principal GitHub Issue number
- Add ticket issue numbers per app

### 10. Summary

```
✅ Story S-042 created!

📋 Story: project/backlog/S-042-oauth-login.md
🔗 Principal Issue: #42

📦 Tickets created:
   • api: #15 (github.com/org/api/issues/15)
   • web: #23 (github.com/org/web/issues/23)

Next steps:
• /sprint plan - Add to sprint
• /work S-042 - Start working
```

## Guards

**No apps with .git found:**
> "No apps found with their own git repository. Run /init or /onboard first."

**App has no remote:**
> "App 'X' has no remote configured. Set up with: cd apps/X && git remote add origin URL"

**gh not authenticated:**
> "GitHub CLI not authenticated. Run: gh auth login"

## Quick Mode

For rapid creation without prompts:

```
/story "Title" --apps api,web --category functional
```

Creates story with defaults, issues in all specified apps.
