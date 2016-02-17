#!/bin/bash
#
# Description : Fix layout pour moodle pour l'affichage des section <code>
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2016-01-11
# Licence : GPL v3.
###############################################################################

##########
## VARS ##

HTML_FILE=$1


##########
## MAIN ##

sed -i  's/<pre><code>/<pre><span style="font-size: small;"><code>/g' $HTML_FILE 

