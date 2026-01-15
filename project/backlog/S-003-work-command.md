---
id: S-003
title: Implémenter /work basique
type: feature
status: ready
sprint: sprint-00
created: 2025-01-15
---

# S-003: Implémenter /work basique

## Contexte

Après avoir créé une story avec `/story`, l'utilisateur doit pouvoir démarrer le travail dessus. La commande `/work` initialise l'environnement de travail et prépare un plan d'implémentation.

## Objectif

En tant que développeur,
je veux lancer `/work S-XXX` pour démarrer le travail sur une story
afin d'avoir ma session configurée et un plan d'implémentation proposé.

## Description

La commande `/work` doit :

1. **Valider** : Vérifier que la story est `ready` (guard si non → "utilise `/story` d'abord")
2. **Configurer la session** :
   - Créer/mettre à jour `.claude/session.json`
   - Passer la story en status `active`
3. **Créer la branche** : `feature/#XXX-slug` depuis main
4. **Créer le ticket GitHub** : Dans le repo de l'app (ou repo principal si mono-app)
5. **Proposer un plan** : Dev Agent analyse les acceptance criteria et propose l'implémentation

### Mono-app vs Multi-app

| Contexte | Comportement |
|----------|--------------|
| Mono-app (comme ce repo) | Pas besoin de `--app`, détection automatique |
| Multi-app | `--app` requis, crée ticket dans le repo de l'app |

## Critères d'acceptation

- [ ] `/work S-XXX` démarre une session de travail
- [ ] Guard bloque si story pas `ready` avec message clair
- [ ] Crée la branche `feature/#XXX-slug` depuis main
- [ ] Met à jour la story en status `active`
- [ ] Crée/met à jour `.claude/session.json` avec :
  - `active_story`: S-XXX
  - `active_app`: nom de l'app (auto-détecté ou via --app)
  - `active_ticket`: repo#XX
  - `branch`: feature/#XXX-slug
  - `started_at`: timestamp
  - `status`: working
  - `current_sprint`: sprint-XX
- [ ] Crée ticket GitHub dans le repo approprié
- [ ] Met à jour la table Tickets dans la story
- [ ] Dev Agent lit les acceptance criteria et l'architecture
- [ ] Dev Agent propose un plan d'implémentation avant de coder
- [ ] Option `--app` pour projets multi-app

## Hors scope

- Gestion des conflits si déjà en `/work` sur autre story (future story)
- `/work abort` pour annuler (future story)

## Questions résolues

- Q: Format de branche ?
  R: `feature/#XXX-slug` (où XXX = numéro du ticket créé)

- Q: Mono-app, comment détecter ?
  R: Si une seule app dans `apps/`, pas besoin de `--app`

- Q: Story pas ready ?
  R: Guard qui bloque avec message "utilise `/story` d'abord"

## Notes techniques

Fichiers à créer/modifier :
- `apps/flowc/commands/work.md` - Définition de la commande
- `apps/flowc/skills/dev-agent.md` - Skill du Dev Agent pour analyse et plan d'implémentation

Dépendances :
- `gh issue create` pour créer les tickets
- Lecture de `.claude/flowc.json` pour config apps (si existe)

### Dev Agent

Le Dev Agent est déclenché automatiquement après le setup technique. Il doit :

1. **Lire le contexte** :
   - Story complète (acceptance criteria, description, hors scope)
   - Architecture de l'app (`engineering/apps/[name].md` si existe)
   - Contraintes techniques (`engineering/` si existe)

2. **Analyser** :
   - Identifier les fichiers à créer/modifier
   - Repérer les dépendances entre tâches
   - Détecter les risques potentiels

3. **Proposer un plan** :
   - Liste ordonnée des étapes d'implémentation
   - Pour chaque étape : fichiers concernés, ce qui sera fait
   - Demander validation avant de commencer
