#!/bin/bash -x
#
# Description :
#   Valide backup after rsnapshot processes
# 
# Suggestion amélioration :
#       - Ajouter la possibilité de valider plusieur répertoire ( passer en argument )
#       - Valider plusieurs fichier ( passer en argument ) 
#       - Valider les fichiers fichier selon le hard link ( passer en argument ) 
#
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2016-02-05
# Licence : GPL v3.
###############################################################################

###############
## VARIABLES ##
RSNAPSHOT_CONF=$1
LST_FILE=$(mktemp)

# Validtion de l'argument
if ! [ -f $RSNAPSHOT_CONF ] ; then
    echo " ERROR : File don't exist ( $RSNAPSHOT_CONF ) please give me the rsnapshot configuration file as argument"
    exit 1
fi

#############
##  MAIN   ##

# Extraction des valeurs 
SNAPSHOT_ROOT=$(cat $RSNAPSHOT_CONF | grep snapshot_root | tr -s "\t" | cut -d "\t" -f 2)
NUM_DIR_BK=$(cat $RSNAPSHOT_CONF | grep ^backup | wc -l )

# pick up rendom line 
BK_CHOICE=$( echo $[ 1 + $[ RANDOM % $NUM_DIR_BK ]])

# TOTO voir pour passer un argument a sed une variable
# extract line information that I will process
#DIR_2_CHECK=$(cat $RSNAPSHOT_CONF | grep ^backup | tr "\t" " "| tr -s " "  | cut -d ":" -f 2- | sed 's/\(.*\) \(.*\)/\2\1/g' |  sed "${BK_CHOICE}q;d")
DIR_2_CHECK_REMOTE=$(cat $RSNAPSHOT_CONF | grep ^backup | tr -s "\t" | cut -d ":" -f 2 )
DIR_2_CHECK=$(cat $RSNAPSHOT_CONF | grep ^backup | tr -s "\t" | cut -d ":" -f 2 sed 's/\(.*\)i\t\(.*\)/\2\1/g' |  sed "${BK_CHOICE}q;d")

HOST_TO_CONNECT=$(cat $RSNAPSHOT_CONF | grep ^backup | tr -s "\t"  | cut -d ":" -f 1 | cut -d "\t" -f 2)


find "${SNAPSHOT_ROOT}/daily.0/${DIR_2_CHECK}" -type f -printf "%n %p \n" > $LST_FILE
if [ $? -ne 0 ] ; then
    echo "ERROR: when try to access to directory ${SNAPSHOT_ROOT}/${DIR_2_CHECK} "
    exit 1
fi

NUM_LINE_FILES=$(wc -l $LST_FILE | cut -d " " -f 1)

# pick up rendom line 
CHOICE_FIlE_RANDOM=$( echo $[ 1 + $[ RANDOM % $NUM_LINE_FILES ]])
FILE_2_CHECK=$(cat $LST_FILE | cut -d " " -f 2- |  sed "${CHOICE_FIlE_RANDOM}q;d")
FILE_2_CHECK_REMOTE=$( echo $FILE_2_CHECK | sed "s@${SNAPSHOT_ROOT}/daily.0/${DIR_2_CHECK}@@g" )

MD5SUM_BK_FILE=$(md5sum $FILE_2_CHECK)

MD5SUM_BK_FILE_REMOTE=$(ssh ${HOST_TO_CONNECT} md5sum ${DIR_2_CHECK_REMOTE}/${FILE_2_CHECK_REMOTE} | cut -d " " -f 1)

if [ "$MD5SUM_BK_FILE" = "$MD5SUM_BK_FILE_REMOTE" ] ; then
    echo "OK : $FILE_2_CHECK "
else
   echo " ERROR : $FILE_2_CHECK "
   exit 1
fi


