# Git Fix Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](https://github.com/RenZan/gitfixmanager/releases)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-lightgrey.svg)](https://github.com/RenZan/gitfixmanager)

Git Fix Manager marque les bugs et leurs corrections à travers les branches et garantit que les corrections critiques sont propagées dans tout votre code.

## Principe de fonctionnement

**Stockage natif dans Git** : Git Fix Manager utilise le système des **notes Git** pour stocker les informations directement dans le dépôt Git. Aucune base de données externe, aucun fichier supplémentaire - tout est intégré nativement dans votre historique Git.

```bash
# Les informations sont stockées comme notes Git
git notes --ref=refs/notes/bugs show <commit>
git notes --ref=refs/notes/fixes show <commit>
```

Cette approche garantit que les données de marquage voyagent avec votre code lors des clones, pushs et pulls.

## Pourquoi cet outil existe

Dans les projets complexes avec plusieurs branches de release, **cherry-picker des corrections spécifiques est souvent plus efficace que merger des branches entières**. Cette approche offre plusieurs avantages clés :

**Avantages du cherry-pick vs merge de branches :**
- **Propagation sélective** : Appliquer uniquement les corrections nécessaires sans fonctionnalités non désirées
- **Historique propre** : Maintenir un historique linéaire sur les branches stables
- **Réduction des risques** : Éviter l'introduction de régressions par des changements non liés
- **Contrôle des releases** : Choisir exactement quelles corrections vont dans chaque release
- **Efficacité des hotfixes** : Déployer rapidement les corrections critiques sur les branches de production

**Cependant**, cette approche sélective introduit un défi critique : **s'assurer qu'aucune correction n'est oubliée**. Manquer un patch de sécurité ou une correction critique sur une branche de production peut avoir des conséquences graves.

Git Fix Manager résout ce problème en fournissant un suivi systématique des bugs et de leurs corrections à travers toutes les branches, avec détection intelligente des corrections manquantes.

## Utilisation simple

**Pour débuter facilement**, utilisez simplement :

```bash
gfm
```

L'outil vous guide pas à pas et vous propose :
- ✅ Marquer un nouveau bug découvert
- ✅ Marquer qu'un bug existant est corrigé
- ✅ Vérifier les corrections manquantes sur une branche
- ✅ Lister les bugs ou corrections existants

## Commandes directes (pour les utilisateurs avancés)

```bash
gfm bug "Fuite mémoire dans le parser"    # Marquer un bug
gfm fix BUG-20250921-A1B2                # Le marquer comme corrigé
gfm check release/v2.1                   # Vérifier que toutes les corrections sont présentes
```

## Installation

### Installation rapide
```bash
curl -fsSL https://raw.githubusercontent.com/RenZan/gitfixmanager/main/install.sh | bash
```

### Installation manuelle
```bash
git clone https://github.com/RenZan/gitfixmanager.git
cd gitfixmanager
./install-smart.sh
```

Ceci installe la commande `gfm` et les extensions Git natives sur tout le système.

## Utilisation - Deux interfaces disponibles

### 🎯 Interface Git native (recommandée)
```bash
# Mode interactif guidé
git bug

# Commandes directes  
git bug "Description du problème"
git fix BUG-20250921-A1B2
git bugcheck
```

### 🚀 Interface GFM classique
```bash
# Mode interactif guidé
gfm

# Commandes directes
gfm bug "Description du problème"
gfm fix BUG-20250921-A1B2
gfm check
```

## Utilisation avancée - Commandes directes

### 1. Marquer un bug
```bash
git bug "Fuite mémoire dans l'authentification"
# Génère : BUG-20250921-A1B2
```

### 2. Marquer une correction
```bash
# Après avoir commité votre correction
gfm fix BUG-20250921-A1B2
# Lie le commit actuel comme correction pour ce bug
```

### 3. Vérifier l'exhaustivité d'une branche
```bash
gfm check release/v2.1.0
# Rapporte tous les bugs qui manquent de corrections sur cette branche
```

## Fonctionnalités principales

- **Interface guidée** : Workflow pas-à-pas accessible via `gfm`
- **Marquage bugs/corrections** : Lie les bugs à leurs corrections via les notes Git
- **Détection inter-branches** : Identifie les corrections manquantes à travers différentes branches
- **Détection de cherry-pick** : Utilise plusieurs heuristiques pour détecter si les corrections ont été cherry-pickées
- **Ciblage de commits** : Marquer bugs/corrections sur n'importe quel commit, pas seulement HEAD
- **Listing contextuel** : Affiche seulement les bugs pertinents pour le contexte de branche actuel
- **Performance optimisée** : Algorithmes efficaces pour les grands dépôts

## Usage expert

### Marquage sur commits spécifiques

Marquez bugs et corrections sur n'importe quel commit, pas seulement HEAD :

```bash
# Marquer un bug sur un commit spécifique
gfm bug "Fuite mémoire" abc1234
gfm bug "Problème de sécurité" HEAD~3
gfm bug "Régression" v1.1.0

# Marquer une correction sur un commit spécifique
gfm fix BUG-20250921-A1B2 def5678
gfm fix BUG-20250921-A1B2 hotfix/security
```

### Cas d'usage typiques

**Audit de sécurité** : Marquer quand les vulnérabilités ont été introduites et où elles ont été corrigées
```bash
gfm bug "Injection SQL" v1.2.3
gfm fix BUG-20250921-A1B2 hotfix/sql-fix
```

**Analyse post-mortem** : Cartographier les bugs vers leurs commits de cause racine et toutes les corrections liées
```bash
gfm bug "Régression de performance" 89abc12
gfm fix BUG-20250921-YYYY commit-1
gfm fix BUG-20250921-YYYY commit-2
```

**Gestion de release** : S'assurer que les corrections critiques atteignent toutes les branches supportées
```bash
gfm check main                # Vérifier la branche de développement
gfm check release/v2.1        # Vérifier la branche de release
gfm check hotfix/critical     # Vérifier la branche de hotfix
```

## Intégration dans le workflow

### Développement quotidien
```bash
# Interface guidée pour débuter facilement
gfm
# → Choisir "Marquer un bug"
# → Entrer "Timeout d'authentification" 
# → Confirmer sur commit actuel

# Développer et commiter la correction
git commit -m "Fix auth timeout handling"
gfm
# → Choisir "Marquer une correction"
# → Sélectionner BUG-20250921-A1B2

# Vérifier avant merge
gfm check main
```

### Workflow d'équipe
```bash
# Développeur A identifie et marque un bug
gfm bug "Échec du refresh de token"

# Développeur B implémente la correction sur la branche feature
git checkout hotfix/oauth-fix
git commit -m "Fix token refresh logic"
gfm fix BUG-20250921-B8C9

# Release manager vérifie la branche de release
gfm check release/v2.1.0
# Rapporte les corrections manquantes nécessitant un cherry-pick
```

### Vérification pré-release
```bash
# Vérifier la branche actuelle
gfm check

# Vérifier une branche ou un tag spécifique
gfm check release/v2.1.0
gfm check v1.1.0
```

## Référence des commandes

| Commande | Raccourci | Description | Exemple |
|----------|-----------|-------------|---------|
| `gfm` | | Interface guidée | `gfm` |
| `gfm bug` | `gfm b` | Marquer un bug | `gfm bug "Fuite mémoire" [commit]` |
| `gfm fix` | `gfm f` | Marquer une correction | `gfm fix BUG-001 [commit]` |
| `gfm check` | `gfm c` | Vérifier les corrections | `gfm check release/v1.0` |
| `gfm list` | `gfm l` | Lister bugs/corrections | `gfm list bugs` |
| `gfm status` | `gfm s` | Statut du dépôt | `gfm status` |
| `gfm interactive` | `gfm i` | Mode interactif | `gfm interactive` |
| `gfm help` | `gfm h` | Aide contextuelle | `gfm help fix` |
| `gfm update` | | Vérifier les mises à jour | `gfm update` |

**Note** : Le paramètre `[commit]` est optionnel. S'il est omis, utilise HEAD (commit actuel).

## Méthodes de détection

Git Fix Manager utilise quatre heuristiques pour détecter les corrections cherry-pickées :

1. **Correspondance exacte de patch-id** : Compare le contenu des patchs avec git patch-id
2. **Similarité de titre** : Fait correspondre les patterns de messages de commit
3. **Corrélation de numéro PR** : Lie les commits via les références de pull requests
4. **Override manuel** : Marquage explicite quand la détection automatique échoue

Le système est optimisé pour minimiser les faux positifs tout en maintenant une haute précision de détection.

## Compatibilité

- **Linux** : Support natif
- **macOS** : Support natif
- **Windows** : Via WSL (Windows Subsystem for Linux)
- **Git** : Version 2.0 ou supérieure requise

## Documentation

- [Guide de suivi sur commits spécifiques](./docs/MARQUAGE-COMMITS-SPECIFIQUES.md)
- [Guide de contribution](./CONTRIBUTING.md)

## Contribution

Les contributions sont les bienvenues. Voir [CONTRIBUTING.md](./CONTRIBUTING.md) pour :

- Procédures de rapport de bugs
- Processus de demande de fonctionnalités
- Guidelines de contribution de code
- Améliorations de documentation

## Licence

Ce projet est sous licence [MIT](./LICENSE).