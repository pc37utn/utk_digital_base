#!/bin/bash

echo "Installing Drupal."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

# Apache configuration file
export APACHE_CONFIG_FILE=/etc/httpd/conf/httpd.conf
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.dist
# copy pre-made httpd.conf
cp -v "$SHARED_DIR"/configs/httpd.conf /etc/httpd/conf/httpd.conf

# Drush and drupal deps
yum -y install php-pecl-imagick ImageMagick perl-Image-Exiftool bibutils poppler-utils
#pecl install uploadprogress
#sed -i '/; extension_dir = "ext"/ a\ extension=uploadprogress.so' /etc/php.ini
#pear install Console_Table
sudo systemctl restart httpd
# drush 8.1 from rhel
sudo yum -y install drush
#yum -y install mod_rewrite

#make web on large partition
mkdir /vhosts
cd /vhosts
mkdir digital
cd digital
mkdir web

# Cycle apache
sudo systemctl restart httpd

cd /vhosts/digital/web

# Download Drupal
drush dl drupal-7.x --drupal-project-rename=collections

# Permissions
chown -R apache:apache collections
chmod -R g+w collections

# Do the install
cd collections
drush si -y --db-url=mysql://root:islandora@localhost/drupal7 --site-name=digital-devel
drush user-password admin --password=islandora

chown apache.apache /vhosts/digital/web/collections/sites/default/settings.php
# Cycle apache
systemctl restart httpd

# Make the modules directory
if [ ! -d sites/all/modules ]; then
  mkdir -p sites/all/modules
fi
cd sites/all/modules

# Modules
drush dl devel imagemagick ctools jquery_update views variable token libraries datepicker date
sudo drush -y en devel imagemagick ctools jquery_update views variable token libraries datepicker_views

# php.ini templating
#cp -v "$SHARED_DIR"/configs/php.ini /etc/php.ini

systemctl restart httpd

# sites/default/files ownership
chown -hR apache:apache "$DRUPAL_HOME"/sites/default/files

# Run cron
#cd "$DRUPAL_HOME"/sites/all/modules
#drush cron
