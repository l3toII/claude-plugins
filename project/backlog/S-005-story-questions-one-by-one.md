---
id: S-005
title: Questions de clarification une par une dans /story
type: ux
status: draft
sprint: sprint-00
github: null
created: 2025-01-15
---

# S-005: Questions de clarification une par une dans /story

## Contexte

Actuellement, quand `/story` détecte une demande complexe, Claude pose toutes les questions de clarification en bloc. Cela crée une interaction moins naturelle et peut submerger l'utilisateur.

## Objectif

En tant qu'utilisateur,
je veux que Claude pose ses questions une par une
afin d'avoir une conversation naturelle et raffiner ma demande au fur et à mesure.

## Description

Modifier le comportement du skill `story` pour :
- Poser une seule question à la fois
- Attendre la réponse avant de poser la suivante
- Adapter les questions suivantes selon les réponses précédentes

## Critères d'acceptation

- [ ] Les questions de clarification sont posées une par une
- [ ] Claude attend la réponse avant de poser la question suivante
- [ ] Le flow reste fluide et conversationnel

## Hors scope

- Optimisation du nombre de questions (pour une future story)
- Skip automatique de questions si réponse implicite (pour une future story)

## Notes

Story d'amélioration UX à raffiner en fin de sprint.
