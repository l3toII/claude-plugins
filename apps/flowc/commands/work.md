---
description: Start working on a story. Explores codebase, proposes architecture, then Claude implements with TDD.
argument-hint: 'S-XXX | S-XXX --app api'
skills: work
---

# /work - Démarrer le Travail sur une Story

Configure la session, explore le codebase, propose l'architecture, puis Claude implémente en TDD.

## Usage

```bash
/work S-003                  # Démarrer sur story (mono-app)
/work S-042 --app api        # Démarrer sur app spécifique (multi-app)
```

## Prérequis

- Story doit être en status `ready` ET assignée à un sprint
  - Si pas ready → "utilise `/story` d'abord"
  - Si pas dans un sprint → "utilise `/sprint plan` d'abord"
- Pour multi-app : `--app` requis si plusieurs apps détectées

## Flow

```
/work S-XXX
    │
    ├── 1. [Guard] Vérifie story ready + in sprint
    │
    ├── 2. Setup technique
    │   ├── Créer .claude/session.json
    │   ├── Story status → active
    │   └── Créer branche feature/#XXX-slug
    │
    ├── 3. Exploration (explore-agent)
    │   ├── Analyse le codebase existant
    │   ├── Trouve patterns et conventions
    │   └── Retourne fichiers clés à lire
    │
    ├── 4. Architecture (architect-agent)
    │   ├── Propose 2-3 options avec trade-offs
    │   ├── User choisit l'approche
    │   └── Valide avant implémentation
    │
    └── 5. Implémentation (Claude)
        ├── TDD: RED → GREEN → REFACTOR
        ├── Respecte l'architecture choisie
        └── User teste manuellement, puis /done
```

## Agents

| Agent | Phase | Rôle |
|-------|-------|------|
| `explore-agent` | 3 | Explore codebase, trouve patterns |
| `architect-agent` | 4 | Propose options d'architecture |

**Claude implémente** (phase 5). Les agents l'assistent.
**review-agent** est appelé par `/done`, après les tests manuels de l'utilisateur.

## Session.json

Créé/mis à jour dans `.claude/session.json` :

```json
{
  "active_story": "S-003",
  "active_app": "flowc",
  "branch": "feature/#003-slug",
  "started_at": "2025-01-15T10:00:00Z",
  "status": "working",
  "current_sprint": "sprint-00"
}
```

## Mono-app vs Multi-app

| Contexte | Détection | Comportement |
|----------|-----------|--------------|
| Mono-app | Une seule app dans `apps/` | Pas besoin de `--app` |
| Plugin Claude | Pas de `apps/` ou type plugin | Pas de ticket, branche depuis ID story |
| Multi-app | Plusieurs apps | `--app` requis, ticket créé dans repo app |

## Exemple

```
User: /work S-042

Claude:
  ✓ Story S-042 chargée (ready → active)
  ✓ Session configurée
  ✓ Branche feature/#042-notifications créée

  ## Phase 3: Exploration
  → Lance explore-agent

  [explore-agent retourne:]
  - Fichiers clés: src/services/, src/events/
  - Patterns: Event-driven, Repository
  - Conventions: camelCase, index.ts exports

  ## Phase 4: Architecture
  → Lance architect-agent

  [architect-agent propose:]
  Option A: Redis pub/sub (Recommandé)
  Option B: In-memory + sync
  Option C: HTTP polling

  Quelle approche ? → User choisit A

  ## Phase 5: Implémentation TDD

  RED: test NotificationService.create()
  → Test échoue ✗

  GREEN: implémentation minimale
  → Test passe ✓

  [... continue TDD ...]

  ✓ Implémentation terminée
  → Testez manuellement, puis /done pour créer la PR
```

## Options

| Option | Description |
|--------|-------------|
| `--app <name>` | Spécifier l'app cible (requis si multi-app) |

## Erreurs

| Erreur | Cause | Solution |
|--------|-------|----------|
| Story non trouvée | ID invalide | Vérifier l'ID avec `ls project/backlog/` |
| Story pas ready | Status draft | Utiliser `/story S-XXX` pour passer en ready |
| Story pas dans sprint | Sprint null | Utiliser `/sprint plan` pour ajouter au sprint |
| App requise | Multi-app sans --app | Ajouter `--app <name>` |

## Règles

1. **Story ready + in sprint** : Guard bloque si pas ready ou pas dans un sprint
2. **Exploration d'abord** : Toujours comprendre avant de coder
3. **Architecture validée** : User choisit l'approche
4. **TDD obligatoire** : Sauf plugins markdown
5. **Test manuel** : User teste avant /done

## Fichiers

| Fichier | Rôle |
|---------|------|
| `commands/work.md` | Cette définition de commande |
| `skills/work.md` | Orchestration du flow |
| `agents/explore-agent.md` | Exploration codebase |
| `agents/architect-agent.md` | Options d'architecture |
| `agents/review-agent.md` | Review qualité |
| `hooks/guard-story-ready.sh` | Guard vérifie story ready |
| `.claude/settings.json` | Configuration du hook |
