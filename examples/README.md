# Exemples d'utilisation du Script de Détection des Corrections Manquantes

Ce dossier contient plusieurs scripts d'exemple pour vous aider à comprendre et tester le système de détection des corrections manquantes.

## 📁 Scripts disponibles

### 1. `quick-test.sh` - Test rapide
**Utilisation :** Vérification rapide que le système fonctionne

```bash
cd examples
chmod +x quick-test.sh
./quick-test.sh
```

**Ce que fait ce script :**
- Vérifie que le script principal est accessible
- Initialise un repository Git si nécessaire
- Teste les commandes de base (mark-bug, mark-fix)
- Affiche les listes de bugs et corrections
- Valide le fonctionnement général

**Durée :** ~1 minute

### 2. `demo-scenario.sh` - Démonstration complète
**Utilisation :** Démonstration complète avec un scénario réaliste

```bash
cd examples
chmod +x demo-scenario.sh
./demo-scenario.sh
```

**Ce que fait ce script :**
- Crée un repository Git de démonstration complet
- Simule l'introduction de 2 bugs sur différents commits
- Crée une branche release avec les bugs
- Simule les corrections sur différentes branches (main, hotfix)
- Démontre la détection automatique des corrections manquantes
- Montre l'application des corrections avec cherry-pick
- Valide le résultat final

**Durée :** ~3-5 minutes

### 3. `real-world-example.sh` - Exemple réaliste
**Utilisation :** Guide interactif d'un cas d'usage réel

```bash
cd examples
chmod +x real-world-example.sh
./real-world-example.sh
```

**Ce que fait ce script :**
- Guide pas-à-pas d'une préparation de release
- Montre le workflow complet dans un contexte professionnel
- Explique les bonnes pratiques
- Présente les commandes dans l'ordre d'utilisation réelle
- Mode interactif (vous contrôlez le rythme)

**Durée :** ~5-10 minutes (selon votre rythme de lecture)

## 🚀 Utilisation recommandée

### Pour débuter
1. **Commencez par `quick-test.sh`** pour vérifier que tout fonctionne
2. **Continuez avec `demo-scenario.sh`** pour voir le système en action
3. **Terminez par `real-world-example.sh`** pour comprendre l'usage professionnel

### Pour la formation d'équipe
1. Utilisez `demo-scenario.sh` pour expliquer les concepts
2. Montrez `real-world-example.sh` pour le workflow quotidien
3. Laissez chaque membre tester avec `quick-test.sh`

## 📊 Comparaison des exemples

| Script | Objectif | Complexité | Durée | Repository |
|--------|----------|------------|-------|------------|
| `quick-test.sh` | Validation rapide | Faible | 1 min | Utilise l'existant ou crée minimal |
| `demo-scenario.sh` | Démonstration complète | Moyenne | 3-5 min | Crée un repository complet |
| `real-world-example.sh` | Formation/workflow | Élevée | 5-10 min | Guide théorique interactif |

## 🎯 Cas d'usage spécifiques

### Validation après installation
```bash
./quick-test.sh
```

### Démonstration à l'équipe
```bash
./demo-scenario.sh
```

### Formation nouveaux développeurs
```bash
./real-world-example.sh
```

### Debug/troubleshooting
Utilisez `demo-scenario.sh` pour recréer un environnement de test propre.

## 📝 Notes importantes

- **Permissions :** N'oubliez pas de rendre les scripts exécutables avec `chmod +x`
- **Git :** Les scripts gèrent automatiquement l'initialisation Git si nécessaire
- **Nettoyage :** `demo-scenario.sh` crée un sous-dossier `missing-fix-demo` qui peut être supprimé après usage
- **Isolation :** Chaque script fonctionne indépendamment des autres

## 🔧 Personnalisation

Vous pouvez modifier ces scripts pour :
- Adapter les exemples à votre contexte métier
- Changer les IDs de bugs pour correspondre à votre nomenclature
- Ajouter des scénarios spécifiques à votre workflow
- Intégrer dans vos outils de formation

## 🆘 En cas de problème

Si un script ne fonctionne pas :

1. **Vérifiez les permissions :**
   ```bash
   chmod +x *.sh
   ```

2. **Vérifiez le chemin du script principal :**
   ```bash
   ls -la ../scripts/missing-fix-detector.sh
   ```

3. **Vérifiez Git :**
   ```bash
   git --version
   ```

4. **Exécutez en mode debug :**
   ```bash
   bash -x ./demo-scenario.sh
   ```

## 💡 Prochaines étapes

Après avoir testé les exemples :
1. Utilisez `gfm check` régulièrement avant vos pushs
2. Appliquez le système à votre repository réel
3. Formez votre équipe avec ces exemples
4. Intégrez `gfm check` dans votre workflow CI/CD