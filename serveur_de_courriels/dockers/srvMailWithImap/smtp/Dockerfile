# Using debian
# Start Exemple:
# ou can add -p 25:25 for LAN access
FROM ubuntu:16.04
MAINTAINER Boutry Thomas <thomas.boutry@x3rus.com>

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# Packages: update
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends postfix \
        python-pip supervisor rsyslog python-wheel python-setuptools  && \
    pip install j2cli

# TODO mettre l'installation dans le layer précédent 
RUN apt-get install --no-install-recommends incron 

# Configure: supervisor
ADD bin/dfg.sh /usr/local/bin/
ADD conf/supervisor-all.conf /etc/supervisor/conf.d/

# Setup postfix conf
ADD conf/postfix-main.j2 /root/

# Runner
ADD run.sh /root/run.sh
RUN chmod +x /root/run.sh

# Declare
EXPOSE 25

CMD ["/root/run.sh"]
