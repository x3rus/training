FROM ubuntu:16.04
MAINTAINER Boutry Thomas "thomas.boutry@x3rus.com"

# install apps 
RUN apt-get update && \
    apt-get install -y apache2 vim
 
COPY start.sh /
COPY index.html /var/www/html/
EXPOSE 80

CMD ["/start.sh"]
