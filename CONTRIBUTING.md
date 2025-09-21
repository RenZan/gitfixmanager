# Contributing to Git Fix Manager

Merci de votre intérêt pour Git Fix Manager ! Nous accueillons les contributions de la communauté.

## 🚀 Comment Contribuer

### 1. Problèmes et Suggestions
- 🐛 **Bugs** : Utilisez les [Issues GitHub](https://github.com/RenZan/gitfixmanager/issues)
- 💡 **Suggestions** : Proposez vos idées via les Issues
- 📖 **Documentation** : Améliorations bienvenues

### 2. Pull Requests

#### Avant de Commencer
1. Fork le repository
2. Créez une branche feature : `git checkout -b feature/ma-fonctionnalité`
3. Testez vos modifications : `./test-final.sh`

#### Standards de Code
- **Scripts Bash** : Suivre les conventions POSIX
- **Documentation** : Mettre à jour README.md si nécessaire
- **Tests** : Ajouter tests pour nouvelles fonctionnalités

#### Processus de Review
1. Créez la Pull Request
2. Décrivez clairement les changements
3. Assurez-vous que tous les tests passent
4. Répondez aux commentaires de review

### 3. Structure du Projet

```
gitfixmanager/
├── gfm                          # Interface principale
├── scripts/
│   └── missing-fix-detector.sh  # Moteur de détection
├── hooks/
│   └── pre-push                 # Hook Git
├── examples/                    # Exemples et démos
├── docs/                        # Documentation supplémentaire
└── tests/                       # Scripts de test
```

### 4. Tests

Avant de soumettre :
```bash
# Tests complets
./test-final.sh

# Tests d'intégration
./test-final.sh --integration

# Test manuel de l'interface
./gfm help
./gfm interactive
```

### 5. Style de Commit

Utilisez des messages clairs :
```
feat: Add support for custom bug ID formats
fix: Resolve issue with WSL compatibility
docs: Update installation instructions
test: Add tests for commit-specific bug marking
```

### 6. Versions et Releases

- **Versions** : Semantic Versioning (semver.org)
- **Changelog** : Documenté dans les releases GitHub
- **Compatibilité** : Maintenue entre versions mineures

## 🛡️ Code de Conduite

### Nos Standards
- 🤝 Respect et bienveillance
- 🎯 Focus sur les améliorations constructives
- 💬 Communication claire et professionnelle
- 🌍 Ouverture à la diversité des approches

### Comportements Attendus
- Utiliser un langage accueillant et inclusif
- Respecter les points de vue différents
- Accepter les critiques constructives
- Se concentrer sur l'amélioration du projet

### Signalement
Signalez tout comportement inapproprié via :
- Issues GitHub (public)
- Email direct au mainteneur (privé)

## 🎯 Domaines de Contribution Prioritaires

### Développement
- 🔧 **Nouvelles fonctionnalités** : Auto-détection avancée, intégrations CI/CD
- 🐛 **Corrections de bugs** : Compatibilité multi-plateformes
- ⚡ **Performance** : Optimisation des opérations Git

### Documentation
- 📚 **Guides d'usage** : Cas d'usage spécifiques
- 🎥 **Tutoriels** : Vidéos ou guides step-by-step
- 🌐 **Traductions** : Documentation en autres langues

### Tests et Qualité
- 🧪 **Tests automatisés** : Couverture étendue
- 🔍 **Outils de qualité** : Linting, analyse statique
- 📊 **Benchmarks** : Performance et fiabilité

## 💡 Idées de Contributions

### Fonctionnalités Demandées
- [ ] Support des templates de bug personnalisés
- [ ] Intégration avec JIRA/GitHub Issues
- [ ] Dashboard web pour visualisation
- [ ] Plugin VS Code
- [ ] API REST pour intégrations

### Améliorations UX
- [ ] Auto-complétion Bash/Zsh
- [ ] Mode verbose/quiet
- [ ] Configuration per-repository
- [ ] Notifications desktop

## 📞 Support et Questions

### Où Obtenir de l'Aide
- 📖 **Documentation** : README.md et docs/
- 💬 **Discussions** : GitHub Discussions
- 🐛 **Issues** : Pour bugs et questions techniques

### Réponses Rapides
- Issues techniques : < 48h
- Pull requests : < 72h  
- Questions générales : < 1 semaine

---

**Merci de contribuer à Git Fix Manager ! Ensemble, nous rendons la gestion des bugs plus simple et plus efficace.** 🚀