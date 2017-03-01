#! /usr/bin/env bash
set -e # exit on error

# Variables
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"DIRECT"}
export SMTP_HOSTNAME=${SMTP_HOSTNAME:-"relay.example.com"}
export PERMIT_NETWORK=${PERMIT_NETWORK:-"192.168.0.0/16"}

export DB_HOST=${DB_HOST:-"mysql"}
export DOVECOT_SRV=${DOVECOT_SRV:-"dovecot-lmtp" }

echo $SMTP_HOSTNAME > /etc/mailname

# Templates
j2 /root/postfix-main.j2 > /etc/postfix/main.cf

# Création du répertoire pour la configuration de sql
mkdir /etc/postfix/sql/

# Launch
rm -f /var/spool/postfix/pid/*.pid
exec /usr/bin/supervisord -n
