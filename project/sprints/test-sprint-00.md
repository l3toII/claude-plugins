---
sprint: sprint-00
type: test
status: pending
---

# Tests Sprint 00

Tests d'acceptation pour valider les stories du sprint 00.

## S-002: /story avec clarification interactive

| # | Test | Commande | Résultat attendu | Status |
|---|------|----------|------------------|--------|
| 1 | Création simple | `/story "Ajouter bouton logout"` | Flow interactif, confirmation, fichier créé | [ ] |
| 2 | Détection multi-stories | `/story "Login Google et reset password"` | Claude identifie 2 stories distinctes | [ ] |
| 3 | Clarification | `/story "Améliorer l'onboarding"` | Claude pose des questions | [ ] |
| 4 | Confirmation avant création | (suite de 1) | Claude demande confirmation | [ ] |
| 5 | Fichier créé | (suite de 1) | `project/backlog/S-XXX-slug.md` existe | [ ] |
| 6 | Template narratif | (suite de 5) | Sections: Contexte, Objectif, Description, Critères, Hors scope | [ ] |
| 7 | ID auto-incrémenté | Créer 2 stories | IDs séquentiels (S-005, S-006...) | [ ] |
| 8 | Force type | `/story tech "Refactorer auth"` | Type = tech dans le fichier | [ ] |
| 9 | Question GitHub | (après confirmation) | "Créer l'issue GitHub ?" | [ ] |
| 10 | Création issue | Répondre "oui" | Issue créée, lien dans frontmatter | [ ] |
| 11 | Option --draft | `/story --draft "Feature X"` | Pas de question GitHub, status = draft | [ ] |
| 12 | Option --ready | `/story --ready "Feature Y"` | Issue créée sans question, status = ready | [ ] |

## S-003: /work basique

| # | Test | Commande | Résultat attendu | Status |
|---|------|----------|------------------|--------|
| 1 | Story not ready bloquée | `/work S-XXX` (draft) | Guard bloque avec message "utilise /story d'abord" | [ ] |
| 2 | Story not in sprint bloquée | `/work S-XXX` (ready, sprint: null) | Guard bloque avec message "utilise /sprint plan d'abord" | [ ] |
| 3 | Story ready + in sprint acceptée | `/work S-XXX` (ready + sprint-00) | Setup démarre | [ ] |
| 4 | Session créée | (suite de 3) | `.claude/session.json` créé avec active_story, branch, etc. | [ ] |
| 5 | Status updated | (suite de 3) | Story passe de `ready` à `active` | [ ] |
| 6 | Branche créée | (suite de 3) | `git branch` montre `feature/#XXX-slug` | [ ] |
| 7 | explore-agent lancé | (suite de 3) | Agent explore le codebase, retourne fichiers/patterns | [ ] |
| 8 | explore-agent format | (suite de 7) | Output avec sections: Fichiers clés, Patterns, Conventions, Architecture | [ ] |
| 9 | architect-agent lancé | (suite de 8) | Agent reçoit contexte explore-agent, propose 2-3 options | [ ] |
| 10 | User choisit architecture | (suite de 9) | Claude attend le choix avant d'implémenter | [ ] |
| 11 | TDD respecté | (après choix) | Claude écrit test d'abord (RED), puis code (GREEN) | [ ] |
| 12 | Fin implémentation | (après TDD) | Message "Testez manuellement, puis /done" | [ ] |
| 13 | Option --app | `/work S-XXX --app api` | Ticket créé dans repo api (multi-app) | [ ] |
| 14 | Plugin mode détecté | `/work S-XXX` (ce repo) | Détection: aucun .git dans apps/, mode plugin | [ ] |
| 15 | Mono-app détecté | `/work S-XXX` (un .git dans apps/) | Détection auto, pas besoin de --app | [ ] |
| 16 | Multi-app sans --app | `/work S-XXX` (plusieurs .git) | Erreur: --app requis | [ ] |

## S-004: /done basique

| # | Test | Commande | Résultat attendu | Status |
|---|------|----------|------------------|--------|
| 1 | Pas de session | `/done` (sans /work) | Guard bloque avec "Lance /work d'abord" | [ ] |
| 2 | Dirty files détectés | `/done` (fichiers non commités) | Analyse + demande user (commit/ignore/abort) | [ ] |
| 3 | Dirty: commit sélectif | Choix "commit X, ignore Y" | X commité, Y ignoré | [ ] |
| 4 | Dirty: ignorer tout | Choix "ignorer tout" | PR sans ces fichiers, warning affiché | [ ] |
| 5 | Dirty: annuler | Choix "annuler" | Exit /done, user corrige manuellement | [ ] |
| 6 | Working tree propre | `/done` (tout commité) | Passe directement à review | [ ] |
| 7 | review-agent lancé | (suite de 6) | Agent review les fichiers modifiés | [ ] |
| 8 | Quality gates (app) | `/done` (dans app code) | Tests + lint + coverage en parallèle de review | [ ] |
| 9 | Quality gates skip (plugin) | `/done` (dans plugin) | Pas de quality gates, juste review-agent | [ ] |
| 10 | Issues critiques bloquent | (review avec issues critiques) | PR non créée, suggestions de fix affichées | [ ] |
| 11 | PR créée | (review OK) | `gh pr create` avec template rempli | [ ] |
| 12 | Template PR - Story link | (suite de 11) | Lien vers story orchestrator dans Summary | [ ] |
| 13 | Template PR - Ticket | (suite de 11) | `Closes #XX` pour ticket app | [ ] |
| 14 | Template PR - Review | (suite de 11) | Verdict review-agent inclus | [ ] |
| 15 | Template PR - Conditionnels | (suite de 11) | Screenshots/Breaking changes si applicable | [ ] |
| 16 | Session updated | (suite de 11) | `status: review`, `pr_url`, `pr_created_at` | [ ] |
| 17 | Lien PR affiché | (suite de 11) | URL de la PR affichée à la fin | [ ] |
| 18 | Message next step | (suite de 17) | "review par l'équipe, puis /sync après merge" | [ ] |
| 19 | Option --force | `/done --force` | Skip review-agent, warning affiché | [ ] |

## Résumé

| Story | Tests | Passés | Échoués |
|-------|-------|--------|---------|
| S-002 | 12 | 0 | 0 |
| S-003 | 16 | 0 | 0 |
| S-004 | 19 | 0 | 0 |
| **Total** | **47** | **0** | **0** |

## Notes

- Exécuter les tests après merge de chaque feature
- Cocher [x] quand le test passe
- Documenter les bugs trouvés dans la section Notes

### Bugs trouvés

(aucun pour l'instant)
