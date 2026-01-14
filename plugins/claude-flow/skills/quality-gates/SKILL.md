---
name: quality-gates
description: Quality gates configuration and enforcement. Use when setting up quality requirements, checking before PR, or configuring app-specific thresholds.
---

# Quality Gates

Configuration and enforcement of code quality standards per app.

## Overview

Each app has a `.claude/quality.json` file defining quality requirements:
- **Coverage** - Minimum test coverage percentage
- **Lint** - Maximum allowed warnings
- **Tests** - Whether tests must pass
- **Security** - Secret detection behavior

## File Location

```
apps/
├── api/
│   └── .claude/
│       └── quality.json     # API quality config
├── web/
│   └── .claude/
│       └── quality.json     # Web quality config
└── devops/
    └── (no quality.json - no code to test)
```

## Schema

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

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `coverage.minimum` | number | 80 | Minimum coverage % required |
| `coverage.enforce` | boolean | true | Block PR if coverage too low |
| `lint.warnings_allowed` | number | 0 | Max lint warnings allowed |
| `tests.required` | boolean | true | Tests must pass before PR |
| `security.block_secrets` | boolean | false | Block vs warn on secrets |

## Profiles

### Strict (Production Services)

```json
{
  "coverage": {
    "minimum": 90,
    "enforce": true
  },
  "lint": {
    "warnings_allowed": 0
  },
  "tests": {
    "required": true
  },
  "security": {
    "block_secrets": true
  }
}
```

### Standard (Most Apps)

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

### Relaxed (Prototypes)

```json
{
  "coverage": {
    "minimum": 50,
    "enforce": false
  },
  "lint": {
    "warnings_allowed": 5
  },
  "tests": {
    "required": false
  },
  "security": {
    "block_secrets": false
  }
}
```

## Enforcement Points

### 1. `/done` Command

Before creating PR, `/done` reads quality.json and runs checks:

```bash
cd apps/api

# Read config
quality=$(cat .claude/quality.json)
min_coverage=$(echo $quality | jq -r '.coverage.minimum')
enforce_coverage=$(echo $quality | jq -r '.coverage.enforce')

# Run checks
npm run lint
npm test
npm run coverage

# Verify coverage
if [ "$enforce_coverage" = "true" ]; then
  actual=$(cat coverage/coverage-summary.json | jq -r '.total.lines.pct')
  if [ "$actual" -lt "$min_coverage" ]; then
    echo "❌ Coverage $actual% < required $min_coverage%"
    exit 1
  fi
fi
```

### 2. `dev-agent`

dev-agent reads quality.json before coding to know requirements:
- Must write tests if `tests.required: true`
- Must achieve `coverage.minimum` percentage
- Must have 0 lint warnings if `lint.warnings_allowed: 0`

### 3. Guard Hooks

`guard-secrets.sh` reads `security.block_secrets`:
- If `true`: exit 2 (block operation)
- If `false`: exit 0 (warn only)

## Integration with Commands

### /done Flow

```
/done
  │
  ├─▶ Read .claude/quality.json
  │
  ├─▶ Run npm run lint
  │   └─ Check warnings <= lint.warnings_allowed
  │
  ├─▶ Run npm test
  │   └─ Check tests.required
  │
  ├─▶ Run npm run coverage
  │   └─ Check coverage >= coverage.minimum (if enforce)
  │
  ├─▶ Run npx tsc --noEmit (TypeScript)
  │
  └─▶ If all pass → Create PR
      If any fail → Block and report
```

### Quality Report

```
Quality Gates Check

App: api
Config: apps/api/.claude/quality.json

✅ Lint: 0 warnings (max: 0)
✅ Tests: 47/47 passed
✅ Coverage: 85.2% (min: 80%)
✅ TypeScript: No errors

All gates passed! Ready for PR.
```

### Failure Report

```
Quality Gates Check

App: api
Config: apps/api/.claude/quality.json

✅ Lint: 0 warnings (max: 0)
❌ Tests: 45/47 passed (2 failed)
⚠️ Coverage: 72.3% (min: 80%) - BLOCKING
✅ TypeScript: No errors

Failed gates:
• tests.required: 2 tests failing
• coverage.minimum: 72.3% < 80%

Fix issues before running /done again.
```

## Per-App Customization

Different apps can have different requirements:

```
apps/
├── api/
│   └── .claude/quality.json
│       coverage.minimum: 90      # Strict - core API
│
├── web/
│   └── .claude/quality.json
│       coverage.minimum: 70      # Lower - UI heavy
│
└── scripts/
    └── .claude/quality.json
        coverage.minimum: 50      # Relaxed - utility scripts
        tests.required: false
```

## Creating quality.json

### With /init

init-agent creates quality.json with standard profile:

```bash
mkdir -p apps/$APP_NAME/.claude
cat > apps/$APP_NAME/.claude/quality.json << 'EOF'
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
EOF
```

### With /onboard

onboard-agent creates quality.json for each app:

```bash
for app in apps/*/; do
  if [ "$app" != "apps/devops/" ]; then
    mkdir -p "$app/.claude"
    # Create with standard profile
  fi
done
```

### Manual Creation

```bash
cd apps/myapp
mkdir -p .claude
cat > .claude/quality.json << 'EOF'
{
  "coverage": { "minimum": 80, "enforce": true },
  "lint": { "warnings_allowed": 0 },
  "tests": { "required": true },
  "security": { "block_secrets": false }
}
EOF
```

## Best Practices

1. **Start Strict, Relax If Needed**
   - Begin with standard profile
   - Only relax if there's good reason
   - Document why in the file

2. **Coverage Is Not Everything**
   - High coverage != good tests
   - Focus on critical paths
   - Test edge cases, not just happy paths

3. **Zero Warnings Policy**
   - Warnings accumulate and become ignored
   - Either fix or disable the rule
   - `warnings_allowed: 0` keeps codebase clean

4. **Security Gates**
   - `block_secrets: true` for production APIs
   - `block_secrets: false` for internal tools
   - Always review warnings even if not blocking
