#!/bin/bash
#
# Description : Creation de l'index pour le markdown 
#   
#   
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2016-01-07
# Licence : GPL v3.
###############################################################################

###########
## VARS  ##

# TODO : mettre un systeme de passage d'argument
FILE_IN=$1
FILE_OUT=$2
DEFAULT_SPACE=4

###########
## MAIN  ##

TOC_BRUT=$(cat $FILE_IN | grep "^#" | tr "#" "*" | sed 's/\(\**\s*\)<a name=\"\(.*\)\"\s*\/>\(.*\)/\1 [\3](#\2) /g' \
    | sed 's/$/\$/g')

IFS='$'
for One_line in $TOC_BRUT ; do
    unset SPACE
    NUM_START=$(echo $One_line | grep "^*" |  awk -F "*"  '{print  NF-1 }')
    # REF : http://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
    if [ $NUM_START -gt 1 ] ;then
        NUM_SPACE=$(( $NUM_START * $DEFAULT_SPACE))
        SPACE=$(seq -s " " $NUM_SPACE| tr -d '[:digit:]' )
    fi
    LINE_INFO=$(echo $One_line | grep "^*" | cut -d " " -f 2-)

    echo "$SPACE*$LINE_INFO"
done


