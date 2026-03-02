#!/bin/bash

# 🤖 SCRIPT DE TEST AUTOMATISÉ - FIX HÉRITAGE MASSIF
# ==================================================
# Script pour CI/CD et validation automatique

set -e

# Configuration
TEST_DIR="/tmp/gfm-auto-test-$$"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GFM_DIR="$(dirname "$SCRIPT_DIR")"
EXIT_CODE=0

# Couleurs (désactivées si pas de TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Fonction de logging
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    EXIT_CODE=1
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Cleanup function
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

trap cleanup EXIT

log "🤖 Test automatisé du fix d'héritage massif"
log "============================================"

# 1. Préparation de l'environnement
log "📦 Préparation de l'environnement de test..."

mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

git init --quiet
git config user.name "CI Test"
git config user.email "ci@test.com"

# 2. Création du scénario de test
log "📝 Création du scénario de test..."

# Commits problématiques
for i in {1..15}; do
    echo "Test content $i" > "test$i.txt"
    git add "test$i.txt"
    
    case $((i % 4)) in
        0) git commit --quiet -m "Merged PR 12345: Test feature $i" ;;
        1) git commit --quiet -m "Fix" ;;
        2) git commit --quiet -m "Update test $i with comprehensive implementation details" ;;
        *) git commit --quiet -m "Feature $i" ;;
    esac
done

# Installation GFM
cp -r "$GFM_DIR"/* ./
if [ ! -f gfm ]; then
    log_failure "Git Fix Manager non trouvé"
    exit 1
fi

chmod +x gfm || true

# 3. Test de base
log "🧪 Test de base - Marquage d'un bug..."

MAIN_BRANCH=$(git symbolic-ref --short HEAD)
TEST_COMMIT=$(git log --oneline --grep="PR 12345" | head -1 | cut -d' ' -f1)

if [ -z "$TEST_COMMIT" ]; then
    log_failure "Aucun commit de test trouvé"
    exit 1
fi

git notes --ref=bugs add -m "BUG-AUTO-TEST|Bug de test automatisé" "$TEST_COMMIT"

# 4. Test du statut
log "📊 Test du statut avec timeout..."

timeout 30s bash -c 'echo "5" | ./gfm > status_result.txt 2>&1' || {
    log_failure "Timeout lors du test de statut"
    exit 1
}

# 5. Analyse des résultats
log "🔍 Analyse des résultats..."

if [ ! -f status_result.txt ]; then
    log_failure "Fichier de résultats non généré"
    exit 1
fi

# Compter les bugs et alertes
BUGS_COUNT=$(grep -c "Bug détecté:" status_result.txt 2>/dev/null || echo "0")
ALERTS_COUNT=$(grep -c "ALERTE.*Limitation" status_result.txt 2>/dev/null || echo "0")

# Nettoyer les valeurs pour éviter les problèmes de parsing
BUGS_COUNT=$(echo "$BUGS_COUNT" | tr -d ' \n\r' | head -c 10)
ALERTS_COUNT=$(echo "$ALERTS_COUNT" | tr -d ' \n\r' | head -c 10)

# Tests de validation
log "✅ Validation des résultats..."

# Test 1: Nombre de bugs raisonnable
if [ "$BUGS_COUNT" -gt 0 ] && [ "$BUGS_COUNT" -le 10 ]; then
    log_success "Nombre de bugs détectés acceptable: $BUGS_COUNT"
else
    log_failure "Nombre de bugs anormal: $BUGS_COUNT (attendu: 1-10)"
fi

# Test 2: Alertes de limitation
if [ "$ALERTS_COUNT" -gt 0 ]; then
    log_success "Alertes de limitation actives: $ALERTS_COUNT"
else
    log_warning "Aucune alerte de limitation déclenchée"
fi

# Test 3: Pas de timeout
if grep -q "TIMEOUT" status_result.txt; then
    log_failure "Timeout détecté dans les résultats"
else
    log_success "Aucun timeout détecté"
fi

# Test 4: Structure des alertes
if [ "$ALERTS_COUNT" -gt 0 ]; then
    if grep -q "Limitation à [0-9]" status_result.txt; then
        log_success "Format des alertes correct"
    else
        log_failure "Format des alertes incorrect"
    fi
fi

# 6. Test de performance
log "⚡ Test de performance..."

start_time=$(date +%s)
timeout 60s bash -c 'echo "5" | ./gfm >/dev/null 2>&1' || {
    log_failure "Timeout de performance (>60s)"
    exit 1
}
end_time=$(date +%s)
duration=$((end_time - start_time))

if [ "$duration" -le 30 ]; then
    log_success "Performance acceptable: ${duration}s"
else
    log_warning "Performance lente: ${duration}s (>30s)"
fi

# 7. Test de régression
log "🔄 Test de régression - vérification de la cohérence..."

# Test avec multiple marquages
for i in {2..4}; do
    git notes --ref=bugs add -f -m "BUG-REG-$i|Bug de régression $i" HEAD~$i 2>/dev/null || true
done

timeout 45s bash -c 'echo "5" | ./gfm >/dev/null 2>&1' || {
    log_failure "Régression détectée - timeout avec multiple bugs"
    exit 1
}

log_success "Test de régression passé"

# 8. Rapport final
log "📋 Génération du rapport final..."

cat > test_report.txt << EOF
TEST AUTOMATISÉ - RAPPORT
========================
Date: $(date)
Environnement: $0
Commit GFM: $(cd "$GFM_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")

RÉSULTATS:
- Bugs détectés: $BUGS_COUNT
- Alertes limitation: $ALERTS_COUNT  
- Performance: ${duration}s
- Status: $([ $EXIT_CODE -eq 0 ] && echo "PASS" || echo "FAIL")

TESTS:
- ✅ Création environnement
- ✅ Marquage bugs
- ✅ Statut sans timeout
- $([ "$BUGS_COUNT" -gt 0 ] && [ "$BUGS_COUNT" -le 10 ] && echo "✅" || echo "❌") Nombre bugs raisonnable
- $([ "$ALERTS_COUNT" -gt 0 ] && echo "✅" || echo "⚠️") Alertes actives
- $([ "$duration" -le 30 ] && echo "✅" || echo "⚠️") Performance
- ✅ Régression

EOF

if [ $EXIT_CODE -eq 0 ]; then
    log_success "🎉 TOUS LES TESTS AUTOMATISÉS RÉUSSIS!"
    echo "✅ Le fix d'héritage massif fonctionne correctement"
    echo "📊 Bugs: $BUGS_COUNT, Alertes: $ALERTS_COUNT, Perf: ${duration}s"
else
    log_failure "❌ ÉCHEC DES TESTS AUTOMATISÉS"
    echo "🔍 Vérifier les logs ci-dessus pour les détails"
fi

# Copier le rapport vers le répertoire principal
if [ -w "$GFM_DIR/tests/" ]; then
    cp test_report.txt "$GFM_DIR/tests/last_auto_test_report.txt"
    log "📁 Rapport sauvegardé: tests/last_auto_test_report.txt"
fi

exit $EXIT_CODE