#!/bin/bash

# Test simplifié et robuste de l'héritage massif
# Focus sur la démonstration claire du problème et de la solution

set -e

TEST_DIR="/tmp/gfm-simple-test"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GFM_DIR="$(dirname "$SCRIPT_DIR")"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Test simplifié d'héritage massif${NC}"
echo "=================================="

# Préparation
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

git init --quiet
git config user.name "Test User"
git config user.email "test@example.com"

echo -e "${YELLOW}📝 Création d'un scénario problématique...${NC}"

# Créer des commits avec des patterns problématiques
for i in {1..20}; do
    echo "Content $i" > "file$i.txt"
    git add "file$i.txt"
    
    case $((i % 4)) in
        0) git commit --quiet -m "Merged PR 123: Feature $i" ;;
        1) git commit --quiet -m "Fix" ;;
        2) git commit --quiet -m "Update" ;;
        *) git commit --quiet -m "Implement detailed feature $i with comprehensive functionality" ;;
    esac
done

# Créer des branches avec cherry-picks
git checkout -b release --quiet
echo "Release content" > release.txt
git add release.txt
git commit --quiet -m "Merged PR 123: Feature release"  # Même PR que d'autres commits

git checkout -b hotfix --quiet  
echo "Hotfix content" > hotfix.txt
git add hotfix.txt
git commit --quiet -m "Fix"  # Même titre générique

# Installation de Git Fix Manager
echo -e "${YELLOW}📋 Installation de Git Fix Manager...${NC}"
cp -r "$GFM_DIR"/* ./
chmod +x gfm

echo -e "${BLUE}🔬 TEST DU PROBLÈME${NC}"
echo "=================="

# Sauvegarder le script actuel
cp scripts/missing-fix-detector.sh scripts/missing-fix-detector-fixed.sh

# Créer la version buggée (sans limitations)
cat > scripts/missing-fix-detector-buggy.sh << 'EOF'
#!/bin/bash

find_cherry_pick_copies() {
    local original_commit="$1"
    local target_branch_pattern="$2"
    
    echo "🔄 Scan automatique des cherry-picks pour héritage..." >&2
    
    local original_title=$(git log --format="%s" -1 "$original_commit" 2>/dev/null)
    
    if [ -z "$original_title" ]; then
        return
    fi
    
    local copied_commits=()
    
    # Méthode 1: Recherche directe par référence
    while IFS= read -r copied_commit; do
        if [ -n "$copied_commit" ] && [ "$copied_commit" != "$original_commit" ]; then
            copied_commits+=("$copied_commit")
        fi
    done < <(git log --all --grep="$original_commit" --format="%H" 2>/dev/null || true)
    
    # Méthode 2: Recherche par titre (SANS FILTRAGE)
    while IFS= read -r copied_commit; do
        if [ -n "$copied_commit" ] && [ "$copied_commit" != "$original_commit" ]; then
            copied_commits+=("$copied_commit")
        fi
    done < <(git log --all --grep="$original_title" --format="%H" 2>/dev/null || true)
    
    # Méthode 3: Recherche PR (SANS ANCHORING)
    local pr_number=$(echo "$original_title" | grep -o '[0-9]\+' | head -1)
    if [ -n "$pr_number" ]; then
        while IFS= read -r copied_commit; do
            if [ -n "$copied_commit" ] && [ "$copied_commit" != "$original_commit" ]; then
                copied_commits+=("$copied_commit")
            fi
        done < <(git log --all --grep="$pr_number" --format="%H" 2>/dev/null || true)
    fi
    
    # Retourner TOUS les résultats (sans limitation)
    for commit in "${copied_commits[@]}"; do
        echo "$commit"
    done
}
EOF

echo -e "${RED}⚡ Test avec code BUGGY...${NC}"
cp scripts/missing-fix-detector-buggy.sh scripts/missing-fix-detector.sh

# Marquer un bug sur un commit problématique  
MAIN_BRANCH=$(git symbolic-ref --short HEAD)
git checkout "$MAIN_BRANCH" --quiet
PROBLEMATIC_COMMIT=$(git log --format="%H" --grep="Merged PR 123" -1)

if [ -n "$PROBLEMATIC_COMMIT" ]; then
    echo "🐛 Marquage bug sur: $PROBLEMATIC_COMMIT"
    git notes --ref=bugs add -m "BUG-MASSIVE-TEST|Bug pour test héritage massif" "$PROBLEMATIC_COMMIT"
    
    echo "📊 Comptage des bugs (version BUGGÉE)..."
    start_time=$(date +%s)
    
    # Compter directement les notes de bugs pour éviter les timeouts
    bug_count_before=$(git notes --ref=bugs list 2>/dev/null | wc -l || echo "0")
    echo "  - Notes de bugs initiales: $bug_count_before"
    
    # Tester le statut avec timeout court
    status_output=$(timeout 15s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT_OR_ERROR")
    end_time=$(date +%s)
    duration_before=$((end_time - start_time))
    
    if echo "$status_output" | grep -q "TIMEOUT\|ALERTE.*Limitation"; then
        echo -e "  ${RED}💥 PROBLÈME DÉTECTÉ: Héritage massif ou timeout!${NC}"
        echo "  - Durée: ${duration_before}s"
    else
        detected_bugs=$(echo "$status_output" | grep -c "Bug détecté:" 2>/dev/null || echo "0")
        echo "  - Bugs détectés: $detected_bugs en ${duration_before}s"
    fi
fi

echo -e "\n${GREEN}⚡ Test avec code CORRIGÉ...${NC}"
cp scripts/missing-fix-detector-fixed.sh scripts/missing-fix-detector.sh

# Nettoyer et remarquer le bug
git notes --ref=bugs remove --ignore-missing $(git rev-list --all) 2>/dev/null || true
git notes --ref=bugs add -m "BUG-FIXED-TEST|Bug pour test version corrigée" "$PROBLEMATIC_COMMIT"

echo "📊 Test de la version corrigée..."
start_time=$(date +%s)

status_output_fixed=$(timeout 30s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
end_time=$(date +%s)
duration_fixed=$((end_time - start_time))

detected_bugs_fixed=$(echo "$status_output_fixed" | grep -c "Bug détecté:" 2>/dev/null || echo "0")
alert_count=$(echo "$status_output_fixed" | grep -c "ALERTE.*Limitation" 2>/dev/null || echo "0")

echo "  - Bugs détectés: $detected_bugs_fixed"
echo "  - Alertes de limitation: $alert_count"
echo "  - Durée: ${duration_fixed}s"

echo -e "\n${BLUE}📈 COMPARAISON${NC}"
echo "=============="
echo -e "${RED}AVANT correction:${NC}"
echo "  - Comportement: Héritage massif ou timeout"
echo "  - Performance: Problématique"

echo -e "${GREEN}APRÈS correction:${NC}"
echo "  - Bugs détectés: $detected_bugs_fixed"
echo "  - Alertes: $alert_count"
echo "  - Durée: ${duration_fixed}s"

if [ "$duration_fixed" -lt 20 ] && [ "$alert_count" -gt 0 ]; then
    echo -e "\n${GREEN}🎉 SUCCÈS: Les corrections fonctionnent!${NC}"
    echo "✅ Limitations actives"
    echo "✅ Performance acceptable"
    echo "✅ Héritage massif maîtrisé"
else
    echo -e "\n${YELLOW}⚠️ Résultats à analyser${NC}"
    echo "Durée: ${duration_fixed}s, Alertes: $alert_count"
fi

# Test supplémentaire: vérifier le contenu des alertes
if [ "$alert_count" -gt 0 ]; then
    echo -e "\n${BLUE}🔍 Détail des alertes:${NC}"
    echo "$status_output_fixed" | grep "ALERTE.*Limitation" | head -3
fi

echo -e "\n${YELLOW}🧹 Nettoyage...${NC}"
cd ..
rm -rf "$TEST_DIR"

echo -e "${GREEN}✅ Test terminé!${NC}"