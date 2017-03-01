#! /usr/bin/env bash
set -e # exit on error

# Variables
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"DIRECT"}
export SMTP_HOSTNAME=${SMTP_HOSTNAME:-"relay.example.com"}
export PERMIT_NETWORK=${PERMIT_NETWORK:-"192.168.0.0/16"}

export DB_HOST=${DB_HOST:-"db"}
export DOVECOT_SRV=${DOVECOT_SRV:-"dovecot-lmtp" }

echo $SMTP_HOSTNAME > /etc/mailname

# Templates
j2 /root/postfix-main.j2 > /etc/postfix/main.cf


# génération des fichiers de configuration SQL pour postfix
for sql_file in /root/sql/*.j2 ; do
    filename=$(basename $sql_file) 
    filedst="/etc/postfix/${filename::-3}"
    j2 $sql_file > $filedst
done


# Launch
rm -f /var/spool/postfix/pid/*.pid
exec /usr/bin/supervisord -n
