#! /usr/bin/env bash
set -e # exit on error

# Variables
export MYSQL_USER=${MYSQL_USER:-"myuser"}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-"superpass"}
export MYSQL_DATABASE=${MYSQL_DATABASE:-"mails"}
export DB_TYPE=${DB_TYPE:-"mysql"}
export MAIL_DOMAIN=${MAIL_DOMAIN:-"example.com"}
export SETUP_PASS=${SETUP_PASS:-"fkrhreiuTOTO"}
export ADM_MAIL=${ADM_MAIL:-"NOT_DEFINE"}
export ADM_PASS=${ADM_PASS:-"NOT_DEFINE"}

# Validation des variables !!
if [ "$ADM_MAIL" == "NOT_DEFINE" ] ; then
    echo 'You need to set variable $ADM_MAIL !! '
    echo "I already set all the software , I can't choose your username ;) "
    exit 1
fi
if [ "$ADM_PASS" == "NOT_DEFINE" ] ; then
    echo 'You need to set variable $ADM_PASS !! '
    echo "I already set all the software , I can't choose your PASSWORD ;) "
    exit 1
fi

# Templates
j2 /root/config.inc.php.j2 > /var/www/html/config.inc.php

# Démarrage du processus apache2 en background 
apache2-foreground &

# en attente de l'initialisation de apache TODO : mettre une solution plus belle
sleep 3

# Initilisation de la configuration de postfix :
SETUP_PASS_HASH=$(curl  -X POST -d "setup_password=$SETUP_PASS" -d "form=createadmin" http://127.0.0.1/setup.php 2>/dev/null | grep "CONF" | grep "setup_password" | sed "s/.*\$CONF\['setup_password'\] = '\(.*\)';.*/\1/g")

echo $SETUP_PASS_HASH

# Update postfix configuration file 
sed -i "s/\$CONF\['setup_password'\] = 'curl_will_change_it';/\$CONF\['setup_password'\] = \'$SETUP_PASS_HASH\';/g" /var/www/html/config.inc.php

# Creation de l'administrateur
curl  -X POST -d "setup_password=$SETUP_PASS" -d "fUsername=$ADM_MAIL" -d "fPassword=$ADM_PASS" -d "fPassword2=$ADM_PASS" -d "form=createadmin" http://127.0.0.1/setup.php | grep "Admin has been added!"

if [ $? -ne 0 ] ; then
    echo "ERROR with Admin creation :-/" 
    echo "Curl cmd : "
    echo "curl X POST -d "setup_password=$SETUP_PASS" -d "fUsername=$ADM_MAIL" -d "fPassword=$ADM_PASS" -d "fPassword2=$ADM_PASS" -d "form=createadmin" http://127.0.0.1/setup.php"
    exit 1
fi

# Show apache logs
tail -f /var/log/apache2/access.log /var/log/apache2/error.log
