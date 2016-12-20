#!/bin/bash

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

if [ ! -d "$DOWNLOAD_DIR" ]; then
  mkdir -p "$DOWNLOAD_DIR"
fi

# Update
#yum -y update

# setup timezone
sudo timedatectl set-timezone America/New_York

# utilities
yum -y install wget mc mutt screen bzip2 zip unzip ntp

# Build tools
yum -y install gcc kernel-devel kernel-headers autoconf

# add epel repo for dkms
yum -y install epel-release
yum -y install dkms

# Git vim
yum -y install git vim
# add openjdk8 java and remove openjdk7
yum -y install java-1.8.0-openjdk
echo '*******removing java openjdk7********'
yum -y remove java-1.7.0-openjdk

# Java 8 (Oracle)
wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.rpm
rpm -Uvh jdk-8*
rm -f jdk-8*
# make java 8 default with the alternatives command
sudo alternatives  --set java /usr/java/jdk1.8.0_92/jre/bin/java

# Set JAVA_HOME variable both now and for when the system restarts
export JAVA_HOME
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment

# Maven
sudo yum -y install maven

# Tomcat - from the epel repo
sudo yum -y install tomcat tomcat-admin-webapps
sudo usermod -a -G tomcat vagrant

# We still need this for the rest of the times Tomcat is run in the other build scripts
sed -i "s|#JAVA_HOME=/usr/lib/jvm/openjdk-[0-9]\+-jdk|JAVA_HOME=$JAVA_HOME|g" /etc/default/tomcat


# More helpful packages
sudo yum -y install htop tree zsh mc

# Set some params so it's non-interactive for the lamp-server install
#debconf-set-selections <<< 'mysql-server mysql-server/root_password password islandora'
#debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password islandora'
#debconf-set-selections <<< "postfix postfix/mailname string islandora-vagrant.org"
#debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

# Lamp server
sudo yum -y install mariadb-server php php-cli php-xml php-mysql httpd-devel httpd mysqlclient php-mcrypt php-mbstring
sudo systemctl enable mariadb
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl start httpd

usermod -a -G apache vagrant
mysqladmin -u root password islandora

echo "CREATE DATABASE fedora3" | mysql -uroot -pislandora
echo "CREATE USER 'fedoraAdmin'@'localhost' IDENTIFIED BY 'fedoraAdmin'" | mysql -uroot -pislandora
echo "GRANT ALL ON fedora3.* TO 'fedoraAdmin'@'localhost'" | mysql -uroot -pislandora
echo "flush privileges" | mysql -uroot -pislandora

# Add web group, and put some users in it
sudo groupadd web
sudo usermod -a -G web apache
sudo usermod -a -G web vagrant
sudo usermod -a -G web tomcat
