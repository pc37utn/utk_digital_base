#!/bin/bash

sudo systemctl restart httpd
# Set correct permissions on sites/default/files
sudo chown -R apache.apache /vhosts/digital/web/collections/sites/default/files
