#!/bin/bash
#
# Description : Fix layout pour moodle 
# 
#   
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2016-01-11
# Licence : GPL v3.
###############################################################################

##########
## VARS ##

URL_TO_CHANGE=$1
HTML_FILE=$2

# Exemple :
# ../tools/fix_href_moodle.sh https://raw.githubusercontent.com/x3rus/training/master/solution_de_backup solution_de_backup.html

##########
## MAIN ##

URL_TO_CHANGE_CLEAN=$(echo $URL_TO_CHANGE | sed 's/\//\\\//g' )

sed -i "s/href=\"\.\//href=\"$URL_TO_CHANGE_CLEAN\//g" $HTML_FILE

