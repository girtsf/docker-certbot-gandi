#!/bin/bash

set -o errexit
set -o pipefail

function check_var() {
  local var_name="$1"
  if [ "${!var_name}" == "" ]; then
    echo "Variable ${var_name} not defined!"
    exit 1
  fi
}

function main() {
  if [ ! -e 'config.sh' ]; then
    echo 'You must create config.sh!'
    exit 1
  fi

  if [ ! -e 'etc_letsencrypt/gandi.ini' ]; then
    echo 'You must create etc_letsencrypt/gandi.ini!'
    exit 1
  fi

  source config.sh

  check_var CERT_NAME
  check_var EMAIL
  check_var DOMAINS
  : ${DRY_RUN:=}

  local domain_str
  local d
  for d in ${DOMAINS}; do
    domain_str="${domain_str} -d ${d}"
  done

  docker run -it --rm --name certbot \
      -v "$(pwd)/etc_letsencrypt:/etc/letsencrypt" \
      certbot-gandi \
      /usr/local/bin/certbot \
      certonly \
      --keep-until-expiring \
      --non-interactive \
      --agree-tos \
      --renew-with-new-domains \
      --cert-name "${CERT_NAME}" \
      --email "${EMAIL}" \
      --authenticator certbot-plugin-gandi:dns \
      --certbot-plugin-gandi:dns-credentials /etc/letsencrypt/gandi.ini \
      --debug \
      ${DRY_RUN} \
      ${domain_str} \
      "$@"
}

main
