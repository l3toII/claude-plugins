---
name: story
description: Intelligent story creation and refinement. Adapts depth based on complexity. Use for /story command.
---

# Story

Skill intelligent de création et refinement de stories. Adapte son approche selon la complexité et le contexte.

## Modes de fonctionnement

### Détection automatique

Le skill évalue la demande et adapte son approche :

| Signal | Interprétation | Approche |
|--------|----------------|----------|
| Demande précise, technique | Simple | Création rapide, peu de questions |
| Demande floue, large scope | Complexe | Questions de clarification |
| Plusieurs features mélangées | Décomposition | Identifier et séparer les stories |
| Story existante (S-XXX) | Refinement | Compléter/améliorer la story |

### Flags explicites

L'utilisateur peut forcer un mode :

| Flag | Comportement |
|------|--------------|
| `--draft` | Création légère, on raffinera plus tard |
| `--ready` | Aller jusqu'à ready (questions + GitHub issue) |
| (défaut) | Adaptatif selon complexité |

## Comportement par contexte

### Nouvelle story simple

```
User: /story "Ajouter bouton logout dans le header"

Claude: Story claire et précise.

  **S-007: Bouton logout dans le header**
  - Type: feature
  - Scope: Bouton dans header, déconnexion, redirect login

  Créer l'issue GitHub ? (oui → ready, non → draft)
```

### Nouvelle story complexe/floue

```
User: /story "Améliorer l'onboarding"

Claude: Cette demande mérite clarification.

  Questions :
  - Quel est le problème actuel avec l'onboarding ?
  - Quels utilisateurs sont concernés ?
  - Qu'est-ce qui définit un "bon" onboarding pour toi ?

[... dialogue ...]

Claude: Je propose 3 stories :
  - S-007: Simplifier le formulaire d'inscription
  - S-008: Ajouter un tutoriel interactif
  - S-009: Email de bienvenue personnalisé

  Confirmer ?
```

### Refinement d'une story existante

```
User: /story S-005

Claude: [Lit la story S-005]

  Story actuelle : "OAuth Google integration"
  Status: draft

  Pour la passer en ready, je dois clarifier :
  - Login seulement ou aussi inscription ?
  - Lier avec compte existant si même email ?

[... dialogue ...]

Claude: Story S-005 mise à jour et prête.
  → Issue GitHub créée: org/project#42
```

### Mode draft (rapide)

```
User: /story --draft "Intégration Stripe pour les paiements"

Claude:
  ✅ Créé S-010: Intégration Stripe (draft)

  À raffiner plus tard avec /story S-010
```

## Checklist avant création

### Pour draft (minimum)
- [ ] Titre clair
- [ ] Type identifié (feature/tech/bug/ux)
- [ ] Description sommaire

### Pour ready (complet)
- [ ] Contexte expliqué (pourquoi)
- [ ] Objectif clair (En tant que... je veux... afin de...)
- [ ] Critères d'acceptation testables
- [ ] Hors scope défini
- [ ] Cohérence avec docs existantes vérifiée
- [ ] Issue GitHub créée

## Vérifications de cohérence

Avant de créer une story, vérifier :

1. **Pas de doublon** : `project/backlog/` ne contient pas déjà cette story
2. **Alignement architecture** : `engineering/` pour contraintes techniques
3. **Cohérence vision** : `docs/` pour la vision produit si documentée

## Questions types par niveau

### Questions légères (story simple)
- "C'est bien [reformulation] ?"
- "Un cas particulier à gérer ?"

### Questions profondes (story complexe)
- "Quel problème résout-on exactement ?"
- "Pour qui ? Dans quel contexte ?"
- "Comment sait-on que c'est réussi ?"
- "Qu'est-ce qui est hors scope ?"
- "Y a-t-il des dépendances ?"

## Anti-patterns détectés

Le skill alerte si :

| Pattern détecté | Alerte |
|-----------------|--------|
| Story trop large | "Cette story semble couvrir plusieurs besoins. Décomposer ?" |
| Critères vagues | "Ce critère n'est pas testable. Reformuler ?" |
| Solution sans problème | "C'est une solution. Quel est le problème à résoudre ?" |
| Doublon potentiel | "S-003 semble similaire. Lien ou doublon ?" |

## Template

Utilise : `${CLAUDE_PLUGIN_ROOT}/templates/story.md`

## Intégration GitHub

### Créer une issue (draft → ready)

Quand l'utilisateur confirme vouloir créer l'issue GitHub :

```bash
# Créer l'issue et capturer le numéro
gh issue create --title "S-XXX: Titre de la story" --body "Lien: project/backlog/S-XXX-slug.md"
```

Après création :
1. Récupérer le numéro d'issue retourné par `gh`
2. Mettre à jour le frontmatter de la story :
   - `status: ready`
   - `github: org/repo#XX`

### Passer une story draft en ready

```bash
/story ready S-005
```

Actions :
1. Lire la story `project/backlog/S-005-*.md`
2. Vérifier que `status: draft`
3. Créer l'issue GitHub avec `gh issue create`
4. Mettre à jour le frontmatter (`status: ready`, `github: ...`)

### Fermer une issue (done)

Quand une story passe en `done` :
```bash
gh issue close <numéro>
```

## Conventions

### Types de stories

| Type | Usage |
|------|-------|
| `feature` | Nouvelle fonctionnalité utilisateur |
| `tech` | Amélioration technique, refactoring |
| `bug` | Correction d'un problème |
| `ux` | Amélioration interface/expérience |

### Statuts et GitHub

```
draft → ready → active → review → done
```

| Status | Issue GitHub | Sprint possible |
|--------|--------------|-----------------|
| `draft` | ❌ | ❌ |
| `ready` | ✅ | ✅ |
| `active` | ✅ | ✅ |
| `review` | ✅ | ✅ |
| `done` | ✅ (fermée) | ✅ |

**Règle** : `draft` = local, `ready` = issue GitHub créée.

### Numérotation

- Format : `S-XXX` (3 chiffres)
- Séquentiel, jamais réutilisé
- Fichier : `project/backlog/S-XXX-slug.md`

### Slug

Généré depuis le titre :
- Lowercase, espaces → tirets
- Max 50 caractères
- Ex: "OAuth Login" → `oauth-login`
