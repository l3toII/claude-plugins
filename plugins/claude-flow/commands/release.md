---
description: Create a release with changelog, tag, and GitHub release. Optionally deploy to staging.
argument-hint: [app] [--dry-run]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(vercel:*), Bash(railway:*), Bash(fly:*)
---

# /release - Create Release

Create a versioned release with changelog and deployment.

## Usage

```
/release              # Release all apps with changes
/release api          # Release specific app
/release --dry-run    # Preview without executing
```

## Workflow

### 1. Pre-release Checks

- All sprint stories Done?
- Tests passing?
- No uncommitted changes?

If not ready:
> "❌ Not ready for release. Complete pending stories first."

### 2. Determine Version

Based on commits since last release:
- `feat:` → Minor bump (1.2.0 → 1.3.0)
- `fix:` → Patch bump (1.2.0 → 1.2.1)
- `feat!:` or `BREAKING CHANGE:` → Major bump (1.2.0 → 2.0.0)

### 3. Generate Changelog

Parse commits and create/update `CHANGELOG.md`:

```markdown
## [1.3.0] - 2025-01-12

### Added
- OAuth login with Google (#42)
- User profile page (#43)

### Fixed
- Session timeout issue (#44)

### Changed
- Updated dependencies
```

### 4. Create Tag

```bash
git tag -a v1.3.0 -m "Release v1.3.0"
# or for monorepo:
git tag -a api/v1.3.0 -m "API Release v1.3.0"
```

### 5. Create GitHub Release

```bash
gh release create v1.3.0 \
  --title "v1.3.0" \
  --notes "$(cat CHANGELOG_SECTION.md)"
```

### 6. Deploy to Staging

If auto_deploy enabled:
```bash
# Vercel
vercel --prod

# Railway
railway up

# Fly.io
fly deploy
```

### 7. Summary

```
✅ Release v1.3.0 created!

📝 Changelog: Updated
🏷️ Tag: v1.3.0
🚀 GitHub Release: https://github.com/.../releases/tag/v1.3.0
🌐 Staging: https://api-staging.example.com

Next: Test staging, then /env deploy api production
```

## Multi-app Release

For monorepo, release each app separately:
- `api/v1.3.0`
- `web/v2.1.0`
- `mobile/v1.0.5`
