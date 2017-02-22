#! /usr/bin/env bash
set -e # exit on error

# Variables
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"DIRECT"}
export SMTP_HOSTNAME=${SMTP_HOSTNAME:-"relay.example.com"}
export PERMIT_NETWORK=${PERMIT_NETWORK:-"192.168.0.0/16"}
export ACCEPT_DOMAIN=${ACCEPT_DOMAIN:-"localhost $SMTP_HOSTNAME"}

MYSQL_USER=${MYSQL_USER:-"myuser"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"superpass"}
MYSQL_DATABASE=${MYSQL_DATABASE:-"mails"}
DB_TYPE=${DB_TYPE:-"mysql"}
MAIL_DOMAIN=${MAIL_DOMAIN:-"example.com"}
SETUP_PASS=${SETUP_PASS:-"fkrhreiu"}

# Templates
j2 /root/config.inc.php.j2 > /var/www/html/config.inc.php

echo "toto" > /root/toto
