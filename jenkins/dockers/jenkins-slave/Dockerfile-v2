#
# Description : Jenkins Slave pour formation
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
    apt-get install -y openssh-server sudo openjdk-8-jre && \
    mkdir /var/run/sshd

 # ajout des package oublié :P 
RUN apt-get install -y libltdl7 git 

 # SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


 # Create default user "jenkinbot" with password toto
 # Ajout du groupe docker pour communiquer avec le docker host
RUN useradd -s /bin/bash -m  jenkinbot && \
    echo "jenkinbot:toto" | chpasswd && \
    groupadd -g 994 docker && \
    usermod -G sudo,docker jenkinbot

 # Creation du répertoire ssh pour l'utilisateur
RUN mkdir /home/jenkinbot/.ssh/ && \
    chown jenkinbot:jenkinbot /home/jenkinbot/.ssh && \
    chmod 700 /home/jenkinbot/.ssh/

 # Copie la clef publique pour jenkins 
COPY conf/authorized_keys /home/jenkinbot/.ssh/authorized_keys

 # Fix perms
RUN chown jenkinbot:jenkinbot /home/jenkinbot/.ssh/authorized_keys && \
    chmod 700 /home/jenkinbot/.ssh/authorized_keys

 # Port et service
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
