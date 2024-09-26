#!/bin/bash

# Fonction pour afficher le menu
show_menu() {
    echo "Choisissez le type de scan Nmap:"
    echo "1) Scan rapide"
    echo "2) Scan complet"
    echo "3) Scan personnalisé"
    echo "4) Scan avancé (OS et services)"
    echo "5) Quitter"
}
# Afficher le menu et lire le choix de l'utilisateur
while true; do
    show_menu
    read -p "Entrez votre choix: " choice
    if [ "$choice" -eq 5 ]; then
        break
    fi
done
