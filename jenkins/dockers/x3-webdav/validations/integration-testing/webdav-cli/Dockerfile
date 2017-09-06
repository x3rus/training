# Description : Test client webdav 
#
# Author : Thomas Boutry <thomas.boutry@x3rus.com>
# Licence : GPLv3+

FROM python:3.5
MAINTAINER Thomas Boutry "thomas.boutry@x3rus.com"

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /x3-apps/
COPY apps/requirements.txt /x3-apps/
RUN pip install --no-cache-dir -r /x3-apps/requirements.txt

COPY apps/* /x3-apps/

CMD ["python3", "/x3-apps/webdav-validation.py", "-v" ]
