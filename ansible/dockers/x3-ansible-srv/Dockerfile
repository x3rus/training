# pull base image
FROM ubuntu:16.04
MAINTAINER Thomas Boutry <thomas.boutry@x3rus.com>

ENV DEBIAN_FRONTEND=noninteractive 

# Installation of ansible 
# J'ai volontairement PAS bloquer l'installation des packages en plus car je veux avoir une conteneur
# meme s'il est gros ca me derange pas :D
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update -y && \
    apt-get install -y ansible
    
 # Create user "c3po" with no password
 # Ajout du groupe docker pour communiquer avec le docker host
RUN useradd -s /bin/bash -m  c3po && \
    groupadd automate && \
    usermod -G automate c3po

 # Creation du répertoire ssh pour l'utilisateur
RUN mkdir /home/c3po/.ssh/ && \
    chown c3po:c3po /home/c3po/.ssh && \
    chmod 700 /home/c3po/.ssh/

 # Copie la clef publique pour jenkins 
COPY conf/id_rsa* /home/c3po/.ssh/

 # Fix perms for ssh key
RUN chown c3po:c3po /home/c3po/.ssh/id_rsa* && \
    chmod 700 /home/c3po/.ssh/id_rsa*


    
# default command: display Ansible version
ENTRYPOINT ["/usr/bin/ansible-playbook"]
CMD ["--version"]
 
