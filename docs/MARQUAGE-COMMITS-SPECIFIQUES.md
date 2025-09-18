# 🎯 Nouveau : Marquage de Bugs sur N'importe Quel Commit

## ✨ Fonctionnalité Ajoutée

Vous pouvez maintenant marquer un bug sur **n'importe quel commit**, pas seulement le commit actuel (HEAD) !

## 📝 Syntaxes Supportées

### 1. Sur le commit actuel (comportement par défaut)
```bash
gfm bug "Memory leak detected"
```

### 2. Sur un commit spécifique par hash
```bash
gfm bug "Bug in authentication" abc1234
gfm bug "Performance issue" a1b2c3d4e5f6
```

### 3. Sur un commit par référence relative
```bash
gfm bug "Error in previous version" HEAD~1
gfm bug "Bug from 3 commits ago" HEAD~3
gfm bug "Issue in parent commit" main~2
```

### 4. Sur un tag ou une branche
```bash
gfm bug "Critical bug in release" v1.0.0
gfm bug "Bug in feature branch" feature/auth
gfm bug "Problem in main" main
```

## 🖥️ Mode Interactif Amélioré

Le mode interactif vous guide maintenant :

```bash
gfm interactive

# → Sélectionnez "1) Marquer un bug"
# → Entrez la description
# → Choisissez le commit :
#   1) Commit actuel (HEAD)
#   2) Autre commit (hash, branche, tag)
```

## ✅ Validation Automatique

- ✅ **Commit valide** : Marque sur le commit spécifié
- ❌ **Commit invalide** : Traite comme partie de la description et marque sur HEAD
- 🔍 **Auto-détection** : Reconnaît automatiquement les hashs, branches, tags

## 📋 Exemples Pratiques

### Marquer un bug ancien découvert
```bash
# Vous venez de découvrir un bug dans un commit d'il y a 5 jours
git log --oneline | head -10
# abc1234 Fix user login
# def5678 Add payment processing  ← Bug ici !

gfm bug "Payment fails with special characters" def5678
```

### Marquer un bug dans une release
```bash
# Bug découvert dans la version 1.0
gfm bug "Critical security issue" v1.0.0
```

### Marquer un bug dans une autre branche
```bash
# Bug dans la branche de développement
gfm bug "Memory leak in dev branch" develop
```

## 🔍 Vérification

Après marquage, vous pouvez vérifier :

```bash
gfm list bugs
# Affiche tous les bugs avec leurs commits respectifs

gfm check v1.0.0
# Vérifie les corrections manquantes dans v1.0.0
```

## 💡 Cas d'Usage Typiques

### 1. **Revue de Code Rétrospective**
```bash
# Lors d'une revue, vous découvrez des bugs dans des commits passés
gfm bug "SQL injection vulnerability" commit-hash
```

### 2. **Analyse de Release**
```bash
# Marquer des bugs trouvés dans une release déployée
gfm bug "Performance degradation" v2.1.0
```

### 3. **Debug de Régression**
```bash
# Identifier quand un bug a été introduit
git bisect start
# ... après bisect ...
gfm bug "Regression introduced here" HEAD~5
```

### 4. **Hotfix Planning**
```bash
# Marquer des bugs dans main pour planifier un hotfix
gfm bug "Critical bug needs hotfix" main
```

## 🚀 Workflow Complet

```bash
# 1. Identifier le commit problématique
git log --oneline -10

# 2. Marquer le bug sur ce commit
gfm bug "Description du bug" commit-hash

# 3. Développer la correction
git checkout -b fix/bug-description
# ... développement ...
git commit -m "Fix: bug description"

# 4. Marquer la correction
gfm fix BUG-ID

# 5. Vérifier avant merge
gfm check main
```

## ⚡ Raccourcis

```bash
# Toutes ces commandes supportent les commits spécifiques :
gfm b "Bug description" commit-hash      # Raccourci pour bug
gfm bug "Description" HEAD~2            # Référence relative
gfm bug "Issue" $(git rev-parse HEAD~1) # Hash résolu
```

---

**💡 Cette fonctionnalité rend Git Fix Manager beaucoup plus flexible pour le marquage rétrospectif de bugs !**