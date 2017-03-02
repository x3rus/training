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

# TODO : a supprimer tempo exploration, je le définie dans l'image pour réduire
# la différence retourné avec docker diff :D
RUN apt-get -qq -y  install vim telnet mysql-client

# Configure: supervisor
ADD bin/dfg.sh /usr/local/bin/
ADD conf/supervisor-all.conf /etc/supervisor/conf.d/

# Runner
ADD run.sh /root/run.sh
RUN chmod +x /root/run.sh

# Declare
EXPOSE 143 24

CMD ["/root/run.sh"]
