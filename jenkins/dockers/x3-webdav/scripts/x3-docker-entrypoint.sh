#!/bin/bash

# set variables
export VERBOSE=${VERBOSE:-"FALSE"}
export USERS_PASS=${USERS_PASS:-"None"}
export PASSWORDFILE=${PASSWORDFILE:-"/usr/local/apache2/user.passwd"}

f_create_password_file () {
    echo "Create password file "

    for user_p in $USERS_PASS
    do
        username=$(echo $user_p | cut -d "=" -f 1) 
        userpass=$(echo $user_p | cut -d "=" -f 2)

        if [ -e $PASSWORDFILE ] ; then
            /usr/local/apache2/bin/htpasswd -b $PASSWORDFILE $username $userpass
            if [ $? -ne 0 ] ; then echo "ERROR creating password file : $PASSWORDFILE " && exit 1 ; fi
        else
            /usr/local/apache2/bin/htpasswd -b -c $PASSWORDFILE $username $userpass
            if [ $? -ne 0 ] ; then echo "ERROR creating password file : $PASSWORDFILE " && exit 1 ; fi
        fi
    done

} # END f_create_password_file

# Check if password user file exist
if [ -e $PASSWORDFILE ] ; then
    echo "Volume or file already created , no action "
else
    if [ "$USERS_PASS" == "None" ]; then
        echo "ERROR : password file don't exist AND variable \$USERS_PASS not define"
        exit 1
    else
        f_create_password_file
    fi # variable validation
fi # htpasswd file exist

httpd-foreground
