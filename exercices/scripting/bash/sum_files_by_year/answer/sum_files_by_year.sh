#!/bin/bash
#
# Description : Fait le calcul des fichiers d'un répertoire avec comme critère 
#   l'annee
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2016-01-21
# Licence : GPL v3.
###############################################################################

###########
## ARGS  ##
# TODO : faire le traitements des arguments avec getopts
PATH_TO_CHECK=$1
STARTING_YEAR=$2

# TODO : definir une function usage()

############
##  MAIN  ##

#### Petite validation d'arguments ####

# validation si le repertoire existe
if [ ! -d $PATH_TO_CHECK ] ; then
    echo "Répertoire en paramètre n'existe pas ou n'est pas un répertoire "
    echo "Répertoire fournit : $PATH_TO_CHECK "
    exit 1
fi

if [ "$STARTING_YEAR" == "" ] ; then
    echo "L'annee ne fut pas fournit en parametre, impossible de la deviner "
    exit 1
fi

# Extraction de l'annee suivante 
NEXT_YEAR=$((STARTING_YEAR + 1))

# Operation 1
# creation d'un fichier temporaire pour le stockage de l'information
LST_FILE_FOR_THE_YEAR=$(mktemp)

# Réalisation de la recherche des fichiers pour l'annee 
# (prendre note que l'utilisation d'un fichier temporaire n'est pas obligatoire cependant quand j'ai réalisé l'opération à l'origine je travaillais sur un répertoire de 1 Tera je ne voulais pas faire l'opération FIND plusieurs fois :P )
find $PATH_TO_CHECK -type f -newermt ${STARTING_YEAR}0101 -not -newermt ${NEXT_YEAR}0101 > $LST_FILE_FOR_THE_YEAR

# Operation 2
# creation d'un fichier temporaire pour l'extraction de la taille des fichier
LST_FILE_FOR_THE_YEAR_WITH_SIZE=$(mktemp)

# note : l'opération 1 ET 2 pourrais être réalisé en une command en utilisant l'argument -exec  de find.
#        je profite de l'oportunité d'utilisé xargs ici pour la démonstration
# TODO : mettre le paramètre pour les "" de args .. avec sed ... 
cat $LST_FILE_FOR_THE_YEAR | xargs -l du -s >> $LST_FILE_FOR_THE_YEAR_WITH_SIZE

echo " La taille total pour l'anne $STARTING_YEAR  en kilobytes : "
echo $(cat $LST_FILE_FOR_THE_YEAR_WITH_SIZE |tr "\t" " " | cut -d ' ' -f 1 | sed 's/$/ \+/g' | tr "\n" " " | sed 's/+ $//g') |  bc

# Clean 
# TODO : ajouter un read pour savoir si je supprimer ou non si les personnes veule voir les etapes.
echo -n " Voulez vous supprimer les fichiers temporaire ? [Y/n] "
read delete_files
if echo $delete_files | grep -i "n" ; then
    echo "Le fichier LST_FILE_FOR_THE_YEAR == : $LST_FILE_FOR_THE_YEAR"
    echo "Le fichier LST_FILE_FOR_THE_YEAR_WITH_SIZE == : $LST_FILE_FOR_THE_YEAR_WITH_SIZE"
    echo "un fois consulter les supprimer :D"
else 
    rm $LST_FILE_FOR_THE_YEAR 
    rm $LST_FILE_FOR_THE_YEAR_WITH_SIZE 
fi
