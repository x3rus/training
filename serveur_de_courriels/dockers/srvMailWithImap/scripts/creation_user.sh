#!/bin/bash
#
# Description : Création d'utilisateur pour le service de courriel
#
# Autheur : Thomas Boutry <Thomas.boutry@x3rus.com>
# Licence : GPL v3
#
#########################################################################

IMAPCONTENEUR=coco-imap-t

f_usage () {
    # Show help message
    echo "  usage : $0 -u nom_utilisateur "
    echo " "
    echo " Description : Création d'un utilisateur pour imap .... "
}

####################
# script arguments #

while getopts u:h FLAG; do
    case $FLAG in
        u)  # Recuperation du nom de l'utilisateur
            NOM_UTILISATEUR=$OPTARG
            ;;
        p)  # Recuperation le mot de passe de l'utilisateur
            PASSWORD_UTILISATEUR=$OPTARG
            ;;
        h)  #how help message
            f_usage
            exit 1
            ;;
        \?) #unrecognized option - show help
            echo "ERROR: option used not reconized , please read usage "
            f_usage
            exit 1
            ;;
    esac # end case opts
done # End while getopts

# Création de l'utilisateur dans le docker 

docker exec -it $IMAPCONTENEUR /usr/local/bin/cuser.sh $NOM_UTILISATEUR $PASSWORD_UTILISATEUR



