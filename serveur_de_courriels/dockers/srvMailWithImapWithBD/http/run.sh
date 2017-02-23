#! /usr/bin/env bash
set -e # exit on error

# Variables
export MYSQL_USER=${MYSQL_USER:-"myuser"}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-"superpass"}
export MYSQL_DATABASE=${MYSQL_DATABASE:-"mails"}
export DB_TYPE=${DB_TYPE:-"mysql"}
export MAIL_DOMAIN=${MAIL_DOMAIN:-"example.com"}
export SETUP_PASS=${SETUP_PASS:-"fkrhreiu"}

# Templates
j2 /root/config.inc.php.j2 > /var/www/html/config.inc.php

# Rappel de la commande CMD du script original
apache2-foreground 
