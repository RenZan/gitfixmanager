#!/bin/bash

# Git Fix Manager - Installation One-liner
# Usage: curl -fsSL https://raw.githubusercontent.com/RenZan/gitfixmanager/main/install.sh | bash

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Git Fix Manager - Installation rapide${NC}"
echo "=============================================="

# Vérifications préliminaires
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git n'est pas installé${NC}"
    exit 1
fi

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    echo -e "${RED}❌ curl ou wget requis pour l'installation${NC}"
    exit 1
fi

# Détection de l'OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
    OS="wsl"
else
    echo -e "${YELLOW}⚠️ OS non détecté, tentative d'installation générique${NC}"
    OS="linux"
fi

echo -e "${BLUE}📍 OS détecté: $OS${NC}"

# Répertoires d'installation
INSTALL_DIR="$HOME/.local/share/gfm"
BIN_DIR="$HOME/.local/bin"

# Créer les répertoires
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

echo -e "${BLUE}📁 Installation dans: $INSTALL_DIR${NC}"

# Télécharger les fichiers principaux
echo -e "${BLUE}📥 Téléchargement des fichiers...${NC}"

BASE_URL="https://raw.githubusercontent.com/RenZan/gitfixmanager/main"

# Télécharger gfm
if command -v curl &> /dev/null; then
    curl -fsSL "$BASE_URL/gfm" -o "$BIN_DIR/gfm"
    curl -fsSL "$BASE_URL/scripts/missing-fix-detector.sh" -o "$INSTALL_DIR/missing-fix-detector.sh"
    curl -fsSL "$BASE_URL/scripts/git-bug" -o "$BIN_DIR/git-bug"
    curl -fsSL "$BASE_URL/scripts/git-fix" -o "$BIN_DIR/git-fix"
    curl -fsSL "$BASE_URL/scripts/git-bugcheck" -o "$BIN_DIR/git-bugcheck"
else
    wget -q "$BASE_URL/gfm" -O "$BIN_DIR/gfm"
    wget -q "$BASE_URL/scripts/missing-fix-detector.sh" -O "$INSTALL_DIR/missing-fix-detector.sh"
    wget -q "$BASE_URL/scripts/git-bug" -O "$BIN_DIR/git-bug"
    wget -q "$BASE_URL/scripts/git-fix" -O "$BIN_DIR/git-fix"
    wget -q "$BASE_URL/scripts/git-bugcheck" -O "$BIN_DIR/git-bugcheck"
fi

# Créer le répertoire scripts et faire le lien
mkdir -p "$INSTALL_DIR/scripts"
cp "$INSTALL_DIR/missing-fix-detector.sh" "$INSTALL_DIR/scripts/"

# Rendre exécutable
chmod +x "$BIN_DIR/gfm"
chmod +x "$BIN_DIR/git-bug"
chmod +x "$BIN_DIR/git-fix"
chmod +x "$BIN_DIR/git-bugcheck"
chmod +x "$INSTALL_DIR/scripts/missing-fix-detector.sh"

# Modifier gfm pour pointer vers la bonne installation
sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=\"$INSTALL_DIR\"|" "$BIN_DIR/gfm"

# Ajouter au PATH si nécessaire
PATH_ADDED=false
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}📝 Ajout de $BIN_DIR au PATH...${NC}"
    
    # Détecter le shell
    SHELL_RC=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.profile"
    fi
    
    if [[ -f "$SHELL_RC" ]]; then
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
        PATH_ADDED=true
        echo -e "${GREEN}✅ PATH ajouté à $SHELL_RC${NC}"
    fi
fi

# Test de l'installation
echo -e "${BLUE}🧪 Test de l'installation...${NC}"
if "$BIN_DIR/gfm" --version &> /dev/null; then
    echo -e "${GREEN}✅ Installation réussie !${NC}"
else
    echo -e "${RED}❌ Erreur lors du test${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Git Fix Manager installé avec succès !${NC}"
echo "=========================================="
echo -e "${BLUE}📍 Emplacement: $BIN_DIR/gfm${NC}"
echo -e "${BLUE}🚀 Utilisation:${NC}"

if [[ ":$PATH:" == *":$BIN_DIR:"* ]] || [[ "$PATH_ADDED" == true ]]; then
    echo -e "   ${GREEN}gfm help${NC}                 # Aide"
    echo -e "   ${GREEN}gfm bug \"Description\"${NC}    # Marquer un bug"
    echo -e "   ${GREEN}gfm fix BUG-ID${NC}           # Marquer une correction"
    echo -e "   ${GREEN}gfm check${NC}                # Vérifier corrections"
    echo ""
    echo -e "${BLUE}🎯 Commandes Git natives:${NC}"
    echo -e "   ${GREEN}git bug${NC}                  # Mode interactif"
    echo -e "   ${GREEN}git bug \"Description\"${NC}    # Marquer un bug"
    echo -e "   ${GREEN}git fix BUG-ID${NC}           # Marquer une correction"
    echo -e "   ${GREEN}git bugcheck${NC}             # Vérifier corrections"
    
    if [[ "$PATH_ADDED" == true ]]; then
        echo ""
        echo -e "${YELLOW}💡 Redémarrez votre terminal ou exécutez:${NC}"
        echo -e "   ${YELLOW}source $SHELL_RC${NC}"
    fi
else
    echo -e "   ${YELLOW}$BIN_DIR/gfm help${NC}        # Aide"
    echo -e "   ${YELLOW}$BIN_DIR/gfm bug \"Desc\"${NC}  # Marquer un bug"
    echo ""
    echo -e "${YELLOW}💡 Pour utiliser 'gfm' directement, ajoutez à votre PATH:${NC}"
    echo -e "   ${YELLOW}export PATH=\"$BIN_DIR:\$PATH\"${NC}"
fi

echo ""
echo -e "${BLUE}📚 Documentation: https://github.com/RenZan/gitfixmanager${NC}"
echo -e "${GREEN}🌟 Prêt à utiliser ! Objectif: Zero correction manquante !${NC}"