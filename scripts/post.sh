#!/bin/bash

# Setup a user for Tomcat Manager ( updated to "manager-gui")
sudo sed -i '$i<user username="islandora" password="islandora" roles="manager-gui"/>' /etc/tomcat/tomcat-users.xml
sudo systemctl restart tomcat
sudo sleep 30
sudo systemctl restart httpd
# Set correct permissions on sites/default/files
sudo chown -R apache.apache /vhosts/digital/web/collections/sites/default/files
