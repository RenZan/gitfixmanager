#!/bin/bash

# Test complet de l'héritage massif de cherry-picks
# Ce script reproduit le problème initial et valide la solution

set -e

TEST_DIR="/tmp/gfm-cherry-pick-test"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GFM_DIR="$(dirname "$SCRIPT_DIR")"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Test d'héritage massif de cherry-picks${NC}"
echo "========================================"

# Nettoyage
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo -e "${YELLOW}📦 Création du dépôt fictif...${NC}"

# Initialisation du repo
git init --quiet
git config user.name "Test User"
git config user.email "test@example.com"

# Branch principale avec beaucoup de commits
echo -e "${YELLOW}📝 Création de 100 commits sur main...${NC}"
for i in {1..100}; do
    echo "Content $i" > "file$i.txt"
    git add "file$i.txt"
    if [ $((i % 10)) -eq 0 ]; then
        # Commits avec numéros de PR (problématiques)
        git commit --quiet -m "Merged PR $i: Feature implementation $i"
    elif [ $((i % 7)) -eq 0 ]; then
        # Commits avec titres génériques (problématiques)
        git commit --quiet -m "Fix"
    elif [ $((i % 5)) -eq 0 ]; then
        # Commits avec titres courts (problématiques)
        git commit --quiet -m "Update"
    else
        # Commits normaux
        git commit --quiet -m "Implement feature $i with detailed description and proper context"
    fi
done

# Vérifier qu'on est sur master par défaut
MAIN_BRANCH=$(git symbolic-ref --short HEAD)
echo "Branche principale détectée: $MAIN_BRANCH"

# Branche de développement
echo -e "${YELLOW}🌿 Création de la branche dev avec cherry-picks...${NC}"
git checkout -b dev --quiet

# Ajout de commits dans dev
for i in {101..120}; do
    echo "Dev content $i" > "dev_file$i.txt"
    git add "dev_file$i.txt"
    git commit --quiet -m "Dev feature $i implementation with proper description"
done

# Création de la branche release
echo -e "${YELLOW}🏷️ Création de la branche release...${NC}"
git checkout -b release --quiet

# Cherry-pick massif (simulation du problème réel)
echo -e "${YELLOW}🍒 Cherry-picking de 50 commits depuis $MAIN_BRANCH...${NC}"
git checkout "$MAIN_BRANCH" --quiet
COMMITS_TO_PICK=($(git log --format="%H" -50))

git checkout release --quiet
for commit in "${COMMITS_TO_PICK[@]}"; do
    if git cherry-pick "$commit" --no-edit >/dev/null 2>&1; then
        # Succès silencieux
        :
    else
        # En cas de conflit, on continue
        git cherry-pick --abort >/dev/null 2>&1 || true
    fi
done

# Branche hotfix avec plus de cherry-picks
echo -e "${YELLOW}🔥 Création de la branche hotfix...${NC}"
git checkout -b hotfix --quiet

# Cherry-pick depuis dev
git log dev --format="%H" -10 | while read commit; do
    if git cherry-pick "$commit" --no-edit >/dev/null 2>&1; then
        :
    else
        git cherry-pick --abort >/dev/null 2>&1 || true
    fi
done

echo -e "${GREEN}✅ Dépôt fictif créé avec succès${NC}"
echo "- 100 commits sur main (dont beaucoup problématiques)"
echo "- 20 commits sur dev"
echo "- ~50 cherry-picks sur release"
echo "- ~10 cherry-picks sur hotfix"

# Copie de Git Fix Manager
echo -e "${YELLOW}📋 Installation de Git Fix Manager...${NC}"
cp -r "$GFM_DIR"/* ./
chmod +x gfm

echo -e "${BLUE}🔬 TESTS AVANT CORRECTION${NC}"
echo "=========================="

# Sauvegarde de l'ancien code (sans les corrections)
cp scripts/missing-fix-detector.sh scripts/missing-fix-detector.sh.backup

# Création de la version AVANT correction (avec le bug)
cat > scripts/missing-fix-detector.sh.old << 'EOF'
#!/bin/bash
# Version AVANT correction - avec le bug d'héritage massif

find_cherry_pick_copies() {
    local original_commit="$1"
    local target_branch_pattern="$2"
    
    echo "🔄 Scan automatique des cherry-picks pour héritage..." >&2
    
    # Récupération des informations du commit original
    local original_title=$(git log --format="%s" -1 "$original_commit" 2>/dev/null)
    local original_message=$(git log --format="%B" -1 "$original_commit" 2>/dev/null)
    
    if [ -z "$original_title" ]; then
        echo "⚠️ Commit $original_commit introuvable" >&2
        return
    fi
    
    # Liste pour stocker les commits copiés
    local copied_commits=()
    
    # Méthode 1: Recherche directe par référence au commit original
    while IFS= read -r copied_commit; do
        if [ -n "$copied_commit" ] && [ "$copied_commit" != "$original_commit" ]; then
            copied_commits+=("$copied_commit")
        fi
    done < <(git log --all --grep="$original_commit" --format="%H" 2>/dev/null || true)
    
    # Méthode 2: Recherche par similitude de titre (BUGGY - pas de filtre)
    if [ ${#copied_commits[@]} -lt 3 ]; then
        while IFS= read -r copied_commit; do
            if [ -n "$copied_commit" ] && [ "$copied_commit" != "$original_commit" ]; then
                copied_commits+=("$copied_commit")
            fi
        done < <(git log --all --grep="$original_title" --format="%H" 2>/dev/null || true)
    fi
    
    # Méthode 3: Recherche par numéro de PR (TRÈS BUGGY - grep simple)
    if [ ${#copied_commits[@]} -lt 3 ]; then
        local pr_number=$(echo "$original_title" | grep -o 'PR [0-9]\+' | head -1 | grep -o '[0-9]\+' || true)
        if [ -n "$pr_number" ]; then
            while IFS= read -r copied_commit; do
                if [ -n "$copied_commit" ] && [ "$copied_commit" != "$original_commit" ]; then
                    copied_commits+=("$copied_commit")
                fi
            done < <(git log --all --grep="$pr_number" --format="%H" 2>/dev/null || true)
        fi
    fi
    
    # Retourner les résultats (SANS LIMITATION)
    for commit in "${copied_commits[@]}"; do
        echo "$commit"
    done
}
EOF

# Test avec l'ancien code
echo -e "${RED}⚡ Test avec l'ancien code (BUGGY)...${NC}"
cp scripts/missing-fix-detector.sh.old scripts/missing-fix-detector.sh

# Marquer un bug sur un commit problématique
git checkout "$MAIN_BRANCH" --quiet
PROBLEMATIC_COMMIT=$(git log --format="%H" --grep="Merged PR" -1)

if [ -n "$PROBLEMATIC_COMMIT" ]; then
    echo -e "${YELLOW}🐛 Marquage d'un bug sur le commit problématique: $PROBLEMATIC_COMMIT${NC}"
    
    # Utilisation interactive simulée
    {
        echo "1"                    # Marquer un bug
        echo "BUG-TEST-MASSIVE"    # ID du bug
        echo "Bug de test pour héritage massif" # Description
        echo "y"                   # Confirmer
        echo "0"                   # Quitter
    } | timeout 60s ./gfm >/dev/null 2>&1 || true
    
    echo -e "${RED}📊 Statut AVANT correction:${NC}"
    start_time=$(date +%s)
    
    # Compter les bugs détectés
    bug_count=$(timeout 30s bash -c 'echo "5" | ./gfm 2>/dev/null | grep -c "Bug détecté:" || echo "TIMEOUT"')
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo "- Bugs détectés: $bug_count"
    echo "- Temps d'exécution: ${duration}s"
    
    if [ "$bug_count" = "TIMEOUT" ] || [ "$bug_count" -gt 50 ]; then
        echo -e "${RED}💥 PROBLÈME CONFIRMÉ: Héritage massif détecté!${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Aucun commit avec PR trouvé pour le test${NC}"
fi

echo -e "\n${BLUE}🔬 TESTS APRÈS CORRECTION${NC}"
echo "========================="

# Restaurer le nouveau code (avec les corrections)
cp scripts/missing-fix-detector.sh.backup scripts/missing-fix-detector.sh

echo -e "${GREEN}⚡ Test avec le nouveau code (CORRIGÉ)...${NC}"

# Nettoyer les git notes
git notes --ref=bugs remove --ignore-missing $(git rev-list --all) 2>/dev/null || true

# Remarquer le même bug
echo -e "${YELLOW}🐛 Remarquage du bug avec le code corrigé...${NC}"
{
    echo "1"                    # Marquer un bug
    echo "BUG-TEST-FIXED"      # ID du bug
    echo "Bug de test avec code corrigé" # Description
    echo "y"                   # Confirmer
    echo "0"                   # Quitter
} | timeout 60s ./gfm >/dev/null 2>&1 || true

echo -e "${GREEN}📊 Statut APRÈS correction:${NC}"
start_time=$(date +%s)

# Test du statut avec limitation
status_output=$(timeout 30s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
bug_count_fixed=$(echo "$status_output" | grep -c "Bug détecté:" || echo "0")
alert_count=$(echo "$status_output" | grep -c "ALERTE.*Limitation" || echo "0")

end_time=$(date +%s)
duration_fixed=$((end_time - start_time))

echo "- Bugs détectés: $bug_count_fixed"
echo "- Alertes de limitation: $alert_count"
echo "- Temps d'exécution: ${duration_fixed}s"

echo -e "\n${BLUE}🧪 TESTS SPÉCIALISÉS${NC}"
echo "==================="

# Test des différentes méthodes
echo -e "${YELLOW}🎯 Test Méthode 1 (référence directe)...${NC}"
git checkout dev --quiet
echo "Test reference to $PROBLEMATIC_COMMIT" > test_ref.txt
git add test_ref.txt
git commit --quiet -m "Reference to commit $PROBLEMATIC_COMMIT"

echo -e "${YELLOW}🎯 Test Méthode 2 (titre générique)...${NC}"
echo "Generic fix content" > test_generic.txt
git add test_generic.txt
git commit --quiet -m "Fix"

echo -e "${YELLOW}🎯 Test Méthode 3 (numéro PR)...${NC}"
echo "PR content" > test_pr.txt
git add test_pr.txt
git commit --quiet -m "Merged PR 12345: Some feature"

# Test final
echo -e "${GREEN}🔍 Test final du statut complet...${NC}"
start_time=$(date +%s)
final_output=$(timeout 45s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
end_time=$(date +%s)
final_duration=$((end_time - start_time))

final_bugs=$(echo "$final_output" | grep -c "Bug détecté:" || echo "0")
final_alerts=$(echo "$final_output" | grep -c "ALERTE.*Limitation" || echo "0")

echo -e "\n${BLUE}📈 RÉSULTATS COMPARATIFS${NC}"
echo "========================="
echo -e "${RED}AVANT correction:${NC}"
echo "- Bugs détectés: $bug_count"
echo "- Alertes: 0"
echo "- Temps: ${duration}s"
echo ""
echo -e "${GREEN}APRÈS correction:${NC}"
echo "- Bugs détectés: $final_bugs"
echo "- Alertes de limitation: $final_alerts"
echo "- Temps: ${final_duration}s"

# Conclusion
echo -e "\n${BLUE}🎯 CONCLUSION${NC}"
echo "============="

if [ "$final_alerts" -gt 0 ] && [ "$final_duration" -lt 30 ]; then
    echo -e "${GREEN}✅ SUCCÈS: Les limitations fonctionnent parfaitement!${NC}"
    echo "- Les alertes de limitation sont déclenchées"
    echo "- Le temps d'exécution est acceptable"
    echo "- L'héritage massif est maîtrisé"
else
    echo -e "${YELLOW}⚠️ Résultats mitigés ou problème persistant${NC}"
fi

echo -e "\n${YELLOW}🧹 Nettoyage...${NC}"
cd ..
rm -rf "$TEST_DIR"

echo -e "${GREEN}✅ Tests terminés!${NC}"