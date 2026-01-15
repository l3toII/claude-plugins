# flowc - Guide Complet

Plugin de workflow de développement pour Claude Code.
**Objectif** : Tracer chaque ligne de code à une story, éliminer le "vibe coding".

---

## Table des Matières

1. [Philosophie](#1-philosophie)
2. [Structure du Projet](#2-structure-du-projet)
3. [Initialisation (/init)](#3-initialisation-init)
4. [Onboarding (/onboard)](#4-onboarding-onboard)
5. [Stories et Backlog](#5-stories-et-backlog)
6. [Sprints](#6-sprints)
7. [Workflow de Développement](#7-workflow-de-développement)
8. [Agents](#8-agents)
9. [Règles de Code](#9-règles-de-code)
10. [Git, Commits et PRs](#10-git-commits-et-prs)
11. [Environnements](#11-environnements)
12. [Release](#12-release)
13. [Guards et Hooks](#13-guards-et-hooks)
14. [Documentation](#14-documentation)
15. [Intégration GitHub](#15-intégration-github)
16. [Configuration](#16-configuration)
17. [Cas Spéciaux](#17-cas-spéciaux)
18. [Commandes Référence](#18-commandes-référence)

---

## 1. Philosophie

### Le Problème

Le "vibe coding" c'est :
- Coder sans ticket, sans direction claire
- Branches `test`, `my-feature`, `wip` qui s'accumulent
- Code non documenté, non testé, non tracé
- Impossible de savoir pourquoi une feature existe

### La Solution : Story-First Development

```
Chaque ligne de code trace à une Story.
Chaque Story a un objectif mesurable.
Chaque Sprint a un but atteignable.
```

### Principes Fondamentaux

| Principe | Description |
|----------|-------------|
| **Story-First** | Pas de code sans story, pas de commit sans ticket |
| **TDD** | Tests écrits avant le code |
| **Clean Code** | Principes explicites, appliqués, vérifiés |
| **Clean Architecture** | Pattern documenté par app |
| **Documentation Vivante** | Docs synchronisées avec le code |
| **Itération** | Dev → Review → Fix → Review jusqu'à qualité |

---

## 2. Structure du Projet

### Arborescence Complète

```
project/
│
├── apps/                           # Tout le code applicatif
│   ├── api/                        # App backend (avec .git propre)
│   │   ├── .git/                   # Repository indépendant
│   │   ├── src/
│   │   ├── tests/
│   │   ├── package.json
│   │   └── README.md
│   │
│   ├── web/                        # App frontend (avec .git propre)
│   │   ├── .git/
│   │   └── ...
│   │
│   └── devops/                     # PAS de .git (repo principal)
│       ├── docker/
│       │   ├── docker-compose.yml
│       │   └── docker-compose.dev.yml
│       ├── env/
│       │   ├── .env.example
│       │   └── .env.dev
│       └── scripts/
│           ├── setup.sh
│           └── deploy.sh
│
├── project/                        # Gestion de projet
│   ├── backlog/                    # Stories
│   │   └── S-XXX-slug.md
│   └── sprints/
│       └── sprint-XX.md
│
├── engineering/                    # Documentation technique
│   ├── architecture.md             # Architecture globale
│   ├── stack.md                    # Choix techniques
│   ├── dependencies.md             # Graphe dépendances entre apps
│   ├── decisions/                  # ADRs
│   │   └── ADR-XXX-titre.md
│   └── apps/                       # Doc par app
│       ├── api.md
│       └── web.md
│
├── docs/                           # Documentation publique
│   ├── api/                        # Doc API générée
│   └── guides/                     # Guides utilisateur
│
├── .claude/
│   ├── session.json                # Session active
│   ├── apps.json                   # Configuration apps
│   └── repos.json                  # Conventions git détectées
│
├── .git/                           # Repository principal
├── CLAUDE.md
├── README.md
├── Makefile
└── package.json                    # Workspace only (PAS de deps)
```

### Règle d'Or : Apps Autonomes

Chaque app dans `apps/` (sauf devops) :
- A son propre `.git` → repository indépendant
- A son propre `package.json` → dépendances autonomes
- A sa propre config (tsconfig, eslint) → pas d'extends externe
- Peut être clonée et exécutée seule

### Versioning

- **Chaque app a sa version** : `api` v1.2.0, `web` v2.0.1
- **Versions indépendantes** : une app peut avancer sans les autres
- **Releases coordonnées** : via le repo principal quand nécessaire

---

## 3. Initialisation (/init)

### Quand l'utiliser

Projet **nouveau**, dossier vide ou presque.

### Flow Adaptatif

`/init` détecte le contexte et s'adapte :

```
/init
  │
  ├─▶ Dossier vide ?
  │     → Flow complet : Vision, Personas, UX, Stack, Apps
  │
  ├─▶ Docs existants ?
  │     → Les lit, pose questions complémentaires
  │
  └─▶ Code existant ?
        → Suggère /onboard à la place
```

### Phases

#### Phase 1 : Discovery
Questions sur le projet :
- Nom, description, objectif
- Type (SaaS, API, CLI, Library, Mobile...)
- Public cible
- Contraintes connues

#### Phase 2 : Personas & UX
- Qui sont les utilisateurs ?
- Quels sont leurs besoins principaux ?
- Direction UX (minimaliste, riche, technique...)

#### Phase 3 : Architecture
- Quelles apps ? (api, web, mobile, worker...)
- Pattern architectural par app :
  - Backend : Layered, Hexagonal, Clean Architecture, CQRS...
  - Frontend : Components, Feature-based, Atomic Design...
- Dépendances entre apps

#### Phase 4 : Stack
Pour chaque app :
- Langage / Framework
- Base de données (si applicable)
- Outils de build/test

#### Phase 5 : Génération
Crée :
- Structure de dossiers complète
- Documents : vision.md, personas.md, ux.md, architecture.md, stack.md
- `engineering/apps/[name].md` pour chaque app
- `.claude/` configuration
- Sprint 0 (setup technique)

### Sprint 0

Sprint initial automatique contenant :
- Story "Setup projet" avec tickets par app
- Configuration CI/CD basique
- Documentation initiale
- Environnement de dev local

---

## 4. Onboarding (/onboard)

### Quand l'utiliser

Projet **existant** avec du code, à migrer vers flowc.

### Objectif

**Reverse engineering** : comprendre l'existant et générer la documentation manquante.

### Phases

#### Phase 1 : Analyse
Scan automatique :
- Structure des dossiers
- Détection des apps (package.json, go.mod, etc.)
- Analyse des dépendances
- Historique git : patterns de commits, branches

#### Phase 2 : Détection Architecture
Pour chaque app détectée :
- Pattern architectural utilisé (ou absence de pattern)
- Structure des layers/modules
- Conventions de nommage
- Style de code

#### Phase 3 : Reverse Engineering Stories
Depuis l'historique git :
- Détecte les features implémentées
- Groupe les commits par fonctionnalité
- Génère des Stories "rétrospectives" (statut: Done)
- État actuel du versioning par app

#### Phase 4 : Questionnaire
Questions pour compléter :
- Valider les détections
- Informations manquantes (vision, personas si pas de doc)
- Confirmer les patterns architecturaux
- Définir les règles de qualité cibles

#### Phase 5 : Génération
Crée les documents manquants :
- `engineering/architecture.md` - vue globale
- `engineering/apps/[name].md` - par app détectée
- `engineering/dependencies.md` - graphe des dépendances
- `project/backlog/` - stories rétrospectives
- `.claude/` - configuration

#### Phase 6 : Rapport
Résumé :
- Ce qui a été détecté
- Ce qui a été généré
- Actions manuelles recommandées
- État de santé du projet (dette technique estimée)

---

## 5. Stories et Backlog

### Philosophie

Une story doit être **compréhensible par tous** : développeurs, product owners, designers. Elle raconte une histoire, pas juste une liste technique.

### Créer des Stories avec /story

La commande `/story` est **interactive et intelligente** :

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

**Comportement** :
- Accepte une description en langage naturel
- Identifie si plusieurs stories sont nécessaires
- Pose des questions de clarification
- Demande confirmation avant création
- Propose de créer les issues GitHub (draft → ready)

**Options** :
- `--draft` : Force draft, pas de question GitHub
- `--ready` : Force ready, crée les issues sans question

### Format Story

Fichier : `project/backlog/S-XXX-slug.md`

```yaml
---
id: S-042
title: OAuth Login avec Google
type: feature                    # feature | tech | bug | ux
status: draft                    # draft | ready | active | review | done
sprint: null                     # sprint-XX ou null
created: 2025-01-15
---

# S-042: OAuth Login avec Google

## Contexte

Le taux de conversion à l'inscription est de 45%. Les utilisateurs
abandonnent face au formulaire d'inscription classique. Google OAuth
permettrait de simplifier l'onboarding.

## Objectif

En tant qu'utilisateur,
je veux me connecter avec mon compte Google
afin de m'inscrire en un clic sans créer de mot de passe.

## Description

Ajouter l'authentification Google OAuth sur la page de login :
- Bouton "Continuer avec Google" visible
- Flow OAuth complet (redirect → Google → callback)
- Création automatique du compte si premier login
- Liaison avec compte existant si même email

## Critères d'acceptation

- [ ] Bouton "Continuer avec Google" sur la page login
- [ ] Flow OAuth complet (redirect, callback, token)
- [ ] Création de compte automatique si premier login
- [ ] Session persistante après login
- [ ] Gestion des erreurs OAuth (refus, timeout)

## Hors scope

- Login avec Apple (story séparée)
- Login avec Facebook (non prévu)
- Migration des comptes existants

## Tickets

<!-- Rempli automatiquement par /work -->
| App | Ticket | Status |
|-----|--------|--------|

## Questions résolues

- Q: OAuth pour login seulement ou aussi inscription ?
  R: Les deux, création de compte automatique au premier login.

## Notes

- Utiliser la lib `google-auth-library`
- Voir ADR-003 pour le choix OAuth vs SAML
```

### Types de Stories

| Type | Description | Exemple |
|------|-------------|---------|
| `feature` | Fonctionnalité utilisateur | Login OAuth |
| `tech` | Amélioration technique | Refactoring auth module |
| `bug` | Correction de bug | Fix session timeout |
| `ux` | Amélioration UX/UI | Redesign onboarding |

### Cycle de Vie

```
draft → ready → active → review → done
```

| Status | Fichier local | Issue GitHub | Sprint possible |
|--------|---------------|--------------|-----------------|
| `draft` | ✅ | ❌ | ❌ |
| `ready` | ✅ | ✅ | ✅ |
| `active` | ✅ | ✅ | ✅ |
| `review` | ✅ | ✅ | ✅ |
| `done` | ✅ | ✅ (fermée) | ✅ |

**Règle clé** : Une story doit être `ready` (avec issue GitHub) pour être ajoutée à un sprint. `/sprint plan` refuse les stories `draft`.

| Status | Signification |
|--------|---------------|
| `draft` | Brouillon local, pas encore d'issue GitHub |
| `ready` | Issue GitHub créée, prête à être planifiée |
| `active` | En cours de développement |
| `review` | Code terminé, en revue |
| `done` | Terminée, mergée |

---

## 6. Sprints

### Philosophie

Les sprints sont **objectif-driven** :
- Un sprint se termine quand **toutes ses stories sont Done**
- Pas de durée fixe imposée
- L'objectif est d'atteindre un état cohérent du produit

### Format Sprint

Fichier : `project/sprints/sprint-XX.md`

```yaml
---
id: sprint-03
title: Authentication Complete
status: active                   # draft | ready | active | review | done
goal: "Users can login via email or Google"
created: 2025-01-10
---

# Sprint 03: Authentication Complete

## Goal

À la fin de ce sprint, les utilisateurs peuvent :
- Créer un compte avec email/password
- Se connecter via Google OAuth
- Récupérer leur mot de passe oublié

## Stories

| Story | Title | Status |
|-------|-------|--------|
| [S-040](../backlog/S-040-email-signup.md) | Email Signup | done |
| [S-041](../backlog/S-041-password-reset.md) | Password Reset | done |
| [S-042](../backlog/S-042-oauth-login.md) | OAuth Login | active |

## Progress

- Total: 3 stories
- Done: 2
- Active: 1
- Blocked: 0

## Notes

- Dépendance externe : clé API Google (obtenue)
- Risk : rate limiting OAuth en dev
```

### Cycle de Vie Sprint

```
Draft → Ready → Active → Review → Done
```

| Status | Description |
|--------|-------------|
| `draft` | En cours de planification |
| `ready` | Stories sélectionnées, prêt à démarrer |
| `active` | En cours de développement |
| `review` | Toutes stories en review ou done, validation finale |
| `done` | Objectif atteint, sprint terminé |

### Gestion du Scope

**Ajout de story en cours de sprint** :
- Possible, mais génère un **warning scope creep**
- Doit être justifié (bug critique, dépendance découverte)
- Tracé dans les notes du sprint

**Stories non terminées à la clôture** :
- Choix manuel pour chaque story :
  - **Reporter** au sprint suivant
  - **Retourner** au backlog (re-prioriser)
  - **Abandonner** (si plus pertinent)

### Commandes Sprint

```bash
/sprint                  # Status du sprint actif
/sprint plan             # Planifier prochain sprint (sélection stories)
/sprint start            # Activer le sprint planifié
/sprint review           # Passer en review (vérification finale)
/sprint close            # Clôturer (gestion stories incomplètes)
```

---

## 7. Workflow de Développement

### Vue d'Ensemble

```
/story "titre" → /sprint plan → /work S-XXX → [TDD cycle] → /done
                                     ↓
                              ┌──────┴──────┐
                              │  Dev Agent  │
                              │    (TDD)    │
                              └──────┬──────┘
                                     ↓
                              ┌──────┴──────┐
                              │Review Agent │
                              │  (auto)     │
                              └──────┬──────┘
                                     ↓
                              Pass? ─┬─ No → Fix → Review
                                     │
                                    Yes
                                     ↓
                                 PR Created
```

### Créer une Story

```bash
/story "OAuth Login avec Google"
```

1. Crée `project/backlog/S-XXX-oauth-login.md`
2. Crée Issue GitHub dans repo principal
3. Statut initial : `draft`
4. L'utilisateur complète les acceptance criteria

### Planifier un Sprint

```bash
/sprint plan
```

1. Affiche les stories `draft` du backlog
2. Sélection interactive des stories à inclure
3. **Les stories sélectionnées passent automatiquement à `ready`**
4. Crée `project/sprints/sprint-XX.md`
5. Met à jour le champ `sprint` des stories sélectionnées

### Démarrer le Travail

```bash
/work S-042              # Story simple (1 app)
/work S-042 --app api    # Story multi-app, spécifier l'app
```

**Prérequis** : Story doit être dans un sprint (status `ready`)

1. Story passe à `active`
2. Crée le ticket GitHub dans le repo de l'app
3. Le numéro du ticket créé détermine le nom de branche
4. Crée la branche `feature/#XX-slug` (où XX = numéro du ticket)
5. Met à jour la story (ajoute le ticket dans la table Tickets)
6. Charge le contexte (acceptance criteria, architecture app)

### Développement (TDD)

L'agent de dev pratique le **TDD** :

```
1. RED    : Écrire un test qui échoue
2. GREEN  : Écrire le code minimal pour passer le test
3. REFACTOR : Améliorer le code sans casser les tests
4. REPEAT
```

L'agent :
- Respecte les règles de `engineering/apps/[name].md`
- N'est pas bloqué par les violations (warning seulement)
- Documente les choix techniques dans la story si nécessaire

### Terminer le Travail

```bash
/done
```

1. **Quality Gates** : lint, tests, coverage (ou test.md pour plugins)
2. **Review Agent** automatique :
   - Vérifie Clean Code
   - Vérifie Architecture
   - Vérifie sync docs
3. **Si review fail** : suggestions de fix, itération
4. **Si review pass** :
   - Coche les critères d'acceptation ✅
   - Passe la story en `done`
   - Clear la session (`session.json` → idle)
   - Crée commit avec tous ces changements
   - Crée PR avec `Closes #XX`

**Important** : La PR inclut le passage à `done` de la story. L'acceptation de la PR valide le tout. Pas de commit post-merge nécessaire.

### Fermeture Automatique

```
PR merged dans api → Ticket api#15 fermé automatiquement (Closes #XX)
                   → Story déjà en "done" (inclus dans la PR)
                   → Issue GitHub fermée automatiquement
```

---

## 8. Agents

### Vue d'Ensemble

| Agent | Rôle | Déclenché par |
|-------|------|---------------|
| `init-agent` | Setup nouveau projet | `/init` |
| `onboard-agent` | Reverse engineering projet existant | `/onboard` |
| `dev-agent` | Implémentation TDD | `/work` |
| `review-agent` | Code review automatique | `/done` |
| `sync-agent` | Audit sync docs/code | `/sync` |
| `release-agent` | Orchestration release | `/release` |

### Dev Agent

**Responsabilités** :
- Comprendre les acceptance criteria
- Pratiquer le TDD (Red-Green-Refactor)
- Respecter les règles de `engineering/apps/[name].md`
- Créer les tickets par app dans la story

**Comportement** :
- Lit l'architecture de l'app avant de coder
- Écrit les tests en premier
- Ne bloque pas sur les violations (warning)
- Documente les décisions techniques

### Review Agent

**Responsabilités** :
- Vérifier Clean Code (naming, functions, DRY, SRP...)
- Vérifier Architecture (layers, dependencies)
- Vérifier couverture de tests
- Vérifier sync documentation

**Comportement** :
- Appelé automatiquement par `/done`
- Retourne PASS ou FAIL avec détails
- Si FAIL : liste les problèmes à corriger
- Itération jusqu'à PASS

### Cycle Dev-Review

```
Dev Agent (TDD)
     │
     ▼
  /done
     │
     ▼
Review Agent ──▶ PASS ──▶ PR Created
     │
     ▼ FAIL
     │
Feedback (problèmes listés)
     │
     ▼
Dev Agent (fixes)
     │
     ▼
  /done
     │
     ▼
Review Agent ──▶ ...
```

---

## 9. Règles de Code

### Piliers de Qualité

1. **Tests** : TDD, couverture minimum
2. **Lint** : 0 warning toléré
3. **Coverage** : seuil global (ex: 80%)
4. **Clean Code** : principes explicites
5. **Clean Architecture** : pattern par app

### Clean Code - Principes Enforced

Tous les principes suivants sont vérifiés par le Review Agent :

#### Naming
- Variables/fonctions : intention claire, pas d'abréviations cryptiques
- Classes : nom = responsabilité
- Fichiers : reflètent le contenu

#### Functions
- Courtes (< 20 lignes idéalement)
- Une seule responsabilité (SRP)
- Peu de paramètres (< 4)
- Pas d'effets de bord cachés

#### DRY (Don't Repeat Yourself)
- Pas de duplication de logique
- Extraction en fonctions/modules si répétition

#### Comments
- Code auto-documenté (pas de comment pour expliquer le "quoi")
- Comments uniquement pour le "pourquoi" non évident
- Pas de code commenté (supprimer)

#### Error Handling
- Exceptions explicites, pas de catch vide
- Messages d'erreur utiles
- Fail fast

#### Structure
- Imports organisés
- Ordre logique des membres
- Séparation des concerns

### Clean Architecture - Par App

Chaque app définit son pattern dans `engineering/apps/[name].md`.

**Patterns courants Backend** :
- **Layered** : Controllers → Services → Repositories
- **Hexagonal** : Domain au centre, Ports/Adapters autour
- **Clean Architecture** : Entities → Use Cases → Adapters → Frameworks
- **CQRS** : Séparation Command/Query

**Patterns courants Frontend** :
- **Component-based** : UI Components indépendants
- **Feature-based** : Organisation par feature métier
- **Atomic Design** : Atoms → Molecules → Organisms → Templates → Pages

**Règles communes** :
- Dépendances unidirectionnelles (pas de cycles)
- Domain/Business logic isolé des frameworks
- Testabilité : injection de dépendances

### Configuration Quality Gates

`.claude/quality.json` :

```json
{
  "coverage": {
    "minimum": 80,
    "enforce": true
  },
  "lint": {
    "warnings_allowed": 0,
    "command": "npm run lint"
  },
  "tests": {
    "required": true,
    "command": "npm test"
  },
  "build": {
    "required": true,
    "command": "npm run build"
  }
}
```

---

## 10. Git, Commits et PRs

### Git Flow

#### Par Défaut (/init) : GitHub Flow

Simple et efficace pour la plupart des projets :

```
main (protégée)
  │
  ├── feature/#15-oauth-login
  │     └── PR → main
  │
  ├── fix/#23-session-bug
  │     └── PR → main
  │
  └── tech/#30-refactor-auth
        └── PR → main
```

**Règles** :
- `main` est toujours déployable
- Branches courtes, PRs fréquentes
- Pas de branche `develop`

#### Onboarding : Respect de l'Existant

`/onboard` détecte le flow actuel et le conserve :

| Flow Détecté | Comportement |
|--------------|--------------|
| GitHub Flow | Conservé tel quel |
| GitFlow | Conservé (main + develop + feature/release/hotfix) |
| Trunk-based | Conservé |
| Custom | Documenté dans `.claude/repos.json` |

La détection analyse :
- Branches existantes (develop? release/*?)
- Historique de merge
- Patterns dans les noms de branches

### Branches

#### Types Autorisés

| Type | Pattern | Mergeable | Usage |
|------|---------|-----------|-------|
| `feature` | `feature/#XX-slug` | Oui | Nouvelles fonctionnalités |
| `fix` | `fix/#XX-slug` | Oui | Corrections de bugs |
| `tech` | `tech/#XX-slug` | Oui | Travail technique |
| `hotfix` | `hotfix/#XX-slug` | Oui | Fix urgent en prod |
| `release` | `release/vX.Y.Z` | Oui | Préparation release |
| `poc` | `poc/description` | **Non** | Exploration, prototype |
| `vibe` | `vibe/description` | **Non** | Expérimentation libre |

#### Naming Convention

```
type/#ticket-slug

Exemples :
feature/#15-oauth-login
fix/#23-session-timeout
tech/#30-migrate-prisma
poc/test-graphql
vibe/new-ui-idea
```

- `#XX` = numéro du ticket dans le repo de l'app
- `slug` = description courte en kebab-case
- Pour `poc/` et `vibe/` : pas de ticket requis

#### Branches Protégées

- `main` est **toujours** protégée (pas de push direct)
- `develop` si GitFlow
- **Configuration manuelle** : l'utilisateur configure la protection sur GitHub
- **flowc vérifie** : warning si tentative de push direct

### Commits

#### Format : Conventional Commits

```
type(scope): description (#ticket)

Exemples :
feat(auth): add Google OAuth login (#15)
fix(api): resolve session timeout issue (#23)
refactor(user): extract validation service (#30)
docs(readme): update installation steps (#31)
test(auth): add OAuth flow tests (#15)
```

#### Types de Commit

| Type | Description | Exemple |
|------|-------------|---------|
| `feat` | Nouvelle fonctionnalité | `feat(auth): add login` |
| `fix` | Correction de bug | `fix(api): null check` |
| `refactor` | Refactoring sans changement fonctionnel | `refactor(user): extract service` |
| `docs` | Documentation | `docs(api): add endpoints` |
| `test` | Ajout/modification de tests | `test(auth): add unit tests` |
| `style` | Formatage, pas de changement de code | `style(lint): fix formatting` |
| `chore` | Maintenance, dépendances | `chore(deps): update packages` |
| `perf` | Amélioration de performance | `perf(db): add index` |
| `ci` | CI/CD | `ci(github): add workflow` |

#### Scope (Auto-détecté)

Le scope est déduit automatiquement des fichiers modifiés :

| Fichiers Modifiés | Scope Détecté |
|-------------------|---------------|
| `src/auth/*` | `auth` |
| `src/api/*` | `api` |
| `src/components/*` | `ui` |
| `src/services/user/*` | `user` |
| Plusieurs modules | scope le plus impacté ou omis |

#### Référence Ticket

**Toujours inclure** le numéro de ticket :

```
feat(auth): add OAuth login (#15)
                            ^^^^
                            Référence ticket
```

Permet :
- Traçabilité totale
- Lien automatique GitHub
- Fermeture auto à la PR

#### Workflow de Commits

**Pendant le développement** :
- Commits fréquents encouragés
- Chaque commit respecte le format conventional
- Petits commits atomiques (une chose à la fois)

```bash
# Bon : commits atomiques
feat(auth): add OAuth redirect endpoint (#15)
feat(auth): add OAuth callback handler (#15)
feat(auth): add token storage (#15)
test(auth): add OAuth flow tests (#15)

# Éviter : commit monolithique
feat(auth): add complete OAuth system (#15)
```

**Au merge (PR)** :
- Squash and merge → 1 commit propre dans main
- Message du squash = titre de la PR

### Pull Requests

#### Création

`/done` crée automatiquement une PR avec :

1. **Titre** : généré depuis le(s) commit(s)
2. **Description** : template rempli automatiquement
3. **Labels** : selon le type (feature, fix, tech...)
4. **Référence** : `Closes #XX` pour fermeture auto

#### Template PR

```markdown
## Summary

[Description auto-générée depuis les commits]

## Related Issue

Closes #15

## Changes

- Added GoogleAuthService for OAuth flow
- Created callback endpoint /auth/google/callback
- Added token refresh mechanism
- Updated login page with Google button

## Test Plan

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing done
  - [ ] Login flow works
  - [ ] Token refresh works
  - [ ] Error cases handled

## Screenshots

[Si changements UI - before/after]

## Breaking Changes

[Si applicable - migration requise, API changée...]

## Checklist

- [ ] Tests ajoutés/mis à jour
- [ ] Documentation mise à jour
- [ ] Pas de console.log oubliés
- [ ] Pas de secrets dans le code
```

#### Merge Strategy

**Squash and Merge** (par défaut) :
- Tous les commits de la branche → 1 seul commit dans main
- Historique main propre et lisible
- Message = titre PR + description

```
Avant merge :
main:     A---B---C
               \
feature:        D---E---F---G

Après squash merge :
main:     A---B---C---H (squash de D+E+F+G)
```

#### Gestion des Conflits

**Stratégie : Merge main dans la branche**

```bash
# Sur la feature branch
git fetch origin
git merge origin/main
# Résoudre les conflits
git commit
git push
```

Pourquoi merge plutôt que rebase :
- Historique préservé
- Moins risqué pour branches partagées
- Conflits résolus une seule fois

#### Fermeture Automatique

```
PR merged avec "Closes #15"
  → Issue #15 fermée automatiquement
  → Story S-042 mise à jour (ticket = done)
  → Si tous tickets done → Story = done → Issue story fermée
```

### Configuration Git

#### .claude/repos.json

```json
{
  "principal": {
    "repo": "org/project",
    "main_branch": "main",
    "flow_type": "github-flow",
    "protected_branches": ["main"]
  },
  "apps": {
    "api": {
      "repo": "org/api",
      "main_branch": "main",
      "commit_format": "conventional",
      "branch_pattern": "type/#*-slug",
      "merge_strategy": "squash"
    },
    "web": {
      "repo": "org/web",
      "main_branch": "main",
      "commit_format": "conventional",
      "branch_pattern": "type/#*-slug",
      "merge_strategy": "squash"
    }
  }
}
```

#### Détection Automatique (/onboard)

L'onboarding détecte :
- Format de commit existant (analyse des 50 derniers commits)
- Pattern de branches (analyse des branches)
- Flow type (présence de develop, release/*, etc.)
- Branche principale (main vs master)

Résultat stocké dans `.claude/repos.json` avec `"detected": true`.

### Commandes Git

| Commande | Description |
|----------|-------------|
| `/commit` | Créer un commit formaté |
| `/commit "message"` | Commit avec message custom |
| `/pr` | Créer PR pour branche courante |
| `/pr review #XX` | Reviewer une PR |
| `/pr merge #XX` | Merger une PR |

### Résumé Visuel

```
                    ┌─────────────────────────────────────┐
                    │            REPOSITORY               │
                    └─────────────────────────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
               ┌────────┐      ┌────────┐      ┌────────┐
               │  main  │      │  main  │      │  main  │
               │  (api) │      │  (web) │      │(project)│
               └────────┘      └────────┘      └────────┘
                    │                │                │
         ┌─────────────────┐        │                │
         │                 │        │                │
         ▼                 ▼        ▼                │
    feature/#15      fix/#23   feature/#24           │
         │                 │        │                │
         │ commits         │        │                │
         │ feat(auth):...  │        │                │
         │ test(auth):...  │        │                │
         ▼                 ▼        ▼                │
        PR ──────────────────────────────────────────┤
         │                                           │
         │ Squash & Merge                            │
         ▼                                           │
      main ◄─────────────────────────────────────────┘
         │
         │ Closes #15 → Story S-042 updated
         ▼
      Deploy
```

---

## 11. Environnements

### Vue d'Ensemble

flowc gère 3 environnements par défaut :

| Environnement | Description | Déploiement |
|---------------|-------------|-------------|
| **local** | Machine du développeur | `docker-compose up` |
| **staging** | Pré-production, tests finaux | Auto sur merge to main |
| **prod** | Production | `/release promote` |

**Optionnel** : environnement `dev` partagé pour équipes > 3 personnes.

### Local

#### Structure

```
apps/devops/
├── docker/
│   ├── docker-compose.yml        # Config de base
│   ├── docker-compose.dev.yml    # Overrides dev (volumes, hot-reload)
│   └── docker-compose.prod.yml   # Overrides prod (optimisé)
├── env/
│   ├── .env.example              # Template (committé)
│   ├── .env.local                # Variables locales (gitignored)
│   ├── .env.staging              # Variables staging
│   └── .env.prod                 # Variables prod (secrets externalisés)
└── scripts/
    ├── setup.sh                  # Installation initiale
    ├── dev.sh                    # Lancer env local
    └── deploy.sh                 # Script de déploiement
```

#### Commandes

```bash
/env local              # Démarrer environnement local
/env local stop         # Arrêter
/env local restart      # Redémarrer
/env local logs api     # Voir logs d'une app
/env local status       # Status des containers
```

#### Fonctionnement

```bash
# /env local exécute :
cd apps/devops/docker
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

### Staging

- **Déploiement** : automatique sur merge to main
- **URL** : configurée dans `apps/devops/env/.env.staging`
- **Données** : base de données de test, données anonymisées

#### CI/CD

Le merge to main déclenche :
1. Build de l'app
2. Push de l'image Docker
3. Déploiement sur staging
4. Tests de smoke

```yaml
# Exemple GitHub Actions (généré par /init)
on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t $IMAGE .
      - run: docker push $IMAGE
      - run: ./apps/devops/scripts/deploy.sh staging
```

### Production

- **Déploiement** : manuel via `/release promote`
- **Sécurité** : confirmation requise, rollback disponible
- **Monitoring** : health checks configurés

#### Promotion Staging → Prod

```bash
/release promote

# Vérifie :
# - Staging healthy
# - Tous tests passent
# - Pas de PR en attente critique

# Demande confirmation :
# "Promouvoir v1.2.0 en production ? (y/n)"

# Exécute :
# - Tag de release prod
# - Déploiement
# - Notification
```

### Commandes /env

| Commande | Description |
|----------|-------------|
| `/env` | Status de tous les environnements |
| `/env local` | Démarrer local |
| `/env local stop` | Arrêter local |
| `/env local logs [app]` | Voir logs |
| `/env staging status` | Status staging |
| `/env prod status` | Status production |

### Variables d'Environnement

#### Gestion des Secrets

```
.env.local      → Secrets locaux (gitignored)
.env.staging    → Références vers secrets manager
.env.prod       → Jamais de secrets en clair
```

**Bonnes pratiques** :
- Secrets en prod via secret manager (AWS Secrets, Vault, etc.)
- `.env.example` avec valeurs placeholder
- Jamais de secrets dans le repo

---

## 12. Release

### Philosophie

Une release = version stable, testée, prête pour la prod.

### Versioning

**Semantic Versioning** par app :
- `MAJOR.MINOR.PATCH`
- Ex: `api` v1.2.0, `web` v2.0.1

| Type | Quand | Exemple |
|------|-------|---------|
| PATCH | Bug fix, pas de nouvelles features | 1.2.0 → 1.2.1 |
| MINOR | Nouvelles features, backward compatible | 1.2.0 → 1.3.0 |
| MAJOR | Breaking changes | 1.2.0 → 2.0.0 |

### Workflow Release

```
/release [app]
    │
    ├── Vérifie sprint done (ou force avec --force)
    │
    ├── Détermine version (auto ou --version X.Y.Z)
    │
    ├── Génère CHANGELOG.md
    │
    ├── Crée tag Git
    │
    ├── Crée GitHub Release
    │
    └── Déploie sur staging
```

### Commandes

```bash
/release                    # Release toutes les apps modifiées
/release api                # Release app spécifique
/release api --version 2.0.0  # Version explicite
/release --dry-run          # Preview sans exécuter
/release promote            # Promouvoir staging → prod
```

### Changelog

Généré automatiquement depuis les commits :

```markdown
# Changelog

## [1.3.0] - 2025-01-15

### Added
- OAuth login with Google (#42)
- Password reset flow (#43)

### Fixed
- Session timeout issue (#44)

### Changed
- Refactored auth module (#45)
```

### Release Multi-App

Si une story touche plusieurs apps :
1. Chaque app a sa release indépendante
2. Le repo principal peut avoir une "meta-release" qui référence les versions

```bash
/release              # Release api v1.3.0, web v2.1.0
```

### Rollback

```bash
/release rollback api         # Rollback dernière release
/release rollback api v1.2.0  # Rollback vers version spécifique
```

---

## 13. Guards et Hooks

### Concept

Les guards sont des vérifications automatiques qui :
- **Bloquent** les actions non conformes (exit code 2)
- **Avertissent** sans bloquer (exit code 0 + message)

### Hooks Configurés

```json
// hooks/hooks.json
{
  "hooks": {
    "SessionStart": [...],
    "Stop": [...],
    "PreToolUse": [...],
    "UserPromptSubmit": [...]
  }
}
```

### Guard : Story Required

**Quand** : Tentative de commit sans branche ticket

**Comportement** : Bloque (exit 2)

```
❌ BLOCKED: Commit without ticket branch

Current branch: my-feature
Expected: feature/#XX-*, fix/#XX-*, tech/#XX-*

Options:
1. Create a story: /story "description"
2. Start work: /work S-XXX
3. Use poc/ or vibe/ for exploration (won't be merged)
```

**Exception** : Branches `poc/*` et `vibe/*` autorisées (mais non-mergeables)

### Guard : Secrets Detection

**Quand** : Écriture de fichier avec pattern de secret

**Comportement** : Warning (exit 0)

```
⚠️ POTENTIAL SECRET DETECTED

File: src/config.ts
Pattern: AWS Access Key (AKIA...)

Recommendations:
• Use environment variables
• Store in apps/devops/env/.env.local
• Use secret manager for prod

Proceeding anyway...
```

**Patterns détectés** :
- AWS keys (AKIA...)
- API keys (api_key, apiKey, API_KEY)
- Passwords en dur
- Private keys
- Tokens JWT/OAuth

### Guard : Protected Branch

**Quand** : Push direct sur main

**Comportement** : Warning (configuration manuelle requise sur GitHub)

```
⚠️ PROTECTED BRANCH WARNING

Attempting to push directly to 'main'.
This branch should be protected.

Configure branch protection on GitHub:
Settings → Branches → Add rule → main
```

### Guard : Non-Mergeable Branch

**Quand** : Tentative de merge `poc/*` ou `vibe/*`

**Comportement** : Bloque (exit 2)

```
❌ BLOCKED: Cannot merge exploration branch

Branch 'poc/test-graphql' is for exploration only.
These branches are not meant to be merged.

If the POC is successful:
1. Create a story: /story "Implement GraphQL"
2. Implement properly with TDD
```

### Guard : Scope Creep

**Quand** : Ajout de story à un sprint actif

**Comportement** : Warning avec confirmation

```
⚠️ SCOPE CREEP WARNING

Adding S-050 to active Sprint 03.
Current stories: 5
New total: 6

This may delay sprint completion.
Reason required: [user input]

Continue? (y/n)
```

### Guard : Quality Gates

**Quand** : `/done` avec tests/lint qui échouent

**Comportement** : Bloque création PR

```
❌ QUALITY GATES FAILED

Coverage: 72% (minimum: 80%)
Lint: 3 warnings (maximum: 0)
Tests: 2 failing

Fix these issues before creating PR.
```

### Désactiver un Guard

Dans `flowc.json` :

```json
{
  "guards": {
    "secrets_warning": true,
    "story_required": true,
    "scope_creep_warning": true,
    "quality_gates": true
  }
}
```

---

## 14. Documentation

### Structure Documentaire

```
project/                    # Gestion de projet
├── backlog/               # Stories (S-XXX.md)
└── sprints/               # Sprints (sprint-XX.md)

engineering/               # Documentation technique interne
├── architecture.md        # Vue globale système
├── stack.md              # Choix technologiques
├── dependencies.md        # Graphe dépendances apps
├── decisions/            # ADRs
│   └── ADR-XXX-titre.md
└── apps/                 # Doc par app
    ├── api.md
    └── web.md

docs/                      # Documentation publique
├── api/                  # Doc API (OpenAPI, etc.)
└── guides/               # Guides utilisateur
```

### Document App (engineering/apps/[name].md)

Template :

```markdown
# [App Name]

## Overview

Description courte de l'app, son rôle dans le système.

## Architecture Pattern

**Pattern** : [Hexagonal / Layered / Clean / Feature-based / ...]

### Diagram

[Schéma des layers/modules]

### Layer Structure

```
src/
├── domain/          # Entities, Value Objects, Domain Services
├── application/     # Use Cases, Application Services
├── infrastructure/  # DB, External APIs, Frameworks
└── presentation/    # Controllers, Views, DTOs
```

## Dependencies

- Dépend de : [autres apps ou services externes]
- Utilisé par : [qui consomme cette app]

## Clean Code Rules

Règles spécifiques à cette app :

- [Règle 1]
- [Règle 2]
- ...

## Testing Strategy

- **Unit tests** : domain/, application/
- **Integration tests** : infrastructure/
- **E2E tests** : [si applicable]
- **Coverage target** : 80%

## API

[Si applicable : endpoints principaux, contrats]

## Deployment

- **Build** : `npm run build`
- **Docker** : `apps/devops/docker/[name].Dockerfile`
- **Environments** : dev, staging, production
- **Spécificités** : [scaling, secrets, etc.]
```

### Synchronisation Docs ↔ Code

**Triple vérification** :

1. **Warning au /done** : si fichiers modifiés touchent des sections documentées
2. **/sync** : audit complet manuel
3. **Review Agent** : vérifie la cohérence

```bash
/sync                # Audit complet
/sync --fix          # Tente de corriger automatiquement
```

---

## 15. Intégration GitHub

### Modèle de Liaison

```
REPO PRINCIPAL (org/project)
├── Issue #42 ← Story S-042
│
├── project/backlog/S-042-oauth-login.md
│   └── github: org/project#42
│   └── tickets:
│       ├── api#15 → org/api#15
│       └── web#23 → org/web#23

REPO API (org/api)
├── Issue #15 ← Ticket de S-042
├── Branch: feature/#15-oauth-backend
└── PR #XX → Closes #15

REPO WEB (org/web)
├── Issue #23 ← Ticket de S-042
├── Branch: feature/#23-oauth-frontend
└── PR #XX → Closes #23
```

### Création Automatique

**`/story "titre"`** :
1. Crée `S-XXX-slug.md` dans `project/backlog/`
2. Crée Issue dans repo principal
3. Lie l'issue dans le frontmatter YAML

**`/work S-XXX --app api`** :
1. Crée Issue dans repo `api`
2. Met à jour la table Tickets dans `S-XXX.md`
3. Crée branche `feature/#XX-slug`

### Fermeture Automatique

**PR merged** :
```
PR "feat: OAuth backend" merged
  → "Closes #15" dans PR description
  → Issue api#15 fermée
  → flowc détecte fermeture
  → Met à jour S-042.md (ticket api = done)
  → Vérifie si tous tickets done
  → Si oui : Issue #42 fermée, S-042 status = done
```

### Migration Future

L'architecture permet de migrer vers Linear, Jira, etc. :
- Les liens sont dans le frontmatter YAML
- Le format S-XXX reste le même
- Seule l'intégration change

---

## 16. Configuration

### Fichiers de Configuration

flowc utilise 2 fichiers dans `.claude/` :

| Fichier | Contenu | Modifié |
|---------|---------|---------|
| `flowc.json` | Configuration statique du projet | Rarement |
| `session.json` | État runtime de la session | À chaque /work |

### .claude/flowc.json

Configuration principale du projet :

```json
{
  "project": {
    "name": "my-project",
    "repo": "org/project",
    "type": "saas"
  },

  "apps": {
    "api": {
      "path": "apps/api",
      "type": "backend",
      "repo": "org/api",
      "version": "1.2.0"
    },
    "web": {
      "path": "apps/web",
      "type": "frontend",
      "repo": "org/web",
      "version": "2.0.1"
    },
    "devops": {
      "path": "apps/devops",
      "type": "devops",
      "repo": null
    }
  },

  "git": {
    "principal": {
      "main_branch": "main",
      "flow_type": "github-flow",
      "protected_branches": ["main"]
    },
    "defaults": {
      "commit_format": "conventional",
      "branch_pattern": "type/#*-slug",
      "merge_strategy": "squash"
    }
  },

  "quality": {
    "coverage": { "minimum": 80, "enforce": true },
    "lint": { "warnings_allowed": 0 },
    "tests": { "required": true },
    "build": { "required": true }
  },

  "guards": {
    "story_required": true,
    "secrets_warning": true,
    "scope_creep_warning": true,
    "quality_gates": true
  },

  "environments": {
    "local": { "enabled": true },
    "staging": { "enabled": true, "auto_deploy": true },
    "prod": { "enabled": true }
  }
}
```

### .claude/session.json

État de la session de travail (runtime) :

```json
{
  "active_story": "S-042",
  "active_app": "api",
  "active_ticket": "api#15",
  "branch": "feature/#15-oauth-backend",
  "started_at": "2025-01-15T10:00:00Z",
  "status": "working",
  "current_sprint": "sprint-03"
}
```

Après `/done`, la session passe en `review` avec les infos PR :

```json
{
  "active_story": "S-042",
  "active_app": "api",
  "active_ticket": "api#15",
  "branch": "feature/#15-oauth-backend",
  "started_at": "2025-01-15T10:00:00Z",
  "status": "review",
  "current_sprint": "sprint-03",
  "pr_url": "https://github.com/org/api/pull/16",
  "pr_created_at": "2025-01-15T14:30:00Z"
}
```

### Génération

- `/init` crée `flowc.json` depuis les réponses au questionnaire
- `/onboard` génère `flowc.json` depuis la détection + questionnaire
- `session.json` est créé/mis à jour par `/work`
- `session.json` passe en `review` après `/done`

---

## 17. Cas Spéciaux

### Projet Mono-App

Pour un projet avec une seule application :

```
project/
├── apps/
│   └── api/                    # Une seule app
│       ├── .git/
│       └── ...
├── project/
├── engineering/
└── ...
```

**Comportement** :
- Pas besoin de `--app` dans les commandes
- `/work S-042` suffit (pas de `--app api`)
- Stories n'ont qu'un seul ticket

### App Type Plugin Claude

Pour les plugins Claude Code (markdown + scripts bash), les règles classiques ne s'appliquent pas.

#### Ce qui n'existe pas

| Concept | Raison |
|---------|--------|
| Tests unitaires | Pas de code exécutable |
| Build | Pas de compilation |
| Coverage | Rien à mesurer |
| Staging | Repo public = prod directe |

#### Ce qui les remplace

| Alternative | Description |
|-------------|-------------|
| `test.md` | Scénarios de test manuels documentés |
| `shellcheck` | Validation syntaxique des scripts bash |
| Tags git | Versioning via releases |
| `main` = prod | Repo public, installable directement |

#### Configuration

```json
// flowc.json
{
  "apps": {
    "flowc": {
      "type": "claude-plugin",
      "repo": "org/flowc"
    }
  },
  "quality": {
    "flowc": {
      "type": "claude-plugin",
      "tests": {
        "type": "manual",
        "file": "test.md",
        "required": true
      },
      "lint": {
        "scripts": "shellcheck",
        "enforce": false
      },
      "coverage": { "enforce": false },
      "build": { "enforce": false }
    }
  },
  "environments": {
    "prod": {
      "branch": "main",
      "description": "main = prod (public repo)"
    }
  }
}
```

#### Quality Gates Adaptés

À `/done`, vérification :
1. **test.md à jour** : Nouveaux scénarios si nouvelle feature
2. **Scripts valides** : `shellcheck scripts/*.sh`
3. **Documentation** : README cohérent

#### Workflow

```
feature branch → PR → merge to main → tagged release
                           ↓
                    Installable immédiatement
                    /plugin install org/flowc
```

### Hotfix en Production

#### Hotfix Critique (prod down)

Bypass le flow normal :

```bash
# 1. Créer branche hotfix depuis main
git checkout main
git checkout -b hotfix/#99-critical-fix

# 2. Fix rapide
# ...

# 3. PR directe vers main
/pr --hotfix

# 4. Créer story rétrospectivement
/story bug "Critical fix for #99" --done
```

#### Hotfix Important (non critique)

Suit le flow normal avec priorité :

```bash
# 1. Créer story bug
/story bug "Session timeout in production"

# 2. Ajouter au sprint (avec warning scope creep)
# 3. /work, /done normalement
```

### Travail en Équipe

#### Plusieurs Devs sur Même Story

Une story multi-app permet le parallélisme :

```
Story S-042: OAuth Login
├── Ticket api#15 → Dev A (backend)
└── Ticket web#23 → Dev B (frontend)
```

```bash
# Dev A
/work S-042 --app api
# ... travaille sur backend

# Dev B (en parallèle)
/work S-042 --app web
# ... travaille sur frontend
```

**Règles** :
- Chaque dev travaille sur son ticket
- PRs indépendantes
- Story "done" quand tous tickets done

#### Multi-Agents Claude

Plusieurs agents Claude peuvent travailler en parallèle :

```bash
# Agent 1: Backend
/work S-042 --app api

# Agent 2: Frontend (autre session)
/work S-042 --app web
```

**Coordination** :
- Chaque agent a sa `session.json` (ou partage si même machine)
- Pas de conflit si apps différentes
- Story mise à jour par le dernier `/done`

### Migration depuis Autre Outil

#### Depuis Jira/Linear

```bash
/onboard --import-tickets jira

# Détecte les tickets existants
# Propose de créer les stories correspondantes
# Lie les tickets importés
```

#### Vers Linear/Jira

```bash
/config set tracker linear

# Configure l'intégration
# /story créera dans Linear au lieu de GitHub Issues
```

### Projet sans GitHub

Pour GitLab, Bitbucket, ou self-hosted :

```json
// flowc.json
{
  "git": {
    "provider": "gitlab",
    "principal": {
      "repo": "group/project",
      "url": "https://gitlab.company.com"
    }
  }
}
```

**Support** :
- GitHub (par défaut)
- GitLab (à venir)
- Bitbucket (à venir)

### Story sans Sprint

Pour du travail hors sprint (maintenance, support) :

```bash
/story tech "Update dependencies" --no-sprint

# Crée la story dans le backlog
# Peut être travaillée sans être dans un sprint
# Warning: recommandé de planifier dans un sprint
```

### Annuler un /work

Si tu as commencé à travailler mais veux abandonner :

```bash
/work abort

# Supprime la branche locale
# Ferme le ticket (si créé)
# Remet la story en "ready"
# Clear la session
```

---

## 18. Commandes Référence

### Projet

| Commande | Description |
|----------|-------------|
| `/init` | Initialiser nouveau projet |
| `/onboard` | Onboarder projet existant |
| `/status` | Status global projet |
| `/apps` | Gérer les applications |

### Stories & Sprints

| Commande | Description |
|----------|-------------|
| `/story "titre"` | Créer une story |
| `/sprint` | Status sprint actif |
| `/sprint plan` | Planifier prochain sprint |
| `/sprint start` | Démarrer sprint planifié |
| `/sprint close` | Clôturer sprint |

### Développement

| Commande | Description |
|----------|-------------|
| `/work S-XXX` | Commencer travail sur story |
| `/work S-XXX --app api` | Travailler sur app spécifique |
| `/done` | Terminer (review + PR) |
| `/commit` | Commit intermédiaire |

### Qualité & Docs

| Commande | Description |
|----------|-------------|
| `/sync` | Vérifier sync docs/code |
| `/debt` | Gérer dette technique |
| `/decision` | Gérer ADRs |

### Ops

| Commande | Description |
|----------|-------------|
| `/env` | Gérer environnements |
| `/release` | Créer release |
| `/pr` | Gérer PRs |
| `/bye` | Terminer session |

---

## Annexe : Exemple Workflow Complet

```bash
# 1. Nouveau projet
/init
# → Questions vision, personas, stack...
# → Génère structure + Sprint 0

# 2. Sprint 0 : Setup
/work S-001
# → Setup initial
/done

# 3. Créer features
/story "User Registration"
/story "OAuth Login"
/story "Password Reset"

# 4. Planifier Sprint 1
/sprint plan
# → Sélectionne S-002, S-003, S-004

/sprint start

# 5. Développer
/work S-002 --app api
# [Dev Agent: TDD sur backend registration]
/done
# [Review Agent: check, itération si besoin]

/work S-002 --app web
# [Dev Agent: TDD sur frontend registration]
/done

# 6. Story suivante
/work S-003 --app api
# ...

# 7. Sprint terminé
/sprint close
# → Toutes stories done
# → Sprint 01 = done

# 8. Release
/release
# → Tag versions
# → Changelog généré
# → Deploy staging
```

---

*flowc v1.0.0 - Story-First Development pour Claude Code*
