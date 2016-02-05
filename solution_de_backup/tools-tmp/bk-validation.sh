#!/bin/bash
#
# Description :
#   Valide backup after rsnapshot processes
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2016-02-05
# Licence : GPL v3.
###############################################################################

###############
## VARIABLES ##

RSNAPSHOT_CONF=$1

# Validtion de l'argument
if ! [ -f $RSNAPSHOT_CONF ] ; then
    echo " ERROR : File don't exist ( $RSNAPSHOT_CONF ) please give me the rsnapshot configuration file as argument"
    exit 1
fi

#############
##  MAIN   ##

# Extraction des valeurs 
SNAPSHOT_ROOT=$(cat $RSNAPSHOT_CONF | grep snapshot_root | tr "\t" " " | tr -s " " | cut -d " " -f 2)
NUM_DIR_BK=$(cat $RSNAPSHOT_CONF | grep ^backup | tr "\t" " "| tr -s " "  | cut -d ":" -f 2- | sed 's/\(.*\) \(.*\)/\2\1/g' | wc -l)

# pick up rendom line 
BK_CHOICE=$( echo $[ 1 + $[ RANDOM % $NUM_DIR_BK ]])

# TOTO voir pour passer un argument a sed une variable
# extract line information that I will process
cat $RSNAPSHOT_CONF | grep ^backup | tr "\t" " "| tr -s " "  | cut -d ":" -f 2- | sed 's/\(.*\) \(.*\)/\2\1/g' |  sed '$BK_CHOICEq;d'



