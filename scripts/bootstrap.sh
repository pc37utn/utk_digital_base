#!/bin/bash

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

if [ ! -d "$DOWNLOAD_DIR" ]; then
  mkdir -p "$DOWNLOAD_DIR"
fi
# for setting the env variables in a non-vagrant startup
# make etc/profile.d/islandora.sh
touch /etc/profile.d/islandora.sh
echo "export CATALINA_HOME="$CATALINA_HOME >> /etc/profile.d/islandora.sh
echo "export FEDORA_HOME="$FEDORA_HOME >> /etc/profile.d/islandora.sh
echo "export DRUPAL_HOME="$DRUPAL_HOME >> /etc/profile.d/islandora.sh
echo "export HOME_DIR=/home/vagrant" >> /etc/profile.d/islandora.sh
echo "export SHARED_DIR=/vagrant" >> /etc/profile.d/islandora.sh
echo "export DOWNLOAD_DIR=/downloads" >> /etc/profile.d/islandora.sh
echo "export DJATOKA_HOME=/usr/local/djatoka" >> /etc/profile.d/islandora.sh
echo "export SOLR_HOME=/usr/local/solr" >> /etc/profile.d/islandora.sh
echo "export FITS_HOME=/usr/local/fits" >> /etc/profile.d/islandora.sh
echo "export FITS_VERSION=1.2.0" >> /etc/profile.d/islandora.sh
echo "export CANTALOUPE_HOME="$CANTALOUPE_HOME >> /etc/profile.d/islandora.sh
echo "export CANTALOUPE_CACHE="$CANTALOUPE_CACHE >> /etc/profile.d/islandora.sh
echo "export CANTALOUPE_LOGS="$CANTALOUPE_LOGS >> /etc/profile.d/islandora.sh
echo "export JAVA_OPTS="$JAVA_OPTS -Dcantaloupe.config=/usr/local/cantaloupe/cantaloupe.properties \
 -Dorg.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true" >> /etc/profile.d/islandora.sh


source /etc/profile.d/islandora.sh

# add epel repo
sudo yum -y install epel-release

# update everything
sudo yum update

# setup timezone
sudo timedatectl set-timezone America/New_York

# disable selinux
sudo sed -i 's|SELINUX=enforcing$|SELINUX=disabled|' /etc/selinux/config
sudo touch /.autorelabel

# utilities and build tools
sudo yum -y install wget mc zip unzip ntp psmisc gcc kernel-devel kernel-headers autoconf git vim htop tree mc zsh net-tools
# recent (Jan 2019) changes have kept php 7.2 from working.
# add remi repo and enable php56
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-plugin-priorities
sudo yum-config-manager --enable remi-php56


# Lamp server
sudo yum -y install httpd mariadb-server httpd-devel mysqlclient 
sudo yum -y install php php-devel php-cli php-mysql php-mcrypt php-mbstring php-gd php-xml php-soap php-curl
sudo systemctl enable mariadb
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl start httpd

# add openjdk8 java 
sudo yum -y install java-1.8.0-openjdk

# Set JAVA_HOME variable both now and for when the system restarts
export JAVA_HOME
JAVA_HOME=/usr/lib/jvm/java
echo "JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/islandora.sh

# Maven
sudo yum -y install maven ant

# Tomcat - from the centos repo
sudo yum -y install tomcat tomcat-admin-webapps
sudo usermod -a -G tomcat vagrant
sudo systemctl enable tomcat
sudo systemctl stop tomcat
sleep 30
# Setup a user for Tomcat Manager ( updated to "manager-gui")
sudo sed -i '$i<role rolename="manager-gui"/>' /etc/tomcat/tomcat-users.xml
sudo sed -i '$i<user username="islandora" password="islandora" roles="manager-gui"/>' /etc/tomcat/tomcat-users.xml
sudo systemctl restart tomcat

sudo usermod -a -G apache vagrant
sudo mysqladmin -u root password islandora

echo "CREATE DATABASE fedora3" | mysql -uroot -pislandora
echo "CREATE USER 'fedoraAdmin'@'localhost' IDENTIFIED BY 'fedoraAdmin'" | mysql -uroot -pislandora
echo "GRANT ALL ON fedora3.* TO 'fedoraAdmin'@'localhost'" | mysql -uroot -pislandora
echo "CREATE DATABASE drupal7" | mysql -uroot -pislandora
echo "flush privileges" | mysql -uroot -pislandora

# Add web group, and put some users in it
sudo groupadd web
sudo usermod -a -G web apache
sudo usermod -a -G web vagrant
sudo usermod -a -G web tomcat
