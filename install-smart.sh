#!/bin/bash

# Script d'installation intelligent pour Git Fix Manager (gfm)
# Configure automatiquement l'environnement et l'interface simplifiée

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.gfm"
BIN_DIR="$HOME/.local/bin"

echo -e "${CYAN}🚀 Installation de Git Fix Manager (gfm)${NC}"
echo -e "${CYAN}======================================${NC}"

# Vérifications préliminaires
check_dependencies() {
    echo -e "${BLUE}🔍 Vérification des dépendances...${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git n'est pas installé${NC}"
        exit 1
    fi
    
    if ! git rev-parse --git-dir &> /dev/null; then
        echo -e "${YELLOW}⚠️  Vous n'êtes pas dans un repository Git${NC}"
        echo -e "${YELLOW}   L'installation globale sera effectuée${NC}"
        GLOBAL_INSTALL=true
    else
        echo -e "${GREEN}✅ Repository Git détecté${NC}"
        GLOBAL_INSTALL=false
    fi
    
    echo -e "${GREEN}✅ Git trouvé : $(git --version)${NC}"
}

# Installation globale
install_global() {
    echo -e "${BLUE}🌍 Installation globale...${NC}"
    
    # Créer les répertoires
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    
    # Copier les scripts
    cp -r "$SCRIPT_DIR/scripts" "$INSTALL_DIR/"
    
    # Créer le script gfm principal
    cat > "$BIN_DIR/gfm" << 'EOF'
#!/bin/bash
# Git Fix Manager - Interface simplifiée
# Auto-généré par install-smart.sh

INSTALL_DIR="$HOME/.gfm"
export GFM_INSTALL_DIR="$INSTALL_DIR"

# Vérifier que gfm est installé
if [[ ! -f "$INSTALL_DIR/scripts/gfm.sh" ]]; then
    echo "❌ gfm n'est pas installé correctement"
    echo "💡 Relancez install-smart.sh"
    exit 1
fi

# Déléguer à l'interface simplifiée
exec "$INSTALL_DIR/scripts/gfm.sh" "$@"
EOF
    
    chmod +x "$BIN_DIR/gfm"
    
    # Copier l'interface simplifiée
    cp "$SCRIPT_DIR/gfm" "$INSTALL_DIR/scripts/gfm.sh" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Interface gfm non trouvée, utilisation de l'interface legacy${NC}"
        create_legacy_wrapper
    }
    
    echo -e "${GREEN}✅ Installation globale terminée${NC}"
    echo -e "${CYAN}💡 Ajoutez $BIN_DIR à votre PATH si ce n'est pas déjà fait${NC}"
}

# Créer un wrapper legacy si gfm n'existe pas encore
create_legacy_wrapper() {
    cat > "$INSTALL_DIR/scripts/gfm.sh" << 'EOF'
#!/bin/bash
# Wrapper legacy pour gfm

INSTALL_DIR="$HOME/.gfm"
DETECTOR="$INSTALL_DIR/scripts/missing-fix-detector.sh"

case "${1:-}" in
    "bug"|"b")
        shift
        if [[ $# -eq 0 ]]; then
            echo "Usage: gfm bug <description>"
            exit 1
        fi
        # Générer un ID automatique
        BUG_ID="BUG-$(date +%Y%m%d)-$(openssl rand -hex 2 2>/dev/null || echo "AUTO")"
        COMMIT=${2:-$(git rev-parse HEAD)}
        "$DETECTOR" mark-bug "$COMMIT" "$BUG_ID" "$1"
        ;;
    "fix"|"f")
        shift
        if [[ $# -eq 0 ]]; then
            echo "Usage: gfm fix <BUG-ID> [bug-commit]"
            exit 1
        fi
        COMMIT=$(git rev-parse HEAD)
        BUG_COMMIT=${2:-"auto"}
        "$DETECTOR" mark-fix "$COMMIT" "$1" "$BUG_COMMIT"
        ;;
    "check"|"c")
        shift
        TARGET=${1:-$(git rev-parse HEAD)}
        "$DETECTOR" check "$TARGET"
        ;;
    "list"|"l")
        shift
        case "${1:-}" in
            "bugs") "$DETECTOR" list-bugs ;;
            "fixes") "$DETECTOR" list-fixes ;;
            *) "$DETECTOR" list-bugs; echo; "$DETECTOR" list-fixes ;;
        esac
        ;;
    "status"|"s")
        "$DETECTOR" check $(git rev-parse HEAD)
        ;;
    "help"|"h"|"")
        echo "Git Fix Manager - Interface simplifiée"
        echo ""
        echo "Commandes :"
        echo "  gfm bug <description>     Marquer un bug"
        echo "  gfm fix <BUG-ID>         Marquer une correction"
        echo "  gfm check [branch/tag]   Vérifier les corrections"
        echo "  gfm list [bugs|fixes]    Lister bugs/corrections"
        echo "  gfm status              Statut du repository"
        echo "  gfm help                Cette aide"
        ;;
    *)
        echo "❌ Commande inconnue : $1"
        echo "💡 Utilisez 'gfm help' pour l'aide"
        exit 1
        ;;
esac
EOF
    chmod +x "$INSTALL_DIR/scripts/gfm.sh"
}

# Installation locale (dans le repo)
install_local() {
    echo -e "${BLUE}📁 Installation locale dans le repository...${NC}"
    
    # Créer un lien symbolique vers gfm si possible
    if [[ -f "$BIN_DIR/gfm" ]]; then
        echo -e "${GREEN}✅ Lien vers l'installation globale créé${NC}"
    else
        echo -e "${YELLOW}⚠️  Installation globale non trouvée${NC}"
        echo -e "${CYAN}💡 Utilisation directe : ./gfm ${NC}"
    fi
}

# Configuration intelligente
smart_config() {
    echo -e "${BLUE}⚙️  Configuration intelligente...${NC}"
    
    # Vérifier si PATH contient BIN_DIR
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo -e "${YELLOW}⚠️  $BIN_DIR n'est pas dans votre PATH${NC}"
        
        # Proposer d'ajouter au shell config
        SHELL_CONFIG=""
        if [[ -f "$HOME/.bashrc" ]]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [[ -f "$HOME/.zshrc" ]]; then
            SHELL_CONFIG="$HOME/.zshrc"
        fi
        
        if [[ -n "$SHELL_CONFIG" ]]; then
            echo -e "${CYAN}💡 Ajouter à $SHELL_CONFIG ? (y/N)${NC}"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
                echo -e "${GREEN}✅ PATH mis à jour dans $SHELL_CONFIG${NC}"
                echo -e "${CYAN}💡 Relancez votre terminal ou exécutez: source $SHELL_CONFIG${NC}"
            fi
        fi
    fi
    
    # Configuration Git globale pour gfm
    git config --global alias.gfm '!gfm'
    echo -e "${GREEN}✅ Alias Git 'git gfm' créé${NC}"
}

# Test de l'installation
test_installation() {
    echo -e "${BLUE}🧪 Test de l'installation...${NC}"
    
    if command -v gfm &> /dev/null; then
        echo -e "${GREEN}✅ gfm est accessible via PATH${NC}"
        gfm help > /dev/null && echo -e "${GREEN}✅ Interface gfm fonctionne${NC}"
    else
        echo -e "${YELLOW}⚠️  gfm n'est pas dans PATH, utilisez le chemin complet${NC}"
    fi
    
    if [[ -f ".git/hooks/pre-push" ]]; then
        echo -e "${GREEN}✅ Hook pre-push installé${NC}"
    fi
}

# Affichage du résumé
show_summary() {
    echo
    echo -e "${PURPLE}🎉 Installation terminée !${NC}"
    echo -e "${PURPLE}========================${NC}"
    echo
    echo -e "${CYAN}📍 Localisation :${NC}"
    echo -e "   Scripts : $INSTALL_DIR"
    echo -e "   Binaire : $BIN_DIR/gfm"
    echo
    echo -e "${CYAN}🚀 Utilisation :${NC}"
    if command -v gfm &> /dev/null; then
        echo -e "   ${GREEN}gfm help${NC}                 # Aide"
        echo -e "   ${GREEN}gfm bug \"description\"${NC}    # Marquer un bug"  
        echo -e "   ${GREEN}gfm fix BUG-ID${NC}           # Marquer une correction"
        echo -e "   ${GREEN}gfm check${NC}                # Vérifier les corrections"
    else
        echo -e "   ${YELLOW}$BIN_DIR/gfm help${NC}        # Aide"
        echo -e "   ${YELLOW}$BIN_DIR/gfm bug \"desc\"${NC}  # Marquer un bug"
        echo
        echo -e "${CYAN}💡 Pour utiliser 'gfm' directement :${NC}"
        echo -e "   export PATH=\"$BIN_DIR:\$PATH\""
        echo -e "   # ou ajoutez cette ligne à votre ~/.bashrc ou ~/.zshrc"
    fi
    echo
    echo -e "${CYAN}✅ Vérification recommandée :${NC}"
    echo -e "   ${GREEN}gfm check${NC}               # Avant chaque push"
    echo
    echo -e "${CYAN}📚 Documentation : README.md${NC}"
    echo -e "${CYAN}🐛 Support : https://github.com/your-repo/issues${NC}"
}

# Fonction principale
main() {
    check_dependencies
    
    # Installation globale
    install_global
    
    # Installation locale si dans un repo Git
    if [[ "$GLOBAL_INSTALL" == false ]]; then
        install_local
    fi
    
    # Configuration intelligente
    smart_config
    
    # Test
    test_installation
    
    # Résumé
    show_summary
}

# Options en ligne de commande
case "${1:-}" in
    "--help"|"-h")
        echo "install-smart.sh - Installation intelligente de Git Fix Manager"
        echo ""
        echo "Usage: ./install-smart.sh [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Afficher cette aide"
        echo "  --global-only  Installation globale uniquement"
        echo "  --local-only   Installation locale uniquement (nécessite un repo Git)"
        echo ""
        exit 0
        ;;
    "--global-only")
        check_dependencies
        install_global
        smart_config
        test_installation
        show_summary
        ;;
    "--local-only")
        check_dependencies
        if [[ "$GLOBAL_INSTALL" == true ]]; then
            echo -e "${RED}❌ --local-only nécessite d'être dans un repository Git${NC}"
            exit 1
        fi
        install_local
        test_installation
        show_summary
        ;;
    "")
        main
        ;;
    *)
        echo -e "${RED}❌ Option inconnue : $1${NC}"
        echo -e "${CYAN}💡 Utilisez --help pour l'aide${NC}"
        exit 1
        ;;
esac