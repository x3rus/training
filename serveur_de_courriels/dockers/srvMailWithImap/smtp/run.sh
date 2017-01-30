#! /usr/bin/env bash
set -e # exit on error

# Variables
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"DIRECT"}
export SMTP_HOSTNAME=${SMTP_HOSTNAME:-"relay.example.com"}
export PERMIT_NETWORK=${PERMIT_NETWORK:-"192.168.0.0/16"}
export ACCEPT_DOMAIN=${ACCEPT_DOMAIN:-"localhost $SMTP_HOSTNAME"}

echo $SMTP_HOSTNAME > /etc/mailname

# Templates
j2 /root/postfix-main.j2 > /etc/postfix/main.cf

# Launch
rm -f /var/spool/postfix/pid/*.pid
exec /usr/bin/supervisord -n
