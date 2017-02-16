#!/bin/bash
#
#########################################################################################
set -e # exit on error

user=$1
pass=$2

export LST_MAILS=${LST_MAILS:-"/etc/dovecot/mails.lst"}

if ! getent passwd $user ; then 
    useradd $user
    mkdir /home/$user
    chown $user /home/$user         
    # set password motpasse         
    echo "${user}:$pass" | chpasswd 

    # Création de la liste des adresses courriels valides 
    echo "$user@$ACCEPT_DOMAIN OK" >> $LST_MAILS 
fi

