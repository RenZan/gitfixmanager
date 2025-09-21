# Tests Git Fix Manager

Suite de tests pour valider le fonctionnement de Git Fix Manager.

## Tests principaux

- `test-final.sh` - Test complet de validation
- `test-gfm-interface.sh` - Test de l'interface gfm
- `run-detector-tests.sh` - Exécute tous les tests du détecteur

## Tests du détecteur

- `detector-basic.sh` - Fonctionnalités de base
- `detector-aggressive-detection.sh` - Prévention des faux positifs
- `detector-branch-filter.sh` - Filtrage par branche
- `detector-patch-id.sh` - Détection patch-id
- `detector-performance.sh` - Tests de performance
- `detector-limit-enforcement.sh` - Respect des limites
- `detector-consistency.sh` - Cohérence des résultats
- `detector-negative.sh` - Cas d'échec attendus
- `detector-multi-bug.sh` - Bugs multiples
- `detector-propagation.sh` - Propagation inter-branches
- `detector-retroactive.sh` - Marquage rétroactif
- `detector-pr-heuristic.sh` - Heuristique PR
- `detector-no-cherry-scan.sh` - Désactivation scan cherry-pick
- `detector-generic-filter.sh` - Filtres génériques

## Tests spécialisés

- `test-demo-fix.sh` - Démonstration problème héritage massif
- `test-auto-ci.sh` - Tests automatisés CI/CD
- `test-edge-cases.sh` - Cas limites
- `test-simple-inheritance.sh` - Héritage simple
- `test-massive-inheritance.sh` - Héritage massif

## Utilisation

```bash
# Tous les tests
bash tests/run-detector-tests.sh

# Test spécifique
bash tests/detector-basic.sh
```

**Ce qu'il fait :**
- Tests automatisés avec exit codes
- Validation de performance (<30s)
- Tests de régression
- Génère un rapport `last_auto_test_report.txt`

### `test-edge-cases.sh` - 🔬 Cas Limites
**Usage pour validation approfondie**

```bash
wsl -e bash tests/test-edge-cases.sh
```

**Ce qu'il teste :**
- Méthode 1: Références directes aux commits
- Méthode 2: Filtrage des titres génériques
- Méthode 3: Validation des numéros PR

### `test-massive-inheritance.sh` - 📊 Test Complet
**Usage pour comparaison avant/après**

```bash
wsl -e bash tests/test-massive-inheritance.sh
```

**Ce qu'il fait :**
- Compare code buggy vs code corrigé
- Simule l'héritage massif
- Mesure les performances

### `test-simple-inheritance.sh` - ⚡ Test Rapide
**Usage pour validation rapide**

```bash
wsl -e bash tests/test-simple-inheritance.sh
```

**Ce qu'il fait :**
- Version simplifiée du test principal
- Focus sur la démonstration du fix
- Plus robuste contre les erreurs de parsing

## 🎉 Résultats de Validation

### ✅ Tests Réussis

Tous les tests confirment que le fix fonctionne :

1. **Héritage massif éliminé** : Limitation à 5 résultats max
2. **Alertes actives** : `🚨 ALERTE: X cherry-picks détectés - Limitation à 3`
3. **Performance acceptable** : <30s pour analyses complètes
4. **Détection préservée** : Les cas légitimes fonctionnent toujours

### 📊 Métriques Typiques

```
AVANT le fix:
• Héritage: 800+ commits (massif)
• Performance: Timeout (>60s)
• Utilisabilité: 0% (bloqué)

APRÈS le fix:
• Héritage: 3-10 commits (contrôlé)
• Performance: <30s
• Utilisabilité: 100% (fonctionnel)
```

## 🔧 Corrections Implémentées

### 1. Limitation Globale
```bash
MAX_RESULTS=5  # Maximum par commit original
```

### 2. Méthode 2 - Filtrage Titres
```bash
# Exclure si titre < 20 caractères
# Exclure préfixes génériques (Fix, Update, etc.)
# Exclure si < 3 mots
```

### 3. Méthode 3 - Numéros PR Stricts
```bash
# AVANT: grep "$pr_number" (permissif)
# APRÈS: grep "Merged PR \b$pr\b:" (strict)
# Minimum 3 chiffres requis
```

## 🚀 Usage en CI/CD

Pour intégrer dans votre pipeline :

```yaml
test:
  script:
    - cd git-fix-manager
    - wsl -e bash tests/test-auto-ci.sh
  artifacts:
    reports:
      - tests/last_auto_test_report.txt
```

## 📋 Validation Manuelle

Pour tester rapidement :

```bash
# Test principal (recommandé)
wsl -e bash tests/test-demo-fix.sh

# Vérifier les alertes dans la sortie :
# 🚨 ALERTE: X cherry-picks détectés - Limitation à 3
```

## 🎯 Critères de Succès

Un test est considéré comme réussi si :

- ✅ Alertes de limitation déclenchées
- ✅ Temps d'exécution < 30s
- ✅ Nombre de bugs détectés < 50
- ✅ Aucun timeout

## 📚 Documentation

- `RAPPORT-VALIDATION-FIX.md` : Rapport complet de validation
- Logs de test sauvegardés dans `/tmp/gfm-*-test/`
- Rapports automatiques : `last_auto_test_report.txt`

## 🐛 En Cas de Problème

Si les tests échouent :

1. Vérifier que WSL est fonctionnel
2. S'assurer que git est installé dans WSL
3. Vérifier les permissions d'exécution
4. Consulter les logs détaillés dans `/tmp/`

## 📧 Support

En cas de problème avec les tests, vérifier :
- La version de Git Fix Manager
- L'état du fichier `scripts/missing-fix-detector.sh`
- Les logs de test détaillés

---

**Dernière validation :** 19 septembre 2025  
**Status :** ✅ Tous tests passent  
**Mainteneur :** RenZan