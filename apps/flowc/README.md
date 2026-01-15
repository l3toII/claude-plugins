# flowc

Plugin de workflow de développement pour Claude Code.

> **Work in Progress** : Ce plugin est en cours de développement. Voir [docs/GUIDE.md](../../docs/GUIDE.md) pour la spec complète.

## Installation

### Mode développement (recommandé pour contribuer)

Charge le plugin directement depuis ton système de fichiers :

```bash
# Cloner le repo
git clone git@github.com:l3toII/claude-plugins.git
cd claude-plugins

# Lancer Claude Code avec le plugin
claude --plugin-dir ./apps/flowc
```

Tu peux charger plusieurs plugins :

```bash
claude --plugin-dir ./apps/flowc --plugin-dir ./apps/autre-plugin
```

Les modifications sont prises en compte au redémarrage de Claude Code.

### Via marketplace (production)

1. Ajouter le marketplace :

```shell
/plugin marketplace add l3toII/claude-plugins
```

2. Installer le plugin :

```shell
/plugin install flowc@l3toII/claude-plugins
```

Ou en une seule commande CLI :

```bash
claude plugin install flowc@l3toII/claude-plugins --scope project
```

### Vérifier l'installation

```shell
/help              # flowc:story doit apparaître
/flowc:story       # Tester la commande
```

## Utilisation

```shell
/story "Ajouter un bouton logout"     # Créer une story
/story S-005                           # Raffiner une story existante
/story --draft "Feature rapide"        # Créer en draft (pas d'issue GitHub)
/story --ready "Feature urgente"       # Créer avec issue GitHub
```

## Structure

```
flowc/
├── .claude-plugin/
│   └── plugin.json      # Manifest du plugin
├── commands/            # Commandes slash
│   └── story.md
├── skills/              # Skills (connaissances)
│   └── story.md
├── templates/           # Templates de fichiers
│   └── story.md
└── README.md
```

## Status (Sprint 0)

| Story | Description | Status |
|-------|-------------|--------|
| S-001 | Restructuration monorepo | ✅ done |
| S-002 | /story interactif + draft/ready | ✅ done |
| S-003 | /work basique | ⬜ ready |
| S-004 | /done basique | ⬜ ready |

## Documentation

- [Guide Complet](../../docs/GUIDE.md) - Spec détaillée du plugin
- [Test Sprint 00](../../project/sprints/test-sprint-00.md) - Tests d'acceptation

## Troubleshooting

**Les commandes n'apparaissent pas ?**

```bash
# Vider le cache des plugins
rm -rf ~/.claude/plugins/cache

# Relancer avec --plugin-dir
claude --plugin-dir ./apps/flowc
```

**Vérifier la version de Claude Code :**

```bash
claude --version  # Plugins requièrent v1.0.33+
```

## License

MIT
