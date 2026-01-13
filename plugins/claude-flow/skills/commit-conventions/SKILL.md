---
name: commit-conventions
description: Conventional commit format and best practices. Use when creating commits, generating commit messages, or reviewing commit history.
---

# Commit Conventions

Follow the Conventional Commits specification for all commits.

## Format

```
type(scope): description (#ticket)

[optional body]

[optional footer]
```

## Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add OAuth login` |
| `fix` | Bug fix | `fix(api): handle null response` |
| `docs` | Documentation | `docs(readme): update install steps` |
| `style` | Formatting (no code change) | `style(ui): fix indentation` |
| `refactor` | Code refactoring | `refactor(auth): extract service` |
| `test` | Adding tests | `test(auth): add OAuth tests` |
| `chore` | Maintenance | `chore(deps): update packages` |
| `perf` | Performance | `perf(api): cache user queries` |
| `ci` | CI/CD changes | `ci: add deploy workflow` |

## Scope

Derive from the main area affected:
- `auth`, `api`, `ui`, `db`, `config`
- Or feature name: `login`, `dashboard`, `payments`

## Description

- Imperative mood: "add" not "added" or "adds"
- Lowercase first letter
- No period at end
- Max 72 characters

## Ticket Reference

Always include ticket number:
- `feat(auth): add OAuth login (#42)`
- `fix(api): handle timeout (#43)`

## Breaking Changes

Use `!` or footer:
```
feat(api)!: change response format

BREAKING CHANGE: Response now uses camelCase
```

## Examples

```
feat(auth): implement Google OAuth login (#42)
fix(api): handle null user in session endpoint (#43)
docs(readme): add deployment instructions
refactor(ui): extract Button component from Form
test(auth): add integration tests for OAuth flow (#42)
chore(deps): update React to 18.2.0
perf(db): add index on users.email column
```

## Multi-line Body

For complex changes:
```
feat(auth): implement OAuth login (#42)

- Add GoogleAuthService
- Create OAuth callback handler
- Update login page with Google button

Closes #42
```
