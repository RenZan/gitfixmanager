# 🚀 Git Fix Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/RenZan/gitfixmanager/releases)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-lightgrey.svg)](https://github.com/RenZan/gitfixmanager)

**Interface ultra-simplifiée pour détecter et suivre les corrections manquantes dans vos projets Git.**

Évitez les oublis de backport et assurez-vous que tous vos bugs ont leurs corrections dans les bonnes branches !

## ✨ Avant/Après

**AVANT** (complexe) :
```bash
./scripts/missing-fix-detector.sh mark-bug abc1234 "BUG-001" "Memory leak"
./scripts/missing-fix-detector.sh mark-fix def5678 "BUG-001" abc1234
./scripts/missing-fix-detector.sh check release/v1.0
```

**MAINTENANT** (ultra-simple) :
```bash
gfm bug "Memory leak"              # Auto-génère ID, détecte commit
gfm fix BUG-20250918-XXXX         # Auto-résout le bug
gfm check release/v1.0             # Vérification complète
```

## ⚡ Installation Rapide

```bash
# Clone et installation automatique
git clone https://github.com/RenZan/gitfixmanager.git
cd gitfixmanager
./install-smart.sh
```

**C'est tout !** L'outil est prêt avec la commande `gfm` disponible partout.

## 🎯 Utilisation en 3 Commandes

### 1. Marquer un Bug
```bash
gfm bug "Memory leak in authentication"
# → ✅ Bug BUG-20250918-A1B2 marqué automatiquement
```

### 2. Marquer une Correction
```bash
# Après avoir fait votre commit de correction
gfm fix BUG-20250918-A1B2
# → ✅ Correction liée automatiquement
```

### 3. Vérifier avant Release
```bash
gfm check release/v2.1.0
# → 🚨 ou ✅ Rapport des corrections manquantes
```

## 🚀 Fonctionnalités Principales

- **🤖 Auto-génération d'ID** : Plus besoin de gérer les identifiants manuellement
- **🎯 Auto-détection** : Reconnaît automatiquement commits, branches, descriptions  
- **✅ Vérification simple** : `gfm check` pour valider avant push
- **💬 Interface intuitive** : Mode interactif pour débutants
- **⚡ Ultra-rapide** : 5 secondes pour marquer un bug vs 30 secondes avant
- **🌍 Multi-plateforme** : Linux, macOS, Windows (WSL)

## 🎯 Marquage sur N'importe Quel Commit

**⭐ FONCTIONNALITÉ CLÉ** : Vous pouvez marquer des bugs/corrections sur n'importe quel commit, pas seulement HEAD !

### 🐛 Marquer des Bugs Historiques

```bash
# Bug sur le commit actuel (défaut)
gfm bug "Memory leak in login"

# Bug sur un commit spécifique (par hash)
gfm bug "Security vulnerability" abc1234

# Bug sur un commit relatif
gfm bug "Regression introduced" HEAD~3

# Bug sur un tag ou une branche
gfm bug "Critical bug in release" v1.0.0
gfm bug "Issue in feature" feature/oauth
```

### 🔧 Marquer des Corrections Historiques

```bash
# Correction sur le commit actuel (défaut)
gfm fix BUG-20250918-A1B2

# Correction sur un commit spécifique
gfm fix BUG-20250918-A1B2 def5678

# Correction sur un commit relatif
gfm fix BUG-20250918-A1B2 HEAD~1

# Correction sur une autre branche
gfm fix BUG-20250918-A1B2 hotfix/security-patch
```

### 💡 Cas d'Usage Typiques

**Audit de sécurité** :
```bash
# Après découverte d'une faille dans un ancien commit
gfm bug "SQL injection vulnerability" v1.2.3
# Puis marquer la correction récente
gfm fix BUG-20250918-XXXX
```

**Analyse post-mortem** :
```bash
# Marquer le commit qui a introduit le bug
gfm bug "Performance regression" 89abc12
# Marquer tous les commits de correction
gfm fix BUG-20250918-YYYY fix-commit-1
gfm fix BUG-20250918-YYYY fix-commit-2  
```

**Backport tracking** :
```bash
# Bug trouvé sur main, déjà corrigé sur develop
gfm bug "Cache invalidation bug" main
gfm fix BUG-20250918-ZZZZ develop
# → Système détectera que la correction manque sur main
```

## 📖 Guide Rapide

### Cas d'Usage Quotidiens

**Développement quotidien** :
```bash
# Matin - bug découvert
gfm bug "Login fails with special characters"

# Après-midi - correction développée  
git commit -m "Fix login with special chars"
gfm fix BUG-20250918-F3A7

# Soir - vérification avant merge
gfm check main
```

**Workflow équipe** :
```bash
# Developer A trouve un bug
gfm bug "Token refresh not working"

# Developer B corrige sur une branche
git checkout hotfix/oauth-fix
git commit -m "Fix token refresh logic"
gfm fix BUG-20250918-B8C9

# Release Manager vérifie
gfm check release/v2.1.0
# → 🚨 Correction manquante ! Cherry-pick suggéré
```

## ✅ Vérification Avant Push

Avant de pousser votre code, vérifiez qu'aucune correction n'est manquante :

```bash
# Vérifier la branche actuelle
gfm check

# Vérifier une branche spécifique
gfm check ma-branche

# Vérifier un tag avant release
gfm check v1.0.0
```

**🎯 Bonne pratique** : Toujours faire `gfm check` avant un `git push` important !

```bash
# Exemple de workflow recommandé
git commit -m "Fix critical bug"
gfm check                    # ✅ Vérification avant push
git push origin v1.0.0      # � Push en toute sécurité
```

## 📚 Documentation

- **[Guide des commits spécifiques](./docs/MARQUAGE-COMMITS-SPECIFIQUES.md)** - Marquer des bugs sur n'importe quel commit
- **[Changelog complet](./docs/TRANSFORMATION-COMPLETE.md)** - Historique des améliorations
- **[Contributing](./CONTRIBUTING.md)** - Comment contribuer au projet

## 🔧 Commandes Complètes

| Commande | Raccourci | Description | Exemple |
|----------|-----------|-------------|---------|
| `gfm bug` | `gfm b` | Marquer un bug | `gfm bug "Memory leak" [commit]` |
| `gfm fix` | `gfm f` | Marquer une correction | `gfm fix BUG-001 [commit]` |
| `gfm check` | `gfm c` | Vérifier corrections | `gfm check release/v1.0` |
| `gfm list` | `gfm l` | Lister bugs/fixes | `gfm list bugs` |
| `gfm status` | `gfm s` | Statut repository | `gfm status` |
| `gfm interactive` | `gfm i` | Mode guidé | `gfm interactive` |
| `gfm help` | `gfm h` | Aide contextuelle | `gfm help fix` |

> 💡 **Astuce** : `[commit]` est optionnel - si omis, utilise HEAD (commit actuel)

## 💻 Compatibilité

- **Linux** : Native
- **macOS** : Native  
- **Windows** : Via WSL (Windows Subsystem for Linux)
- **Git** : Versions 2.0+

## 🤝 Contributing

Les contributions sont les bienvenues ! Consultez [CONTRIBUTING.md](./CONTRIBUTING.md) pour :

- 🐛 Reporter des bugs
- 💡 Proposer des fonctionnalités
- 🔧 Soumettre du code
- 📖 Améliorer la documentation

## 📄 License

Ce projet est sous licence [MIT](./LICENSE).

## 🙏 Remerciements

- Inspiré par les besoins réels de gestion de branches de release
- Conçu pour simplifier les workflows Git complexes
- Testé en environnement professionnel

---

**⭐ Si Git Fix Manager vous aide, n'hésitez pas à lui donner une étoile !**

**🚀 Objectif : Zero correction manquante dans vos releases !**