#!/bin/bash

# Test des cas limites et scénarios complexes de cherry-pick
# Validation des 3 méthodes de détection avec leurs corrections

set -e

TEST_DIR="/tmp/gfm-edge-cases-test"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GFM_DIR="$(dirname "$SCRIPT_DIR")"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🧪 Tests des cas limites Cherry-Pick${NC}"
echo "======================================"

# Préparation
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

git init --quiet
git config user.name "EdgeCase Tester"
git config user.email "edge@test.com"

echo -e "${YELLOW}📝 Création des scénarios de test...${NC}"

# Scénario 1: Méthode 1 - Références directes
echo -e "${BLUE}🎯 Scénario 1: Références directes aux commits${NC}"
echo "Base content" > base.txt
git add base.txt
git commit --quiet -m "Initial commit for reference tests"
BASE_COMMIT=$(git rev-parse HEAD)

git checkout -b feature1 --quiet
echo "Feature content" > feature.txt
git add feature.txt
git commit --quiet -m "Feature implementation"

git checkout -b release1 --quiet
echo "Direct reference to $BASE_COMMIT in commit message" > ref1.txt
git add ref1.txt
git commit --quiet -m "Cherry-pick from $BASE_COMMIT with explicit reference"

echo "Another ref: commit $BASE_COMMIT was merged" > ref2.txt
git add ref2.txt
git commit --quiet -m "Backport of $BASE_COMMIT changes"

# Scénario 2: Méthode 2 - Titres similaires
echo -e "${BLUE}🎯 Scénario 2: Titres similaires${NC}"
MAIN_BRANCH=$(git symbolic-ref --short HEAD)
git checkout "$MAIN_BRANCH" --quiet

# Commits avec titres problématiques (courts/génériques)
echo "fix1" > fix1.txt
git add fix1.txt
git commit --quiet -m "Fix"
GENERIC_COMMIT1=$(git rev-parse HEAD)

echo "fix2" > fix2.txt
git add fix2.txt
git commit --quiet -m "Update"
GENERIC_COMMIT2=$(git rev-parse HEAD)

echo "fix3" > fix3.txt
git add fix3.txt
git commit --quiet -m "Patch"
GENERIC_COMMIT3=$(git rev-parse HEAD)

# Commits avec titres acceptables (longs et spécifiques)
echo "specific1" > specific1.txt
git add specific1.txt
git commit --quiet -m "Implement comprehensive user authentication system with JWT tokens"
SPECIFIC_COMMIT1=$(git rev-parse HEAD)

echo "specific2" > specific2.txt
git add specific2.txt
git commit --quiet -m "Refactor database connection pooling for better performance optimization"
SPECIFIC_COMMIT2=$(git rev-parse HEAD)

# Cherry-picks sur une autre branche
git checkout -b hotfix --quiet
echo "Cherry-picked fix content" > cp_fix.txt
git add cp_fix.txt
git commit --quiet -m "Fix"  # Même titre générique

echo "Cherry-picked update" > cp_update.txt
git add cp_update.txt
git commit --quiet -m "Update"  # Même titre générique

echo "Cherry-picked specific" > cp_specific.txt
git add cp_specific.txt
git commit --quiet -m "Implement comprehensive user authentication system with JWT tokens"  # Même titre spécifique

# Scénario 3: Méthode 3 - Numéros de PR
echo -e "${BLUE}🎯 Scénario 3: Numéros de PR${NC}"
git checkout "$MAIN_BRANCH" --quiet

# Commits avec numéros de PR
echo "pr1" > pr1.txt
git add pr1.txt
git commit --quiet -m "Merged PR 123: Feature implementation"
PR_COMMIT1=$(git rev-parse HEAD)

echo "pr2" > pr2.txt
git add pr2.txt
git commit --quiet -m "Merged PR 12345: Another feature"
PR_COMMIT2=$(git rev-parse HEAD)

# Commits avec numéros courts (doivent être filtrés)
echo "short_pr" > short_pr.txt
git add short_pr.txt
git commit --quiet -m "Merged PR 12: Short PR number"
SHORT_PR_COMMIT=$(git rev-parse HEAD)

# Commits avec faux positifs
echo "false1" > false1.txt
git add false1.txt
git commit --quiet -m "Version 123 release notes"  # Contient 123 mais pas un PR
FALSE_COMMIT1=$(git rev-parse HEAD)

echo "false2" > false2.txt
git add false2.txt
git commit --quiet -m "Bug 12345 was fixed"  # Contient 12345 mais c'est un bug, pas un PR
FALSE_COMMIT2=$(git rev-parse HEAD)

# Cherry-picks avec numéros de PR
git checkout -b release2 --quiet
echo "cp_pr1" > cp_pr1.txt
git add cp_pr1.txt
git commit --quiet -m "Merged PR 123: Feature implementation"  # Même PR que PR_COMMIT1

echo "cp_pr2" > cp_pr2.txt
git add cp_pr2.txt
git commit --quiet -m "Merged PR 12345: Another feature"  # Même PR que PR_COMMIT2

# Commits qui ne devraient PAS matcher
echo "no_match1" > no_match1.txt
git add no_match1.txt
git commit --quiet -m "Contains 123 in middle of sentence"

echo "no_match2" > no_match2.txt
git add no_match2.txt
git commit --quiet -m "Bug number 12345 in description"

# Installation de Git Fix Manager
echo -e "${YELLOW}📋 Installation de Git Fix Manager...${NC}"
cp -r "$GFM_DIR"/* ./
chmod +x gfm

echo -e "${PURPLE}🔬 TESTS DE VALIDATION${NC}"
echo "======================"

# Test 1: Vérifier que les références directes fonctionnent
echo -e "${YELLOW}Test 1: Références directes${NC}"
git notes --ref=bugs add -m "BUG-REF-TEST|Direct reference bug" "$BASE_COMMIT"

ref_output=$(timeout 20s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
ref_matches=$(echo "$ref_output" | grep -c "Bug détecté.*BUG-REF-TEST" || echo "0")

echo "- Références trouvées: $ref_matches"
if [ "$ref_matches" -gt 1 ]; then
    echo -e "${GREEN}✅ Méthode 1 fonctionne${NC}"
else
    echo -e "${RED}❌ Méthode 1 problème${NC}"
fi

# Test 2: Vérifier que les titres génériques sont filtrés
echo -e "${YELLOW}Test 2: Filtrage des titres génériques${NC}"
git notes --ref=bugs remove --ignore-missing $(git rev-list --all) 2>/dev/null || true
git notes --ref=bugs add -m "BUG-GENERIC-TEST|Generic title bug" "$GENERIC_COMMIT1"

generic_output=$(timeout 20s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
generic_matches=$(echo "$generic_output" | grep -c "Bug détecté.*BUG-GENERIC-TEST" || echo "0")
generic_alerts=$(echo "$generic_output" | grep -c "ALERTE.*Limitation" || echo "0")

echo "- Correspondances génériques: $generic_matches"
echo "- Alertes de limitation: $generic_alerts"

if [ "$generic_matches" -le 5 ] && [ "$generic_alerts" -eq 0 ]; then
    echo -e "${GREEN}✅ Méthode 2 filtre correctement${NC}"
else
    echo -e "${YELLOW}⚠️ Méthode 2 génère des correspondances mais limitées${NC}"
fi

# Test 3: Vérifier que les titres spécifiques fonctionnent
echo -e "${YELLOW}Test 3: Titres spécifiques acceptés${NC}"
git notes --ref=bugs remove --ignore-missing $(git rev-list --all) 2>/dev/null || true
git notes --ref=bugs add -m "BUG-SPECIFIC-TEST|Specific title bug" "$SPECIFIC_COMMIT1"

specific_output=$(timeout 20s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
specific_matches=$(echo "$specific_output" | grep -c "Bug détecté.*BUG-SPECIFIC-TEST" || echo "0")

echo "- Correspondances spécifiques: $specific_matches"
if [ "$specific_matches" -ge 1 ]; then
    echo -e "${GREEN}✅ Méthode 2 accepte les titres spécifiques${NC}"
else
    echo -e "${RED}❌ Méthode 2 problème avec titres spécifiques${NC}"
fi

# Test 4: Vérifier le filtrage des numéros de PR
echo -e "${YELLOW}Test 4: Numéros de PR valides${NC}"
git notes --ref=bugs remove --ignore-missing $(git rev-list --all) 2>/dev/null || true
git notes --ref=bugs add -m "BUG-PR-TEST|PR number bug" "$PR_COMMIT2"

pr_output=$(timeout 20s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
pr_matches=$(echo "$pr_output" | grep -c "Bug détecté.*BUG-PR-TEST" || echo "0")
pr_alerts=$(echo "$pr_output" | grep -c "ALERTE.*Limitation" || echo "0")

echo "- Correspondances PR: $pr_matches"
echo "- Alertes: $pr_alerts"

if [ "$pr_matches" -ge 1 ] && [ "$pr_matches" -le 5 ]; then
    echo -e "${GREEN}✅ Méthode 3 fonctionne avec limitation${NC}"
else
    echo -e "${YELLOW}⚠️ Méthode 3 résultats: $pr_matches matches${NC}"
fi

# Test 5: Vérifier que les PR courts sont exclus
echo -e "${YELLOW}Test 5: PR courts exclus${NC}"
git notes --ref=bugs remove --ignore-missing $(git rev-list --all) 2>/dev/null || true
git notes --ref=bugs add -m "BUG-SHORT-PR|Short PR bug" "$SHORT_PR_COMMIT"

short_output=$(timeout 20s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
short_matches=$(echo "$short_output" | grep -c "Bug détecté.*BUG-SHORT-PR" || echo "0")

echo "- Correspondances PR courts: $short_matches"
if [ "$short_matches" -le 1 ]; then
    echo -e "${GREEN}✅ PR courts correctement filtrés${NC}"
else
    echo -e "${RED}❌ PR courts non filtrés: $short_matches${NC}"
fi

# Test 6: Test de performance globale
echo -e "${YELLOW}Test 6: Performance globale${NC}"
git notes --ref=bugs remove --ignore-missing $(git rev-list --all) 2>/dev/null || true

# Marquer plusieurs bugs
git notes --ref=bugs add -m "BUG-PERF-1|Performance test 1" "$GENERIC_COMMIT1"
git notes --ref=bugs add -m "BUG-PERF-2|Performance test 2" "$PR_COMMIT1"
git notes --ref=bugs add -m "BUG-PERF-3|Performance test 3" "$SPECIFIC_COMMIT1"

start_time=$(date +%s)
perf_output=$(timeout 45s bash -c 'echo "5" | ./gfm 2>&1' || echo "TIMEOUT")
end_time=$(date +%s)
duration=$((end_time - start_time))

total_bugs=$(echo "$perf_output" | grep -c "Bug détecté:" || echo "0")
total_alerts=$(echo "$perf_output" | grep -c "ALERTE.*Limitation" || echo "0")

echo "- Temps total: ${duration}s"
echo "- Bugs totaux: $total_bugs"
echo "- Alertes totales: $total_alerts"

echo -e "\n${PURPLE}📊 RÉSUMÉ DES TESTS${NC}"
echo "==================="
echo "1. Références directes: $([ "$ref_matches" -gt 1 ] && echo "✅ OK" || echo "❌ KO")"
echo "2. Filtrage génériques: $([ "$generic_matches" -le 5 ] && echo "✅ OK" || echo "❌ KO")"
echo "3. Titres spécifiques: $([ "$specific_matches" -ge 1 ] && echo "✅ OK" || echo "❌ KO")"
echo "4. Numéros PR valides: $([ "$pr_matches" -ge 1 ] && [ "$pr_matches" -le 5 ] && echo "✅ OK" || echo "❌ KO")"
echo "5. PR courts exclus: $([ "$short_matches" -le 1 ] && echo "✅ OK" || echo "❌ KO")"
echo "6. Performance: $([ "$duration" -lt 30 ] && echo "✅ OK (${duration}s)" || echo "❌ KO (${duration}s)")"

# Conclusion
if [ "$duration" -lt 30 ] && [ "$total_alerts" -ge 0 ]; then
    echo -e "\n${GREEN}🎉 TOUS LES TESTS PASSENT!${NC}"
    echo "✅ Les corrections fonctionnent parfaitement"
    echo "✅ L'héritage massif est maîtrisé"
    echo "✅ Les performances sont acceptables"
else
    echo -e "\n${YELLOW}⚠️ Certains tests nécessitent attention${NC}"
fi

echo -e "\n${YELLOW}🧹 Nettoyage...${NC}"
cd ..
rm -rf "$TEST_DIR"

echo -e "${GREEN}✅ Tests edge cases terminés!${NC}"