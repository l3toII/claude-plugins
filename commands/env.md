---
description: Manage environments - status, deploy, logs, rollback. Supports Vercel, Railway, Fly.io.
argument-hint: [action] [app] [environment]
allowed-tools: Read, Write, Glob, Bash(vercel:*), Bash(railway:*), Bash(fly:*), Bash(curl:*)
---

# /env - Environment Management

Manage deployment environments.

## Usage

```
/env                          # Show all environments status
/env status                   # Same as above
/env deploy api staging       # Deploy api to staging
/env deploy api production    # Deploy to production (requires confirmation)
/env logs api staging         # View logs
/env rollback api staging     # Rollback to previous version
```

## /env status

Display status for all apps and environments:

```
📊 Environment Status

API
├── staging:    v1.3.0 ✅ (deployed 2h ago)
├── production: v1.2.0 ✅ (deployed 3d ago)
└── health: all checks passing

Web
├── staging:    v2.1.0 ✅
├── production: v2.0.0 ✅
└── health: all checks passing
```

## /env deploy [app] [env]

### Staging Deploy

```bash
# Automatic, no confirmation needed
railway up -s api-staging
# or
vercel --env staging
# or
fly deploy --app api-staging
```

### Production Deploy

**Requires double confirmation:**

```
⚠️ PRODUCTION DEPLOY

App: api
Version: v1.3.0
Environment: production

Checks:
✅ Tests passing
✅ Staging tested
✅ All stories Done
⚠️ 2 hours since last staging deploy

Type "deploy production api" to confirm:
```

```bash
railway up -s api-production
```

## /env logs [app] [env]

```bash
# Railway
railway logs -s api-staging

# Vercel
vercel logs api-staging

# Fly.io
fly logs --app api-staging
```

Display last 100 lines, highlight errors.

## /env rollback [app] [env]

### 1. Show History

```
Recent deploys:
1. v1.3.0 (current) - 2h ago
2. v1.2.0 - 3d ago
3. v1.1.0 - 1w ago
```

### 2. Confirm Rollback

```
Rollback api staging to v1.2.0?
```

### 3. Execute

```bash
railway rollback -s api-staging
```

### 4. Log

Save to `.claude/deploy-history.json`

## Configuration

`.claude/environments.json`:
```json
{
  "apps": {
    "api": {
      "platform": "railway",
      "staging": {
        "service": "api-staging",
        "auto_deploy": true
      },
      "production": {
        "service": "api-production",
        "protected": true
      }
    }
  }
}
```
