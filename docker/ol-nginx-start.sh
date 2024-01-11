#!/bin/bash

# Initialize an empty string for the certbot options
certbot_options=""

RUN_CERTBOT=0

# Iterate through the NGINX_DOMAIN variable and construct the certbot options
for domain in $NGINX_DOMAIN; do
  certbot_options+=" -d $domain"
  if [ -d "/etc/letsencrypt/live/$domain" ]; then
    RUN_CERTBOT=1
  fi
done

# Check if certbot_options is not empty before executing certbot
if [ "$RUN_CERTBOT" -eq 1 ]; then
  certbot certonly --webroot --webroot-path /openlibrary/static $certbot_options
fi

if [ -n "$CRONTAB_FILES" ] ; then
  cat $CRONTAB_FILES | crontab -
  service cron start
fi

# logrotate comes from olsystem which is volume mounted
# logrotate requires files to be 644 and owned by root??? (WHAT)
# expect conflicts writing to file
chmod 644 /etc/logrotate.d/nginx
chown root:root /etc/logrotate.d/nginx
logrotate --verbose /etc/logrotate.d/nginx

nginx -g "daemon off;"
