#!/bin/bash

cd /tmp/gfm-selection-test

echo "=== Test complet de gfm fix avec sélection interactive ==="

# Test en mode manuel plutôt qu'avec echo
echo "1. Vérification des bugs disponibles:"
/home/renzan/.local/bin/gfm list bugs

echo
echo "2. Test interactif complet:"
echo "Nous allons simuler la sélection du premier bug..."

# Créer un fichier avec l'input pour éviter les problèmes de pipe
echo "1" > /tmp/input.txt
echo "Y" >> /tmp/input.txt

echo "Input simulé créé. Lancement de gfm fix..."
/home/renzan/.local/bin/gfm fix < /tmp/input.txt

echo
echo "=== Test terminé ==="