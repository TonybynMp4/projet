#!/bin/bash

# Fonction pour afficher le menu
show_menu() {
    echo "Choisissez le type de scan Nmap:"
    echo "1) Scan rapide"
    echo "2) Scan complet"
    echo "3) Scan personnalisé"
    echo "4) Scan avancé (OS et services)"
    if [ -n "$1" ] && [ "$1" -eq 1 ]; then
        return
    fi
    echo "5) Planifier un scan"
    echo "6) Quitter"
}

# Fonction pour effectuer le scan
perform_scan() {
    case $1 in
        1) nmap -F -Pn $2 ;; # Scan rapide
        2) nmap -p 1-65535 -Pn $2 ;; # Scan complet
        3) # Scan personnalisé
            read -p "Entrez les ports spécifiques ou la plage de ports à scanner (ex: 22,80,443 ou 1000-2000): " ports
            nmap -p $ports -Pn $2 ;;
        4) nmap -O -sV -Pn $2 ;; # Scan avancé (OS et services)
        *) echo "Option invalide" ;;
    esac
}

# Fonction pour planifier les scans avec cron
schedule_scan() {
    read -p "Entrez la fréquence des scans (ex: @daily, @weekly): " frequency
    show_menu 1
    read -p "Entrez le type de scan à effectuer (1-4): " action
    read -p "Entrez l'adresse IP ou la plage d'IP à scanner: " target

    # Vérifier si l'utilisateur a fourni des arguments
    if [ -z "$frequency" ] || [ -z "$action" ] || [ -z "$target" ]; then
        echo "Veuillez fournir des valeurs valides"
        return 1
    fi

    # Créer une tâche cron pour le scan
    (crontab -l 2>/dev/null; echo "$frequency $(whoami) $(pwd)/script.sh $action $target") | crontab -
    echo "Scan planifié avec succès"

    # Afficher les tâches cron actives & terminer le script
    crontab -l
    return 0
}

# Vérifier si l'utilisateur a fourni des arguments
if [ $# -eq 2 ]; then
    mkdir -p "$(pwd)/rapports"
    perform_scan $1 $2 > "$(pwd)/rapports/$(date +%Y-%m-%d_%H-%M).txt"
    exit 0
fi

while true; do
    show_menu
    read -p "Entrez votre choix: " choice
    if [ "$choice" -eq 6 ]; then
        break
    fi
    if [ "$choice" -gt 0 ] && [ "$choice" -lt 5 ]; then
        read -p "Entrez l'adresse IP ou la plage d'IP à scanner: " target
        perform_scan $choice $target
    elif [ "$choice" -eq 5 ]; then
        schedule_scan
    else
        echo "Option invalide"
    fi
done
