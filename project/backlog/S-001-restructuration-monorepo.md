---
id: S-001
title: Restructuration monorepo
type: tech
status: done
sprint: sprint-00
created: 2025-01-15
---

# S-001: Restructuration monorepo

## Description

Transformer le repo claude-flow en structure monorepo compatible flowc pour permettre le dogfooding.

## Critères d'Acceptation

- [x] Structure `apps/flowc/` avec git indépendant
- [x] Structure `project/backlog/` et `project/sprints/`
- [x] Structure `engineering/apps/`
- [x] Structure `docs/` avec GUIDE.md
- [x] Configuration `.claude/flowc.json`
- [x] Documentation adaptée pour apps type plugin (test.md)
- [x] Repo GitHub renommé en `claude-plugins`

## Notes Techniques

Type d'app: `claude-plugin`
- Pas de tests unitaires → test.md
- Pas de staging → main = prod
- Versioning via tags git
