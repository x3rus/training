#! /usr/bin/env bash
set -e # exit on error

# Variables
export LST_USERS=${LST_USERS:"NONE"}

export LST_MAILS=${LST_MAILS:"/etc/dovecot/mails-$ACCEPT_DOMAIN.lst"}

# Création des utilisateurs 
if [ "$LST_USERS" == "NONE" ] ; then
    echo "You must define variable LST_USER to create at leat one user !!"
    exit 2
fi

# Creation des utilisateur 
for user in $LST_USER ; do
        adduser $user
        # set password motpasse 
        echo "${user}:motpasse" | chpasswd 

        # Création de la liste des adresses courriels valides 
        echo "$user@$ACCEPT_DOMAIN OK" >> $LST_MAILS 
done


# Launch
rm -f /var/run/dovecot/*.pid  
exec /usr/bin/supervisord -n
