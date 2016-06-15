#!/bin/bash

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

if [ ! -d "$DOWNLOAD_DIR" ]; then
  mkdir -p "$DOWNLOAD_DIR"
fi

# Update
yum -y update

# utilities
yum -y install wget bzip2 zip unzip ntp

# Build tools
yum -y install gcc kernel-devel kernel-headers autoconf

# add epel repo for dkms
yum -y install epel-release
yum -y install dkms

# Git vim
yum -y install git vim

# Java 8 (Oracle)
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.rpm
rpm -Uvh jdk-8*
rm -f jdk-8*

# Set JAVA_HOME variable both now and for when the system restarts
export JAVA_HOME
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment

# Maven
yum install maven

# Tomcat - from the epel repo
yum -y install tomcat tomcat-admin-webapps
usermod -a -G tomcat vagrant

# We still need this for the rest of the times Tomcat is run in the other build scripts
sed -i "s|#JAVA_HOME=/usr/lib/jvm/openjdk-[0-9]\+-jdk|JAVA_HOME=$JAVA_HOME|g" /etc/default/tomcat


# More helpful packages
yum -y install htop tree zsh 

# Set some params so it's non-interactive for the lamp-server install
#debconf-set-selections <<< 'mysql-server mysql-server/root_password password islandora'
#debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password islandora'
#debconf-set-selections <<< "postfix postfix/mailname string islandora-vagrant.org"
#debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

# Lamp server
yum install mariadb-server php php-cli php-xml php-mysql httpd-devel httpd mysqlclient
systemctl enable mariadb
systemctl enable httpd
systemctl start mariadb
systemctl start httpd

usermod -a -G apache vagrant
sudo mysqladmin -u root password islandora

echo "CREATE DATABASE fedora3" | mysql -uroot -pislandora
echo "CREATE USER 'fedoraAdmin'@'localhost' IDENTIFIED BY 'fedoraAdmin'" | mysql -uroot -pislandora
echo "GRANT ALL ON fedora3.* TO 'fedoraAdmin'@'localhost'" | mysql -uroot -pislandora
echo "flush privileges" | mysql -uroot -pislandora

# Add web group, and put some users in it
groupadd web
usermod -a -G web apache
usermod -a -G web vagrant
usermod -a -G web tomcat
