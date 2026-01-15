---
id: S-002
title: Implémenter /story avec clarification interactive
type: feature
status: ready
sprint: sprint-00
created: 2025-01-15
---

# S-002: Implémenter /story avec clarification interactive

## Contexte

Actuellement, créer des stories demande de les écrire une par une avec un format technique. Les utilisateurs veulent pouvoir exprimer leurs besoins en langage naturel et laisser Claude structurer ça en stories.

## Objectif

En tant qu'utilisateur, je veux décrire mes besoins en langage naturel afin que Claude crée les stories appropriées après clarification.

## Description

La commande `/story` doit :

1. **Accepter une description libre** : L'utilisateur décrit ce qu'il veut sans format imposé
2. **Analyser et décomposer** : Claude identifie s'il y a une ou plusieurs stories
3. **Clarifier** : Claude pose des questions pour lever les ambiguïtés
4. **Confirmer** : L'utilisateur valide avant création
5. **Créer** : Génération des fichiers story avec template narratif
6. **Proposer GitHub** : Demander si créer l'issue GitHub (draft → ready)

## Règle draft/ready

| Status | Fichier local | Issue GitHub | Peut être dans sprint |
|--------|---------------|--------------|----------------------|
| `draft` | ✅ | ❌ | ❌ |
| `ready` | ✅ | ✅ | ✅ |

- **draft** : Story en cours de rédaction, locale seulement
- **ready** : Story finalisée avec issue GitHub, peut être planifiée

`/sprint plan` refuse les stories `draft` → doit d'abord passer en `ready`.

## Critères d'acceptation

- [x] `/story "description libre"` déclenche le flow interactif
- [x] Claude identifie si plusieurs stories sont nécessaires
- [x] Claude pose des questions de clarification si ambiguïté
- [x] L'utilisateur confirme avant création
- [x] Fichiers créés dans `project/backlog/S-XXX-slug.md`
- [x] Template narratif (Contexte, Objectif, Description, Critères, Hors scope)
- [x] ID auto-incrémenté
- [x] Option `--type` pour forcer un type (feature, tech, bug, ux)
- [x] Après confirmation, demande "Créer l'issue GitHub ?" (oui → ready, non → draft)
- [x] Si oui : crée issue dans repo principal, lie dans le fichier story
- [x] Option `--draft` pour forcer draft sans question
- [x] Option `--ready` pour forcer ready (crée issue sans question)

## Hors scope

- Assignation automatique à un sprint
- Estimation de points
- Création de tickets par app (fait par `/work`)

## Exemple de flow

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

Claude: Créer les issues GitHub maintenant ? (oui/non)
        - oui : stories prêtes à être planifiées (ready)
        - non : stories en brouillon (draft)

User: oui

Claude: ✅ Créé S-005: Authentification Google OAuth
           → Issue: org/project#42
        ✅ Créé S-006: Reset Password par email
           → Issue: org/project#43
```

## Notes techniques

Fichiers modifiés :
- `apps/flowc/commands/story.md` - Logique de la commande
- `apps/flowc/skills/story.md` - Skill adaptatif + intégration GitHub
- `apps/flowc/templates/story.md` - Template narratif

Intégration GitHub :
- Utiliser `gh issue create` pour créer l'issue
- Stocker le lien dans le frontmatter : `github: org/project#42`
