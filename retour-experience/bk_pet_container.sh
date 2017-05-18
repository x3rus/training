#!/bin/bash
#
# Autheur : Thomas.boutry@x3rus.com
# Licence : GPL v3
#
######################################################

LST_CONTAINER_RUNNING=$(docker ps | tr -s " " | cut -d " " -f 1,2 | cut -d ":" -f 1 | grep -v CONTAI | tr " " "_")

for container in $LST_CONTAINER_RUNNING 
do
    CONTAINER_ID=$(echo $container | cut -d "_" -f 1)
    CONTAINER_NAME=$(echo $container | cut -d "_" -f 2)

    echo "Realisation sauvegarde de $CONTAINER_NAME"
    docker commit $CONTAINER_ID $CONTAINER_NAME:running
done
