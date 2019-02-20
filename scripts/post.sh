#!/bin/bash

# Setup a user for Tomcat Manager ( updated to "manager-gui")
sed -i '$i<user username="islandora" password="islandora" roles="manager-gui"/>' /etc/tomcat/tomcat-users.xml
systemctl restart tomcat
sleep 30
systemctl restart httpd
# Set correct permissions on sites/default/files
chown -R apache.apache /vhosts/digital/web/collections/sites/default/files
