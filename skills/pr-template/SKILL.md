---
name: pr-template
description: Pull request structure and content. Use when creating PRs, writing PR descriptions, or reviewing PR completeness.
---

# Pull Request Template

Structure for comprehensive, reviewable PRs.

## Title Format

```
type(scope): description (#ticket)
```

Same as commit convention:
- `feat(auth): implement OAuth login (#42)`
- `fix(api): handle session timeout (#43)`

## Description Structure

```markdown
## Summary
Brief description of what this PR does and why.

## Related Story
Closes #42
See: docs/backlog/functional/US-042-oauth-login.md

## Changes
- Added GoogleAuthService for OAuth flow
- Updated login page with Google button
- Created callback handler for OAuth redirect
- Added user profile sync from Google

## To Test
1. Navigate to /login
2. Click "Continue with Google"
3. Complete Google OAuth flow
4. Verify redirect to dashboard
5. Check profile shows Google avatar

## Potential Regression
- Existing email/password login flow
- Session management and cookies
- User profile display
- Remember me functionality

## Screenshots
(If UI changes - before/after)

## Checklist
- [ ] Tests pass locally
- [ ] Lint clean (0 warnings)
- [ ] Documentation updated
- [ ] Self-reviewed code
- [ ] No console.logs or debug code
```

## To Test Section

Be specific:
1. Step-by-step instructions
2. Expected results
3. Edge cases to verify

## Potential Regression

List what could break:
- Related features
- Shared components
- Database changes impact

## Labels

Add appropriate labels:
- `feature`, `bugfix`, `refactor`
- `needs-review`, `work-in-progress`
- `breaking-change` if applicable

## Reviewers

Assign based on:
- CODEOWNERS file
- Changed file areas
- Team expertise
