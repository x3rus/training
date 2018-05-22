#
# Description : Ansible Slave / machine pour formation
#
# Author : Thomas.boutry@x3rus.com
# Licence : GPLv3 ou plus
#
# Reference : https://docs.docker.com/engine/examples/running_ssh_service/#build-an-eg_sshd-image
###########################################################

FROM ubuntu:16.04
MAINTAINER Thomas Boutry "thomas.boutry@x3rus.com"

 # Installation des applications, besoin de ssh et de java pour le service Jenkins
RUN apt-get update && \
    apt-get install -y openssh-server sudo git python && \
    mkdir /var/run/sshd

 # TODO besoin client ansible / python ??

 # ajout des package oublié :P 
 # Valider si requis ou juste Jenkins RUN apt-get install -y libltdl7 git 

 # SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile && \
    echo "%automate ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


 # Create user "r2d2" with no password
 # Ajout du groupe docker pour communiquer avec le docker host
RUN useradd -s /bin/bash -m  r2d2 && \
    groupadd automate && \
    usermod -G sudo,automate r2d2

 # Creation du répertoire ssh pour l'utilisateur
RUN mkdir /home/r2d2/.ssh/ && \
    chown r2d2:r2d2 /home/r2d2/.ssh && \
    chmod 700 /home/r2d2/.ssh/

 # Copie la clef publique pour jenkins 
COPY conf/authorized_keys /home/r2d2/.ssh/authorized_keys

 # Fix perms for ssh key
RUN chown r2d2:r2d2 /home/r2d2/.ssh/authorized_keys && \
    chmod 700 /home/r2d2/.ssh/authorized_keys

 # Port et service
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
