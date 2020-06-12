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
pear install Console_Table
systemctl restart httpd
# drush 8.1 from rhel
yum -y install drush
yum -y install mod_rewrite

#make web on large partition
mkdir /vhosts
cd /vhosts
mkdir digital
cd digital
mkdir web

# Cycle apache
systemctl restart httpd

cd /vhosts/digital
chown -R apache:apache web
chmod -R g+w web
cd /vhosts/digital/web

# Download Drupal
drush dl drupal-7.x --drupal-project-rename=collections

# Permissions
chown -R apache:apache collections
chmod -R g+w collections

# Do the install
cd /vhosts/digital/web/collections
drush si -y --db-url=mysql://root:islandora@localhost/drupal7 --site-name=digital-devel
drush user-password admin --password=islandora
cd /vhosts/digital/web/collections/sites/default
mkdir files
chown -R apache.apache files
chmod -r g+w files
chown apache.apache /vhosts/digital/web/collections/sites/default/settings.php
cd /vhosts/digital/web/collections

# Make the modules directory
if [ ! -d sites/all/modules ]; then
  mkdir -p sites/all/modules
fi
cd sites/all/modules

# Modules
sudo drush dl imagemagick ctools jquery_update views variable token libraries datepicker date
sudo drush -y en imagemagick ctools jquery_update views variable token libraries 

# php.ini templating
cp -v "$SHARED_DIR"/configs/php.ini /etc/php.ini

systemctl restart httpd

# sites/default/files ownership
chown -hR apache:apache "$DRUPAL_HOME"/sites/default/files

# Run cron
#cd "$DRUPAL_HOME"/sites/all/modules
#drush cron
