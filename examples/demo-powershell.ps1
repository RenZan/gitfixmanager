# Démonstration PowerShell du Script de Détection des Corrections Manquantes
# ===========================================================================

Write-Host "🎬 Démonstration du Script de Détection des Corrections Manquantes" -ForegroundColor Blue
Write-Host "=================================================================" -ForegroundColor Blue
Write-Host ""

# Vérifier que nous sommes dans le bon dossier
$currentDir = Get-Location
Write-Host "📁 Répertoire actuel: $currentDir" -ForegroundColor Cyan

# Vérifier que le script principal existe
$scriptPath = "..\scripts\missing-fix-detector.sh"
if (Test-Path $scriptPath) {
    Write-Host "✅ Script principal trouvé: $scriptPath" -ForegroundColor Green
} else {
    Write-Host "❌ Script principal non trouvé: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📝 Création du repository de démonstration..." -ForegroundColor Cyan

# Créer le dossier de démonstration
$demoDir = "missing-fix-demo"
if (Test-Path $demoDir) {
    Remove-Item -Recurse -Force $demoDir
}
New-Item -ItemType Directory -Name $demoDir | Out-Null
Set-Location $demoDir

# Initialiser Git
git init | Out-Null
git config user.name "Demo User" | Out-Null
git config user.email "demo@example.com" | Out-Null

# Créer la structure de dossiers
New-Item -ItemType Directory -Name "src" -Force | Out-Null
New-Item -ItemType Directory -Name "scripts" -Force | Out-Null

# Copier le script
Copy-Item "..\$scriptPath" "scripts\" -Force

Write-Host "📝 Création du code initial..." -ForegroundColor Cyan

# Créer le fichier main.c initial
@"
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Application Demo\n");
    
    // Code initial sans bugs
    char *buffer = malloc(100);
    printf("Buffer allocated\n");
    free(buffer);
    
    return 0;
}
"@ | Out-File -FilePath "src\main.c" -Encoding UTF8

# Créer le fichier parser.c initial
@"
#include <stdio.h>
#include <string.h>

int parse_input(char *input) {
    // Fonction de parsing simple
    if (input != NULL) {
        return strlen(input);
    }
    return 0;
}
"@ | Out-File -FilePath "src\parser.c" -Encoding UTF8

# Créer le README
@"
# Demo Application

Cette application démontre le système de détection des corrections manquantes.

## Fonctionnalités
- Parser d'entrée
- Gestion mémoire
- Interface utilisateur
"@ | Out-File -FilePath "README.md" -Encoding UTF8

# Commit initial
git add . | Out-Null
git commit -m "Initial commit: basic application structure" | Out-Null

Write-Host ""
Write-Host "🐛 Simulation: Introduction de bugs..." -ForegroundColor Yellow

# Bug 1: Memory leak dans main.c
@"
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Application Demo\n");
    
    // BUG: Memory leak - malloc sans free
    char *buffer = malloc(100);
    printf("Buffer allocated\n");
    // free(buffer); // Oublié !
    
    return 0;
}
"@ | Out-File -FilePath "src\main.c" -Encoding UTF8

git add src\main.c | Out-Null
git commit -m "Add logging feature" | Out-Null
$bug1Commit = git rev-parse HEAD

Write-Host "   ➜ Bug 1 introduit: Memory leak dans main.c (commit: $(git rev-parse --short $bug1Commit))" -ForegroundColor Red

# Bug 2: Null pointer dans parser.c
@"
#include <stdio.h>
#include <string.h>

int parse_input(char *input) {
    // BUG: Pas de vérification de input avant strlen
    return strlen(input); // Crash si input est NULL
}
"@ | Out-File -FilePath "src\parser.c" -Encoding UTF8

git add src\parser.c | Out-Null
git commit -m "Optimize parser performance" | Out-Null
$bug2Commit = git rev-parse HEAD

Write-Host "   ➜ Bug 2 introduit: Null pointer dans parser.c (commit: $(git rev-parse --short $bug2Commit))" -ForegroundColor Red

Write-Host ""
Write-Host "🏷️  Marquage des bugs..." -ForegroundColor Cyan

# Utiliser WSL ou bash pour exécuter le script bash
try {
    bash scripts/missing-fix-detector.sh mark-bug $bug1Commit "LEAK-001" "Memory leak in main function"
    bash scripts/missing-fix-detector.sh mark-bug $bug2Commit "NULL-001" "Null pointer dereference in parser"
} catch {
    Write-Host "⚠️  Impossible d'exécuter le script bash depuis PowerShell" -ForegroundColor Yellow
    Write-Host "   Les commandes seraient:" -ForegroundColor Yellow
    Write-Host "   bash scripts/missing-fix-detector.sh mark-bug $bug1Commit 'LEAK-001' 'Memory leak in main function'" -ForegroundColor Yellow
    Write-Host "   bash scripts/missing-fix-detector.sh mark-bug $bug2Commit 'NULL-001' 'Null pointer dereference in parser'" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌿 Création de la branche release avec les bugs..." -ForegroundColor Cyan
git checkout -b release/v1.0 | Out-Null
Write-Host "   ➜ Branche release/v1.0 créée à partir de master avec les 2 bugs" -ForegroundColor Yellow

# Retour sur master pour les corrections
git checkout master | Out-Null

Write-Host ""
Write-Host "🔧 Simulation: Corrections des bugs sur master..." -ForegroundColor Green

# Correction du bug 1
@"
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Application Demo\n");
    
    // FIX: Memory leak corrigé
    char *buffer = malloc(100);
    printf("Buffer allocated\n");
    free(buffer); // Ajouté pour corriger le leak
    
    return 0;
}
"@ | Out-File -FilePath "src\main.c" -Encoding UTF8

git add src\main.c | Out-Null
git commit -m "Fix memory leak in main function" | Out-Null
$fix1Commit = git rev-parse HEAD

Write-Host "   ➜ Bug 1 corrigé sur master (commit: $(git rev-parse --short $fix1Commit))" -ForegroundColor Green

Write-Host ""
Write-Host "🌿 Création d'une branche hotfix pour le bug 2..." -ForegroundColor Cyan
git checkout -b hotfix/null-fix | Out-Null

# Correction du bug 2
@"
#include <stdio.h>
#include <string.h>

int parse_input(char *input) {
    // FIX: Vérification de input avant utilisation
    if (input == NULL) {
        return 0;
    }
    return strlen(input);
}
"@ | Out-File -FilePath "src\parser.c" -Encoding UTF8

git add src\parser.c | Out-Null
git commit -m "Fix null pointer dereference in parser" | Out-Null
$fix2Commit = git rev-parse HEAD

Write-Host "   ➜ Bug 2 corrigé sur hotfix/null-fix (commit: $(git rev-parse --short $fix2Commit))" -ForegroundColor Green

Write-Host ""
Write-Host "📊 État actuel du repository:" -ForegroundColor Blue
Write-Host "=============================" -ForegroundColor Blue
Write-Host "• master: Les 2 bugs + correction du bug 1" -ForegroundColor Yellow
Write-Host "• hotfix/null-fix: Correction du bug 2" -ForegroundColor Yellow
Write-Host "• release/v1.0: Les 2 bugs SANS corrections" -ForegroundColor Yellow

Write-Host ""
Write-Host "🔍 Démonstration: Commandes pour marquer les corrections..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Commandes à exécuter pour marquer les corrections:" -ForegroundColor Yellow
Write-Host "bash scripts/missing-fix-detector.sh mark-fix $fix1Commit 'LEAK-001' $bug1Commit" -ForegroundColor White
Write-Host "bash scripts/missing-fix-detector.sh mark-fix $fix2Commit 'NULL-001' $bug2Commit" -ForegroundColor White

Write-Host ""
Write-Host "Commandes pour vérifier les corrections manquantes:" -ForegroundColor Yellow
Write-Host "bash scripts/missing-fix-detector.sh check release/v1.0" -ForegroundColor White
Write-Host "bash scripts/missing-fix-detector.sh suggest release/v1.0" -ForegroundColor White

Write-Host ""
Write-Host "🎉 Structure de démonstration créée!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Résumé de la démonstration:" -ForegroundColor Blue
Write-Host "==============================" -ForegroundColor Blue
Write-Host "1. ✅ Repository créé avec structure réaliste" -ForegroundColor Yellow
Write-Host "2. ✅ 2 bugs introduits sur des commits séparés" -ForegroundColor Yellow
Write-Host "3. ✅ Branche release/v1.0 créée avec les bugs" -ForegroundColor Yellow
Write-Host "4. ✅ Corrections créées sur différentes branches" -ForegroundColor Yellow
Write-Host "5. ✅ Script copié et prêt à être utilisé" -ForegroundColor Yellow

Write-Host ""
Write-Host "💡 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "• Ouvrir un terminal bash/WSL dans: $(Get-Location)" -ForegroundColor Yellow
Write-Host "• Exécuter les commandes de marquage ci-dessus" -ForegroundColor Yellow
Write-Host "• Tester: bash scripts/missing-fix-detector.sh help" -ForegroundColor Yellow
Write-Host "• Vérifier: bash scripts/missing-fix-detector.sh check release/v1.0" -ForegroundColor Yellow

Write-Host ""
Write-Host "📂 Le repository de démonstration est dans: $(Get-Location)" -ForegroundColor Blue