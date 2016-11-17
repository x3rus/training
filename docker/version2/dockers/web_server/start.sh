#!/bin/bash
#
###############################################

/etc/init.d/apache2 start

tail -f /var/log/apache2/access.log
