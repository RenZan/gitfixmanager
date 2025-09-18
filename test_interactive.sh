#!/bin/bash

# Script de test pour la sélection interactive
cd /tmp/gfm-selection-test || exit 1

echo "=== Test de la sélection interactive ==="
echo

# Vérifier que les bugs existent
echo "1. Vérification des bugs existants:"
/home/renzan/.local/bin/gfm list bugs
echo

# Test de la sélection interactive avec simulation d'entrée
echo "2. Test de la sélection interactive (sélection automatique du premier bug):"
echo "1" | /home/renzan/.local/bin/gfm fix

echo
echo "=== Fin du test ==="