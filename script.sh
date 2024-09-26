#!/bin/bash

# Fonction pour afficher le menu
show_menu() {
    echo "Choisissez le type de scan Nmap:"
    echo "1) Scan rapide"
    echo "2) Scan complet"
    echo "3) Scan personnalisé"
    echo "4) Scan avancé (OS et services)"
    echo "5) Planifier un scan"
    echo "6) Quitter"
}

ask_for_scan() {
    read -p "Voulez-vous effectuer un scan Nmap? (y/n): " response
    if [ "$response" == "y" ]; then
        show_menu
    else
        echo "Au revoir!"
        exit 0
    fi
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
        5) schedule_scan ;; # Planification des scans
        *) echo "Option invalide" ;;
    esac
}

# Fonction pour planifier les scans avec cron
schedule_scan() {
    read -p "Entrez la fréquence des scans (ex: @daily, @weekly): " frequency
    show_menu;
    read -p "Entrez l'action à effectuer " action
    read -p "Entrez l'adresse IP ou la plage d'IP à scanner: " target

    # Créer une tâche cron pour le scan
    echo "$frequency root $HOME/script.sh $action $target" >> /etc/crontab
    echo "Scan planifié avec succès"

    # Redémarrer le service cron pour appliquer les modifications
    service cron restart
    echo "Service cron redémarré"

    # Afficher les tâches cron actives & terminer le script
    crontab -l
    exit 0
}

# Vérifier si l'utilisateur a fourni des arguments
if [ $# -eq 2 ]; then
    mkdir -p "$(pwd)/rapports"
    perform_scan $1 $2 > "$(pwd)/rapports/$(date +%Y-%m-%d_%H-%M).txt"
    exit 0
fi

# Afficher le menu et lire le choix de l'utilisateur
while true; do
    show_menu
    read -p "Entrez votre choix: " choice
    if [ "$choice" -eq 6 ]; then
        break
    fi
    read -p "Entrez l'adresse IP ou la plage d'IP à scanner: " target
    perform_scan $choice $target
done
