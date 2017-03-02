#! /usr/bin/env bash
set -e # exit on error

# Launch
rm -f /var/run/dovecot/*.pid  
exec /usr/bin/supervisord -n
