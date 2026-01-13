---
name: design-principles
description: UI/UX design principles including anti-AI-slop guidelines. Use when creating UI, reviewing designs, or making aesthetic decisions.
---

# Design Principles

Guidelines for distinctive, high-quality UI.

## Anti-Slop Rules

### ❌ NEVER Use

- **Generic fonts**: Inter, Roboto, Arial, system fonts
- **Purple gradients** on white backgrounds
- **Symmetric layouts** that feel predictable
- **Cookie-cutter components** without character
- **Stock patterns**: Same hero sections, same card layouts
- **Overused effects**: Generic glassmorphism, basic shadows

### ✅ ALWAYS Apply

- **Distinctive typography**: Fonts with character
- **Bold color choices**: Not just gray + one accent
- **Asymmetric layouts**: Visual tension and interest
- **Quality animations**: Purposeful, not decorative
- **Texture and depth**: Subtle gradients, shadows, layers
- **Unique touches**: Something memorable

## Typography

Choose fonts that match brand personality:

| Mood | Font Examples |
|------|---------------|
| Modern/Tech | Space Grotesk, JetBrains Mono |
| Luxury | Playfair Display, Cormorant |
| Friendly | Nunito, Quicksand |
| Bold | Bebas Neue, Oswald |
| Editorial | Merriweather, Lora |

## Color Strategy

Don't default to gray + blue:

```
Primary:   Strong, not muted
Secondary: Complementary, not competing
Accent:    Bold, attention-grabbing
Background: Consider off-whites, subtle tints
Text:      Not pure black (#1a1a1a better)
```

## Layout Principles

1. **Break the grid** intentionally
2. **Overlap elements** for depth
3. **Vary rhythm** - not everything aligned
4. **White space** as design element
5. **Visual hierarchy** through size contrast

## Animation Guidelines

- **Enter animations**: Subtle, fast (200-300ms)
- **Hover states**: Immediate feedback (100ms)
- **Page transitions**: Smooth, purposeful
- **Loading states**: Engaging, not annoying
- **Micro-interactions**: Delight without distraction

## Before Coding UI

1. Check `docs/UX.md` for direction
2. Check `docs/DESIGN-SYSTEM.md` for tokens
3. Review persona preferences
4. Consider accessibility (WCAG 2.1)

## Review Checklist

- [ ] Font is not generic
- [ ] Colors are distinctive
- [ ] Layout has visual interest
- [ ] Animations are smooth
- [ ] Responsive and accessible
- [ ] Matches brand direction
