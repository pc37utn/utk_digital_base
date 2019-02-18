#!/bin/bash

# Setup a user for Tomcat Manager ( updated to "manager-gui")
sed -i '$i<user username="islandora" password="islandora" roles="manager-gui"/>' /etc/tomcat/tomcat-users.xml
systemctl restart tomcat

# Set correct permissions on sites/default/files
chmod -R 775 /vhosts/digital/web/collections/sites/default/files
