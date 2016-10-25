#!/bin/bash
#
#############################

# Variables
USER_BD=bob
USER_PASS=marley
DB=ma_super_BD

export IFS=$'\n'

for line in $(dmesg) ; do
    TIMESTAMP=$(echo $line | cut -d ']' -f 1 | tr -d "[" | tr -s " " )
    TEXT=$(echo $line | cut -d ']' -f 2- | tr -s " ")
    STATUS=$(shuf -i 1-3 -n 1)

    # insertion dans mysql
    mysql -u $USER_BD --password=$USER_PASS $DB -e "insert into app_article (texte,text_status,info) values (\"$TEXT\",$STATUS,\"$TIMESTAMP\");"
    mysql -u $USER_BD --password=$USER_PASS $DB -e "insert into app_inno_article (texte,text_status,info) values (\"$TEXT\",$STATUS,\"$TIMESTAMP\");"


done

