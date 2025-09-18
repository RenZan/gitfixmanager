#!/bin/bash

# Script de validation pour publication GitHub
# Vérifie que le projet est prêt pour publication

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}🔍 Validation pour Publication GitHub${NC}"
echo -e "${CYAN}====================================${NC}"

ISSUES=0

# Vérification de la structure
echo -e "${BLUE}📁 Structure du projet...${NC}"

required_files=(
    "README.md"
    "LICENSE" 
    "CONTRIBUTING.md"
    "CHANGELOG.md"
    ".gitignore"
    "gfm"
    "install-smart.sh"
    "scripts/missing-fix-detector.sh"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "  ${GREEN}✅ $file${NC}"
    else
        echo -e "  ${RED}❌ $file manquant${NC}"
        ((ISSUES++))
    fi
done

required_dirs=(
    "docs"
    "examples" 
    "tests"
    "scripts"
)

for dir in "${required_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        echo -e "  ${GREEN}✅ $dir/${NC}"
    else
        echo -e "  ${RED}❌ $dir/ manquant${NC}"
        ((ISSUES++))
    fi
done

# Vérification des liens GitHub
echo -e "${BLUE}🔗 Liens GitHub...${NC}"

github_files=("README.md" "gfm" "CONTRIBUTING.md")
for file in "${github_files[@]}"; do
    if grep -q "RenZan/gitfixmanager" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✅ $file contient les bons liens GitHub${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $file pourrait nécessiter une mise à jour des liens${NC}"
    fi
done

# Vérification de la syntaxe des scripts
echo -e "${BLUE}🔍 Syntaxe des scripts...${NC}"

scripts=("gfm" "install-smart.sh" "scripts/missing-fix-detector.sh")
for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        if bash -n "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✅ $script syntaxe OK${NC}"
        else
            echo -e "  ${RED}❌ $script erreur de syntaxe${NC}"
            ((ISSUES++))
        fi
    fi
done

# Vérification des permissions
echo -e "${BLUE}🔐 Permissions...${NC}"

executable_files=("gfm" "install-smart.sh")
for file in "${executable_files[@]}"; do
    if [[ -x "$file" ]]; then
        echo -e "  ${GREEN}✅ $file exécutable${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $file non exécutable (sera corrigé sur GitHub)${NC}"
    fi
done

# Vérification du contenu
echo -e "${BLUE}📝 Contenu...${NC}"

# Vérifier que README contient les sections essentielles
readme_sections=("Installation" "Utilisation" "License" "Contributing")
for section in "${readme_sections[@]}"; do
    if grep -i "$section" README.md >/dev/null; then
        echo -e "  ${GREEN}✅ README contient section '$section'${NC}"
    else
        echo -e "  ${YELLOW}⚠️  README pourrait manquer section '$section'${NC}"
    fi
done

# Vérifier version cohérente
if grep -q "2.0.0" gfm && grep -q "2.0.0" README.md; then
    echo -e "  ${GREEN}✅ Versions cohérentes${NC}"
else
    echo -e "  ${YELLOW}⚠️  Versions potentiellement incohérentes${NC}"
fi

# Vérification Git
echo -e "${BLUE}📦 État Git...${NC}"

if git status --porcelain | grep -q .; then
    echo -e "  ${YELLOW}⚠️  Fichiers non committés détectés${NC}"
    git status --porcelain
else
    echo -e "  ${GREEN}✅ Repository propre${NC}"
fi

# Suggestions d'amélioration
echo -e "${BLUE}💡 Suggestions...${NC}"

suggestions=(
    "Ajouter des screenshots dans README.md"
    "Créer une release avec tag v2.0.0"
    "Ajouter des GitHub Actions pour CI/CD"
    "Créer des issues templates"
    "Ajouter un code of conduct"
)

for suggestion in "${suggestions[@]}"; do
    echo -e "  ${CYAN}💡 $suggestion${NC}"
done

# Résumé final
echo
echo -e "${CYAN}${BOLD}📊 RÉSUMÉ${NC}"
echo -e "${CYAN}=========${NC}"

if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}🎉 PROJET PRÊT POUR PUBLICATION !${NC}"
    echo -e "${GREEN}✅ Aucun problème bloquant détecté${NC}"
    echo
    echo -e "${CYAN}🚀 Prochaines étapes recommandées :${NC}"
    echo -e "  1. ${CYAN}git add -A && git commit -m 'feat: Ready for GitHub publication'${NC}"
    echo -e "  2. ${CYAN}git remote add origin https://github.com/RenZan/gitfixmanager.git${NC}"
    echo -e "  3. ${CYAN}git push -u origin main${NC}"
    echo -e "  4. ${CYAN}git tag v2.0.0 && git push origin v2.0.0${NC}"
    echo
    echo -e "${GREEN}🌟 Votre projet Git Fix Manager est prêt à être partagé !${NC}"
else
    echo -e "${RED}${BOLD}❌ $ISSUES PROBLÈME(S) DÉTECTÉ(S)${NC}"
    echo -e "${YELLOW}⚠️  Corrigez les problèmes ci-dessus avant publication${NC}"
fi

exit $ISSUES