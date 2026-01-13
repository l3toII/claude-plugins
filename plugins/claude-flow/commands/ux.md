---
description: Manage UX artifacts - personas, user journeys, design system. Apply anti-slop principles.
argument-hint: [artifact]
allowed-tools: Read, Write, Edit, Glob, Grep
---

# /ux - UX Management

Manage UX documentation and design artifacts.

## Usage

```
/ux                    # Show UX status
/ux persona            # Create/edit persona
/ux journey            # Create user journey
/ux design-system      # Manage design tokens
/ux review             # Review UI for anti-slop
```

## /ux persona

Create or update persona in `docs/PERSONAS.md`:

Questions:
1. "What's the persona name?"
2. "Demographics (age, job, location)?"
3. "Tech savviness level?"
4. "Goals and motivations?"
5. "Frustrations and pain points?"
6. "Quote that represents them?"

Output:
```markdown
## Sarah - The Busy Professional

### Demographics
- Age: 32
- Job: Marketing Manager
- Location: Urban
- Tech level: Intermediate

### Goals
- Save time on repetitive tasks
- Look professional to clients

### Frustrations
- Too many tools to manage
- Steep learning curves

### Quote
"I just want it to work without reading a manual."
```

## /ux journey

Create user journey map:

```markdown
# Journey: First-time User Onboarding

## Persona: Sarah

## Stages

### 1. Discovery
- Touchpoint: Landing page
- Action: Signs up
- Emotion: Curious 😊
- Pain points: None

### 2. Setup
- Touchpoint: Onboarding wizard
- Action: Configures account
- Emotion: Focused 🤔
- Pain points: Too many options

### 3. First Use
- Touchpoint: Dashboard
- Action: Creates first project
- Emotion: Accomplished 🎉
- Pain points: Finding features
```

## /ux design-system

Manage `docs/DESIGN-SYSTEM.md`:

```markdown
# Design System

## Colors
- Primary: #2563EB (Blue 600)
- Secondary: #7C3AED (Violet 600)
- Accent: #F59E0B (Amber 500)
- Background: #F8FAFC
- Text: #1E293B

## Typography
- Headings: Inter Bold
- Body: Inter Regular
- Code: JetBrains Mono

## Spacing
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
```

## /ux review (Anti-Slop Check)

Review UI code for generic AI patterns:

### ❌ Avoid
- Generic fonts (Inter, Roboto, Arial)
- Purple gradients on white
- Symmetric predictable layouts
- Cookie-cutter components

### ✅ Require
- Distinctive typography
- Strong color accents
- Asymmetric layouts
- Quality animations
- Texture and depth

Output:
```
🎨 Anti-Slop Review

⚠️ Issues Found:
1. Button uses system font → Use brand font
2. Card has no shadow/depth → Add subtle shadow
3. Layout too symmetric → Add visual interest

✅ Good:
1. Color palette is distinctive
2. Animations are smooth
3. Typography has character
```
