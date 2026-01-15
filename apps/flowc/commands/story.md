---
description: Create or refine stories. Adapts depth based on complexity.
argument-hint: '"description" | S-XXX | --draft "description"'
skills: story
---

# /story - Créer et Raffiner des Stories

Utilise le skill `story` pour une création intelligente et adaptative.

- Demande simple → création rapide
- Demande floue → questions de clarification
- Story existante (S-XXX) → refinement

## Usage

```bash
/story "Ajouter bouton logout"           # Création adaptative
/story "Améliorer l'onboarding"          # Détecte complexité → questions
/story S-005                              # Raffiner story existante
/story --draft "Intégration Stripe"      # Force draft (rapide)
/story --ready "Feature urgente"          # Force ready (complet)
/story tech "Refactorer auth module"     # Force type
```

## Comportement adaptatif

Le skill `story` adapte sa profondeur selon la demande :

| Demande | Comportement |
|---------|--------------|
| Précise, simple | Création rapide, peu de questions |
| Floue, large | Questions de clarification |
| Plusieurs besoins | Décomposition en stories |
| S-XXX existante | Refinement de la story |

### Story simple

```
User: /story "Ajouter bouton logout"

Claude: Story claire.
  S-007: Bouton logout dans le header
  Créer l'issue GitHub ? (oui/non)
```

### Story complexe

```
User: /story "Améliorer l'onboarding"

Claude: Cette demande mérite clarification.
  - Quel problème avec l'onboarding actuel ?
  - Quels utilisateurs concernés ?
  ...
```

### Refinement

```
User: /story S-005

Claude: [Lit S-005, complète les manques]
  Pour passer en ready, je clarifie :
  - ...
```

## Confirmation

Claude présente un résumé des stories à créer :
- Titre proposé
- Type identifié
- Points clés

L'utilisateur confirme ou ajuste avant création.

## GitHub Issue

Après confirmation, Claude demande :
```
Créer les issues GitHub maintenant ?
- oui : stories prêtes à être planifiées (ready)
- non : stories en brouillon local (draft)
```

## Création

Pour chaque story confirmée :
- Génère l'ID suivant (S-XXX)
- Crée le fichier `project/backlog/S-XXX-slug.md`
- Si ready : crée l'issue GitHub et lie dans le frontmatter

## Règle draft/ready

| Status | Fichier local | Issue GitHub | Sprint possible |
|--------|---------------|--------------|-----------------|
| `draft` | ✅ | ❌ | ❌ |
| `ready` | ✅ | ✅ | ✅ |

- **draft** : Brouillon local, pas encore prêt pour planification
- **ready** : Issue GitHub créée, peut être ajoutée à un sprint

`/sprint plan` refuse les stories `draft`.

## Options

| Option | Description |
|--------|-------------|
| `tech` | Force le type Technical Story |
| `bug` | Force le type Bug |
| `ux` | Force le type UX Story |
| `--draft` | Force draft, skip la question GitHub |
| `--ready` | Force ready, crée l'issue sans question |
| `--no-confirm` | Skip toutes les confirmations (usage avancé) |

## Exemple Complet

```
User: /story "Je veux que les users puissent se logger avec Google
       et aussi reset leur password par email"

Claude: Je comprends 2 fonctionnalités distinctes :

  1. **Login Google** - Authentification via OAuth Google
  2. **Reset Password** - Récupération de mot de passe par email

  Quelques questions :
  - Login Google : uniquement connexion ou aussi inscription ?
  - Reset Password : délai d'expiration du lien ?

User: Google pour login et inscription, lien valide 24h

Claude: Parfait. Je vais créer 2 stories :

  **S-005: Authentification Google OAuth**
  - Login ET inscription via Google
  - Type: feature

  **S-006: Reset Password par email**
  - Lien de reset valide 24h
  - Type: feature

  Confirmer la création ? (oui/non)

User: oui

Claude: Créer les issues GitHub maintenant ?
        - oui : stories prêtes à être planifiées (ready)
        - non : stories en brouillon local (draft)

User: oui

Claude: ✅ Créé S-005: Authentification Google OAuth
           → Issue: org/project#42
        ✅ Créé S-006: Reset Password par email
           → Issue: org/project#43
```

## Template Story

Utilise le template : `${CLAUDE_PLUGIN_ROOT}/templates/story.md`

## Règles

1. **Toujours clarifier** : Ne jamais créer sans comprendre
2. **Toujours confirmer** : Sauf si `--no-confirm`
3. **Un fichier par story** : Jamais de stories multiples dans un fichier
4. **ID unique** : Jamais réutiliser un ID même si story supprimée
5. **draft = local** : Pas d'issue GitHub
6. **ready = GitHub** : Issue créée, prête pour sprint

## Passer une story draft en ready

Si une story existe en `draft` et doit passer en `ready` :

```bash
/story ready S-005
```

Cela crée l'issue GitHub et met à jour le fichier.
