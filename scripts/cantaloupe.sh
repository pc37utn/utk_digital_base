#!/bin/bash

SHARED_DIR=$1

# Apache configuration file
export APACHE_CONFIG_FILE=/etc/httpd/conf/httpd.conf


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
  
 
if [ ! -f "$DOWNLOAD_DIR/Cantaloupe.zip" ]; then
  echo "Downloading Cantaloupe"
  wget -q -O "$DOWNLOAD_DIR/Cantaloupe.zip" "https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip"
fi
  
cd /tmp || exit
cp "$DOWNLOAD_DIR/Cantaloupe.zip" /tmp
unzip Cantaloupe.zip
cd Cantaloupe-"$CANTALOUPE_VERSION" || exit
mv -v ./* "$CANTALOUPE_HOME"

# Deploy Cantaloupe
cp -v "$CANTALOUPE_HOME"/Cantaloupe-"$CANTALOUPE_VERSION".war /var/lib/tomcat/webapps/cantaloupe.war
chown tomcat:tomcat /var/lib/tomcat/webapps/cantaloupe.war

# Libraries
cp "$SHARED_DIR"/configs/cantaloupe.properties "$CANTALOUPE_HOME"
cp "$SHARED_DIR"/configs/delegates.rb "$CANTALOUPE_HOME"/delegates.rb

chown -R tomcat:tomcat "$CANTALOUPE_HOME"
chown -R tomcat:tomcat "$CANTALOUPE_LOGS"
chown -R tomcat:tomcat "$CANTALOUPE_CACHE"

# Make tomcat/VM aware of cantaloup's config.
# shellcheck disable=SC2016
echo 'JAVA_OPTS="${JAVA_OPTS} -Dcantaloupe.config=/usr/local/cantaloupe/cantaloupe.properties -Dorg.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true"' >> /etc/profile.d/islandora.sh

# add cantaloupe proxy pass.
if [ "$(grep -c "iiif" $APACHE_CONFIG_FILE)" -eq 0 ]; then

read -r -d '' APACHE_CONFIG << APACHE_CONFIG_TEXT
   AllowEncodedSlashes NoDecode

   ProxyPass /iiif/2 http://localhost:8080/cantaloupe/iiif/2 nocanon
   ProxyPassReverse /iiif/2 http://localhost:8080/cantaloupe/iiif/2

   #RequestHeader set X-Forwarded-Port 8000
   RequestHeader set X-Forwarded-Proto "http" env=HTTP
   RequestHeader set X-Forwarded-Path "/"

APACHE_CONFIG_TEXT

sed -i "/<\/VirtualHost>/i $(echo "|$APACHE_CONFIG" | tr '\n' '|')" $APACHE_CONFIG_FILE
tr '|' '\n' < $APACHE_CONFIG_FILE > $APACHE_CONFIG_FILE.t 2> /dev/null; mv $APACHE_CONFIG_FILE{.t,}

fi


#OpenJPEG from centos equivalent
yum -y install openjpeg openjpeg-devel openjpeg2 openjpeg2-devel libpng-devel libpng libtiff libtiff-devel libtiff-tools

# Sleep for 60 while Tomcat restart
echo "Sleeping for 30 while Tomcat stack restarts"
systemctl restart tomcat
sleep 30
systemctl restart httpd
sleep 5
