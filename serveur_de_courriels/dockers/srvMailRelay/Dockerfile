# Using debian
# Start Exemple:
# docker run -d -h relay.dck.example.com --name="mailrelay" -e ENABLE_SASL_AUTH no -e EXT_RELAY_HOST=relais.videotron.ca -e ACCEPTED_NETWORKS=172.17.0.0/16 srvMailRelay
# ou can add -p 25:25 for LAN access
FROM debian:jessie
MAINTAINER Uri Savelchev <alterrebe@gmail.com>

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# Packages: update
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends postfix ca-certificates \
        libsasl2-modules python-pip supervisor rsyslog && \
    pip install j2cli

# Fix timezone
RUN ln -s -f /usr/share/zoneinfo/Canada/Eastern /etc/localtime
    
# Add files
ADD conf /root/conf

# Configure: supervisor
ADD bin/dfg.sh /usr/local/bin/
ADD conf/supervisor-all.conf /etc/supervisor/conf.d/

# Runner
ADD run.sh /root/run.sh
RUN chmod +x /root/run.sh

# Declare
EXPOSE 25

CMD ["/root/run.sh"]
