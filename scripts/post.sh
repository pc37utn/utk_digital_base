#!/bin/bash

# Setup a user for Tomcat Manager
sed -i '$i<user username="islandora" password="islandora" roles="manager-gui"/>' /etc/tomcat/tomcat-users.xml
systemctl restart tomcat

# Set correct permissions on sites/default/files
chmod -R 775 /var/www/drupal/sites/default/files
