# Using Ubuntu
FROM ubuntu:16.04
MAINTAINER Boutry Thomas <thomas.boutry@x3rus.com>

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# Packages: update
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends dovecot-imapd dovecot-lmtpd dovecot-mysql \
        python-pip supervisor rsyslog python-wheel python-setuptools  && \
    pip install j2cli

# Configure: supervisor
ADD bin/dfg.sh /usr/local/bin/
ADD conf/supervisor-all.conf /etc/supervisor/conf.d/

# Création répertoire pour les courriels & utilisateur
RUN groupadd -g 5000 vmail && \
    useradd -g vmail -u 5000 vmail -d /var/mail && \
    chown -R vmail:vmail /var/mail 
     
# Fichier configuration Dovecot
ADD conf/10*.conf conf/auth-sql.conf.ext /etc/dovecot/conf.d/

# Fichier de configuration de mysql en template pour substitution 
ADD conf/dovecot-sql.conf.ext.j2           /root/

# Runner
ADD run.sh /root/run.sh
RUN chmod +x /root/run.sh

# Declare
EXPOSE 143 24

CMD ["/root/run.sh"]
