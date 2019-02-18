#!/bin/bash

SHARED_DIR=$1

# Apache configuration file
export APACHE_CONFIG_FILE=/etc/apache2/sites-enabled/000-default.conf


if [ -f "$SHARED_DIR/configs/variables" ]; then
# shellcheck disable=SC1090
  . "$SHARED_DIR/configs/variables"
fi

echo "Installing Cantaloupe"

# Setup install path and download Cantaloupe
if [ ! -d "$CANTALOUPE_HOME" ]; then
  mkdir  -p "$CANTALOUPE_HOME"
fi
if [ ! -d "$CANTALOUPE_LOGS" ]; then
  mkdir  -p "$CANTALOUPE_LOGS"
fi
if [ ! -d "$CANTALOUPE_CACHE" ]; then
  mkdir  -p "$CANTALOUPE_CACHE"
fi
  
