#! /usr/bin/env bash
set -e # exit on error

# Variables
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"email-smtp.us-east-1.amazonaws.com"}
export EXT_RELAY_PORT=${EXT_RELAY_PORT:-"25"}
export RELAY_HOST_NAME=${RELAY_HOST_NAME:-"relay.example.com"}
export ACCEPTED_NETWORKS=${ACCEPTED_NETWORKS:-"192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"}
export OTHER_MY_DEST

echo $RELAY_HOST_NAME > /etc/mailname

# Templates
j2 /root/conf/postfix-main.cf > /etc/postfix/main.cf

# Launch
rm -f /var/spool/postfix/pid/*.pid
exec /usr/bin/supervisord -n
