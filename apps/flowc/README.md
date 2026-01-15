# flowc

Plugin de workflow de développement pour Claude Code.

> **Work in Progress** : Ce plugin est en cours de développement. Voir [docs/GUIDE.md](../../docs/GUIDE.md) pour la spec complète.

## Status

🚧 **En construction** - Les anciennes commandes ont été archivées dans `_legacy/` (gitignored). Nous reconstruisons chaque composant proprement.

## Structure actuelle

```
flowc/
├── .claude-plugin/
│   └── plugin.json      # Manifest du plugin
├── _legacy/             # Anciennes implémentations (gitignored)
├── commands/            # À implémenter
├── agents/              # À implémenter
├── skills/              # À implémenter
├── test.md              # Scénarios de test manuels
└── README.md
```

## Roadmap (Sprint 0)

| Story | Description | Status |
|-------|-------------|--------|
| S-001 | Restructuration monorepo | ✅ done |
| S-002 | /story interactif + draft/ready | 🔄 in progress |
| S-003 | /work basique | ⬜ ready |
| S-004 | /done basique | ⬜ ready |

## Installation

```bash
/plugin install l3toII/claude-plugins/apps/flowc
```

## Documentation

- [Guide Complet](../../docs/GUIDE.md) - Spec détaillée du plugin
- [Architecture flowc](../../engineering/apps/flowc.md) - Conventions spécifiques

## License

MIT
