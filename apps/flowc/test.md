# flowc - Test Scenarios

Ce fichier documente les scénarios de test manuels pour valider le plugin flowc.

## Comment utiliser ce fichier

1. **Avant chaque PR** : Exécuter les scénarios impactés par les changements
2. **Après merge** : Validation rapide sur main
3. **Nouvelle feature** : Ajouter les scénarios correspondants

## Légende

- ⬜ Non testé
- ✅ Passé
- ❌ Échoué
- 🚧 En cours d'implémentation

---

## 1. Initialisation

### 1.1 /init - Nouveau projet

**Status**: 🚧

**Preconditions**:
- Dossier vide ou nouveau repo

**Steps**:
1. Exécuter `/init`
2. Répondre aux questions (nom projet, type, apps)

**Expected**:
- Structure créée (`apps/`, `project/`, `engineering/`, `docs/`)
- `.claude/flowc.json` généré
- `engineering/architecture.md` créé
- Sprint 0 créé avec stories initiales

---

### 1.2 /onboard - Projet existant

**Status**: 🚧

**Preconditions**:
- Repo git existant avec historique

**Steps**:
1. Exécuter `/onboard`
2. Laisser l'analyse se faire

**Expected**:
- Détection automatique de la structure
- Génération des documents manquants
- Stories de dette technique créées

---

## 2. Stories & Backlog

### 2.1 /story - Création feature

**Status**: 🚧

**Steps**:
1. `/story "User login with OAuth"`
2. Vérifier le fichier créé

**Expected**:
- Fichier `project/backlog/S-XXX.md` créé
- ID auto-incrémenté
- Issue GitHub créée et liée
- Status = `draft`

---

### 2.2 /story - Création bug

**Status**: 🚧

**Steps**:
1. `/story "Fix login redirect" --type bug`

**Expected**:
- Type = `bug` dans le frontmatter
- Prefix ticket = `BUG-XXX`

---

## 3. Sprints

### 3.1 /sprint new

**Status**: 🚧

**Steps**:
1. `/sprint new "MVP Authentication"`
2. Vérifier création

**Expected**:
- Fichier `project/sprints/sprint-XX.md`
- Objectif documenté
- Status = `draft`

---

### 3.2 /sprint plan

**Status**: 🚧

**Preconditions**:
- Sprint existant en `draft`
- Stories en `draft` dans le backlog

**Steps**:
1. `/sprint plan`
2. Sélectionner stories à inclure

**Expected**:
- Stories passent en `ready`
- Stories liées au sprint
- Sprint reste en `draft`

---

### 3.3 /sprint start

**Status**: 🚧

**Steps**:
1. `/sprint start`

**Expected**:
- Sprint passe en `active`
- Un seul sprint actif à la fois

---

## 4. Workflow Développement

### 4.1 /work - Démarrer travail

**Status**: 🚧

**Preconditions**:
- Story en `ready` dans sprint actif

**Steps**:
1. `/work S-001`

**Expected**:
- Branche créée (`feature/#001-slug`)
- Story passe en `active`
- Session démarrée (`.claude/session.json`)

---

### 4.2 /done - Terminer travail

**Status**: 🚧

**Preconditions**:
- Travail en cours (`/work` actif)
- Modifications commitées

**Steps**:
1. `/done`

**Expected**:
- Quality gates vérifiés (test.md à jour)
- PR créée
- Story passe en `review`

---

### 4.3 /commit - Commit conventionnel

**Status**: 🚧

**Steps**:
1. Modifier un fichier
2. `/commit "Add new command"`

**Expected**:
- Format: `type(scope): message (#ticket)`
- Ticket auto-détecté depuis branche

---

## 5. Guards & Hooks

### 5.1 Guard - Story required

**Status**: 🚧

**Steps**:
1. Sans `/work` actif, tenter de modifier du code
2. Observer le warning

**Expected**:
- Warning affiché (pas de blocage)
- Suggestion d'utiliser `/story` puis `/work`

---

### 5.2 Guard - Secrets detection

**Status**: 🚧

**Steps**:
1. Ajouter une ligne avec `API_KEY=xxx123`
2. Tenter un commit

**Expected**:
- Warning sur potentiel secret
- Suggestion de vérifier

---

## 6. Release

### 6.1 /release - Création release

**Status**: 🚧

**Preconditions**:
- Commits sur main depuis dernière release

**Steps**:
1. `/release minor`

**Expected**:
- Tag créé (`v0.X.0`)
- CHANGELOG.md mis à jour
- GitHub Release créée

---

## 7. Commandes Info

### 7.1 /status

**Status**: 🚧

**Steps**:
1. `/status`

**Expected**:
- Affiche sprint actif
- Affiche travail en cours
- Affiche stories du sprint

---

### 7.2 /bye - Fin de session

**Status**: 🚧

**Steps**:
1. `/bye`

**Expected**:
- Session sauvegardée
- Résumé du travail effectué
- Suggestions pour prochaine session

---

## Notes de Test

### Environnement de test

Pour tester flowc, créer un repo de test séparé :

```bash
mkdir /tmp/flowc-test
cd /tmp/flowc-test
git init
# Installer le plugin
/plugin install /path/to/claude-plugins/apps/flowc
```

### Reset entre tests

```bash
rm -rf project/ engineering/ .claude/
git checkout -- .
```
