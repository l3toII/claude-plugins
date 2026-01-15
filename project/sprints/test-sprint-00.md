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
| 1 | TBD | | | [ ] |

## S-004: /done basique

| # | Test | Commande | Résultat attendu | Status |
|---|------|----------|------------------|--------|
| 1 | TBD | | | [ ] |

## Résumé

| Story | Tests | Passés | Échoués |
|-------|-------|--------|---------|
| S-002 | 12 | 0 | 0 |
| S-003 | - | - | - |
| S-004 | - | - | - |

## Notes

- Exécuter les tests après merge de chaque feature
- Cocher [x] quand le test passe
- Documenter les bugs trouvés dans la section Notes
