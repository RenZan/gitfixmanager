# Guide de suivi sur commits spécifiques

## Principe technique

Git Fix Manager permet de marquer bugs et corrections sur **n'importe quel commit**, en utilisant les **notes Git** pour stocker les informations directement dans le dépôt.

```bash
# Stockage via notes Git
git notes --ref=refs/notes/bugs add -m "BUG-ID|Description" <commit>
git notes --ref=refs/notes/fixes add -m "BUG-ID" <commit>
```

## Syntaxes supportées

### 1. Commit actuel (défaut)
```bash
gfm bug "Fuite mémoire détectée"
gfm fix BUG-20250921-A1B2
```

### 2. Commit spécifique par hash
```bash
gfm bug "Bug dans l'authentification" abc1234
gfm fix BUG-20250921-A1B2 def5678
```

### 3. Références relatives
```bash
gfm bug "Erreur dans version précédente" HEAD~1
gfm bug "Bug il y a 3 commits" HEAD~3
gfm fix BUG-20250921-A1B2 main~2
```

### 4. Tags et branches
```bash
gfm bug "Bug critique en release" v1.0.0
gfm bug "Problème sur branche feature" feature/auth
gfm fix BUG-20250921-A1B2 hotfix/security
```

## Mode interactif

Le mode interactif guide l'utilisateur :

```bash
gfm interactive

# Workflow guidé :
# 1. Choisir l'action (bug/fix)
# 2. Entrer la description ou BUG-ID
# 3. Sélectionner le commit cible
```

## Validation

- **Commit existant** : Vérifie que le commit existe dans le dépôt
- **Résolution automatique** : Résout les références Git (branches, tags, HEAD~n)
- **Commit invalide** : Traité comme partie de la description, marqué sur HEAD
- **Auto-détection** : Reconnaissance automatique des hashs, branches, tags

## Exemples pratiques

### Audit de sécurité
```bash
# Marquer une vulnérabilité découverte dans une ancienne version
gfm bug "Injection SQL dans login" v1.2.3

# Puis marquer la correction développée
gfm fix BUG-20250921-A1B2 hotfix/sql-security
```

### Analyse post-mortem
```bash
# Identifier le commit qui a introduit un bug
git log --oneline -10
gfm bug "Régression de performance" abc1234

# Lier toutes les corrections associées
gfm fix BUG-20250921-A1B2 fix-commit-1
gfm fix BUG-20250921-A1B2 fix-commit-2
```

### Gestion de release
```bash
# Vérifier qu'un bug de production a bien été corrigé sur toutes les branches
gfm bug "Bug critique production" v2.0.0
gfm fix BUG-20250921-A1B2 main
gfm check release/v2.1.0  # Vérifier si correction présente
```

## Vérification et suivi

### Lister les bugs par commit
```bash
gfm list bugs
# Affiche : BUG-ID | Description | Commit | Date
```

### Vérifier les corrections manquantes
```bash
gfm check main           # Branche principale
gfm check release/v2.1   # Branche de release
gfm check v1.0.0         # Tag spécifique
```

### Inspecter les notes Git directement
```bash
# Voir les bugs sur un commit
git notes --ref=refs/notes/bugs show abc1234

# Voir les corrections sur un commit
git notes --ref=refs/notes/fixes show def5678
```

## Workflow type

```bash
# 1. Identifier le commit problématique
git log --oneline --grep="feature" -5

# 2. Marquer le bug sur ce commit
gfm bug "Fuite mémoire dans nouvelle feature" abc1234

# 3. Développer la correction
git checkout -b fix/memory-leak
git commit -m "Fix: memory leak in feature"

# 4. Lier la correction au bug
gfm fix BUG-20250921-A1B2

# 5. Vérifier avant merge
gfm check main
```

Ce système garantit une traçabilité complète des bugs et corrections à travers l'historique Git.
gfm bug "Description" HEAD~2            # Référence relative
gfm bug "Issue" $(git rev-parse HEAD~1) # Hash résolu
```

---

**💡 Cette fonctionnalité rend Git Fix Manager beaucoup plus flexible pour le marquage rétrospectif de bugs !**