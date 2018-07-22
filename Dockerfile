# Mostly cribbed from
# https://github.com/webitdesign/docker-letsencrypt-cron.git

FROM python:3-alpine

VOLUME /etc/letsencrypt

# Pull in system stuff, as well as a patched version of certbot-plugin-gandi.
RUN apk add --no-cache --virtual .build-deps linux-headers gcc musl-dev \
  && apk add --no-cache git libffi-dev openssl-dev dialog \
  && pip install \
    setuptools wheel ruamel.yaml certbot \
    'git+https://github.com/girtsf/certbot-plugin-gandi.git@359eb53f0e095e0b8966ed7e60cee9d4a3b917ca' \
    --no-cache-dir \
  && apk del .build-deps \
  && mkdir /scripts
