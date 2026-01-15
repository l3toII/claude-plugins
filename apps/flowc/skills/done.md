---
name: done
description: Orchestrates /done command. Analyzes dirty files, runs review-agent, creates PR, updates session.
---

# Done Skill

Orchestre la commande `/done`. Analyse les fichiers non commités, lance review-agent, crée la PR, met à jour la session.

## Déclenchement

Invoqué par `/done` après que l'utilisateur a testé manuellement.

## Flow obligatoire

```
/done
    │
    ├── 1. Vérifier session active
    │   └── Guard si pas de session working
    │
    ├── 2. Analyse dirty files
    │   ├── Détecter fichiers non commités
    │   ├── Analyser chaque fichier
    │   └── Demander action à l'utilisateur
    │
    ├── 3. En parallèle
    │   ├── review-agent (OBLIGATOIRE)
    │   └── quality gates (si app code)
    │
    ├── 4. Évaluer résultats
    │   ├── Si issues critiques → bloquer
    │   └── Si OK → continuer
    │
    ├── 5. Créer PR
    │   ├── Commit + push
    │   ├── gh pr create
    │   └── Afficher lien
    │
    └── 6. Mise à jour session
        └── status: review + pr_url
```

## Phase 1 : Vérifier session

Lire `.claude/session.json` :

```json
{
  "active_story": "S-004",
  "status": "working"
}
```

**Guard** : Si pas de session ou `status != working` → bloquer avec message "Lance /work d'abord".

## Phase 2 : Analyse dirty files

### Détecter

```bash
git status --porcelain
```

### Analyser

Pour chaque fichier non commité, déterminer :
- Type de changement (modifié, nouveau, supprimé)
- Raison probable (debug, config, oubli, intentionnel)
- Action suggérée (commit, ignore, review)

### Demander

```
⚠️ Fichiers non commités détectés :

- src/utils/helper.ts (modifié)
  → Semble être du debug oublié (console.log ajoutés)

- .env.local (nouveau)
  → Fichier d'environnement, ne devrait pas être commité

Que faire ?
1. Commit helper.ts, ignore .env.local
2. Ignorer tout
3. Annuler /done
```

**ATTENDRE** la réponse de l'utilisateur avant de continuer.

### Actions selon le choix

| Choix | Action |
|-------|--------|
| Commit fichier X | `git add X && git commit -m "..."` |
| Ignore fichier X | `git checkout -- X` (revert) ou laisser (non inclus) |
| Ignorer tout | Continuer sans ces fichiers (ils restent dirty) |
| Annuler | Exit `/done`, user corrige manuellement |

**Comportement "Ignorer tout"** :
- Les fichiers dirty ne sont PAS inclus dans le commit
- Ils restent dans le working tree (non commités)
- La PR est créée sans ces fichiers
- Warning affiché : "⚠️ X fichiers ignorés, restent non commités"

**Comportement "Ignore fichier X"** :
- Si modifié : `git checkout -- X` pour revenir à HEAD
- Si nouveau : laissé tel quel (untracked)
- Si supprimé : `git checkout -- X` pour restaurer

## Phase 3 : Review & Quality Gates

### En parallèle

Lancer simultanément :

1. **review-agent** (OBLIGATOIRE)
   ```
   Lance review-agent avec:
     Review: [fichiers modifiés depuis main]
     Contexte: [story S-XXX, implémentation de...]
   ```

2. **quality gates** (si app code, pas plugin)
   ```bash
   npm test
   npm run lint
   npm run build
   ```

### Pour plugins

Pas de quality gates automatiques :
- Pas de tests unitaires (markdown)
- Pas de lint (sauf shellcheck sur .sh)
- Juste review-agent

## Phase 4 : Évaluer résultats

### Si issues critiques

```
## Review Results
- Issues critiques: 2
- Issues importantes: 1
- Issues mineures: 3

### Issues critiques (à corriger)

1. **Erreur silencieuse** - `commands/done.md:L42`
   → Le catch ne log pas l'erreur

2. **Injection possible** - `skills/done.md:L89`
   → Input non sanitizé

✗ Création PR bloquée
→ Corriger les issues critiques et relancer /done
```

**BLOQUER** : Ne pas créer la PR.

### Si OK

```
## Review Results
- Issues critiques: 0
- Issues importantes: 1 (naming convention)
- Issues mineures: 2

✓ Aucune issue bloquante
→ Création PR...
```

**CONTINUER** vers la création de PR.

## Phase 5 : Créer PR

### Commit + Push

```bash
git add .
git commit -m "feat(S-XXX): [description]"
git push -u origin [branch]
```

### Créer PR

Utiliser le template `templates/pr.md` :

```bash
gh pr create \
  --title "feat(S-XXX): [story title]" \
  --body "[template rempli]"
```

### Remplir le template

| Variable | Source | Description |
|----------|--------|-------------|
| `{{story_id}}` | session.json → active_story | ID de la story (S-XXX) |
| `{{story_title}}` | Story file → title | Titre de la story |
| `{{story_file}}` | Story file → filename | Nom du fichier (S-XXX-slug.md) |
| `{{story_context}}` | Story file → Contexte section | Description du contexte |
| `{{orchestrator_url}}` | Config ou détection | URL du repo orchestrator |
| `{{app_ticket_number}}` | session.json → active_ticket | Numéro du ticket app (#XX) |
| `{{app_name}}` | session.json → active_app | Nom de l'app (api, web...) |
| `{{commits_summary}}` | `git log --oneline main..HEAD` | Liste des commits |
| `{{files_changed_list}}` | `git diff --name-only main` | Liste des fichiers modifiés |
| `{{files_count}}` | `git diff --name-only main \| wc -l` | Nombre de fichiers |
| `{{acceptance_criteria_as_checklist}}` | Story file → Critères | Critères en checklist |
| `{{review_agent_verdict}}` | review-agent → Verdict | "Prêt" ou "Bloquant" |
| `{{review_agent_warnings}}` | review-agent → Issues importantes | Liste des warnings |
| `{{warnings_count}}` | review-agent → count | Nombre de warnings |
| `{{review_warnings}}` | Boolean | true si warnings > 0 |
| `{{has_screenshots}}` | Boolean | true si fichiers UI modifiés |
| `{{screenshots}}` | User input | Screenshots fournis par user |
| `{{has_breaking_changes}}` | Boolean | true si breaking changes |
| `{{breaking_changes}}` | Story file ou détection | Description des breaking changes |

### Variables conditionnelles

Les variables `{{#if X}}` affichent leur section seulement si la condition est vraie :

```handlebars
{{#if review_warnings}}
  → Affiche si warnings > 0
{{/if}}

{{#if has_screenshots}}
  → Affiche si fichiers UI modifiés (*.tsx, *.vue, *.css...)
{{/if}}

{{#if has_breaking_changes}}
  → Affiche si breaking_changes non vide dans story
  → Ou si détecté : suppression/renommage d'API publique
{{/if}}
```

### Afficher

```
✓ PR créée: https://github.com/org/api/pull/16
```

## Phase 6 : Mise à jour session

### Mettre à jour session.json

```json
{
  "active_story": "S-004",
  "active_app": "api",
  "branch": "feature/#15-done-command",
  "started_at": "2025-01-15T10:00:00Z",
  "status": "review",
  "pr_url": "https://github.com/org/api/pull/16",
  "pr_created_at": "2025-01-15T14:30:00Z"
}
```

### Ne PAS mettre à jour la story

La story reste `active` jusqu'au `/sync` qui détectera le merge.

## Output attendu

```
User: /done

Claude:
  ## Analyse
  ✓ Session active (S-004)
  ✓ Working tree propre

  ## Review & Quality (en parallèle)
  → review-agent...
  → quality gates... (skipped - plugin)

  ## Review Results
  - Issues critiques: 0
  - Issues importantes: 1
  - Issues mineures: 2

  ✓ Aucune issue bloquante

  ## Création PR
  → Committing changes...
  → Pushing to origin/feature/#004-done-command
  → Creating PR...

  ✓ PR créée: https://github.com/org/api/pull/16

  ## Session
  ✓ Status: working → review
  ✓ PR tracked in session.json

  Prochaine étape: review par l'équipe, puis /sync après merge
```

## Option --force

Si `--force` est passé :
- Skip review-agent
- Crée la PR directement
- **Non recommandé** sauf urgence

```
User: /done --force

Claude:
  ⚠️ Mode force activé - review-agent skippé

  ## Création PR
  → Pushing...
  → Creating PR...

  ✓ PR créée: https://github.com/org/api/pull/16

  ⚠️ Attention: PR créée sans review automatique
```

## Gestion des erreurs

| Erreur | Action |
|--------|--------|
| Pas de session | "Lance /work d'abord" |
| Session pas working | "Session en status [X], attendu: working" |
| Issues critiques | Afficher, bloquer, suggérer fixes |
| Push failed | Afficher erreur git, suggérer résolution |
| PR creation failed | Afficher erreur gh, vérifier permissions |
