#!/bin/bash

echo "Installing Drupal."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

# Apache configuration file
#export APACHE_CONFIG_FILE=/etc/apache2/sites-enabled/000-default.conf
export APACHE_CONFIG_FILE=/etc/httpd/conf/httpd.conf


# Drush and drupal deps
yum -y install php-gd php-devel php-xml php-soap php-curl
yum -y install php-pecl-imagick ImageMagick perl-Image-Exiftool bibutils poppler-utils
pecl install uploadprogress
sed -i '/; extension_dir = "ext"/ a\ extension=uploadprogress.so' /etc/php.ini
# drush 8.1 from rhel
yum -y install drush
#yum -y install mod_rewrite
#a2enmod rewrite
systemctl restart httpd
cd /var/www

# Download Drupal
drush dl drupal-7.x --drupal-project-rename=drupal

# Permissions
chown -R apache:apache drupal
chmod -R g+w drupal

# Do the install
cd drupal
drush si -y --db-url=mysql://root:islandora@localhost/drupal7 --site-name=islandora-development.org
drush user-password admin --password=islandora
#================================ NEXT HERE
# Enable proxy module
#ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/proxy.load
#ln -s /etc/apache2/mods-available/proxy_http.load /etc/apache2/mods-enabled/proxy_http.load
#ln -s /etc/apache2/mods-available/proxy_html.load /etc/apache2/mods-enabled/proxy_html.load
#ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load

# Set document root
sed -i "s|DocumentRoot /var/www/html$|DocumentRoot $DRUPAL_HOME|" $APACHE_CONFIG_FILE

# Set override for drupal directory
# Now inserting into VirtualHost container - whikloj (2015-04-30)
if [ "$(grep -c "ProxyPass" $APACHE_CONFIG_FILE)" -eq 0 ]; then

sed -i 's#<VirtualHost \*:80>#<VirtualHost \*:8000>#' $APACHE_CONFIG_FILE

sed -i 's/Listen 80/Listen \*:8000/' /etc/httpd/conf.d/ports.conf

sed -i "/Listen \*:8000/a \
NameVirtualHost \*:8000" /etc/httpd/conf.d/ports.conf

read -d '' APACHE_CONFIG << APACHE_CONFIG_TEXT
	ServerAlias islandora-vagrant

	<Directory ${DRUPAL_HOME}>
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ProxyRequests Off
	ProxyPreserveHost On

	<Proxy *>
		Require all granted
	</Proxy>

	ProxyPass /fedora/get http://localhost:8080/fedora/get
	ProxyPassReverse /fedora/get http://localhost:8080/fedora/get
	ProxyPass /fedora/services http://localhost:8080/fedora/services
	ProxyPassReverse /fedora/services http://localhost:8080/fedora/services
	ProxyPass /fedora/describe http://localhost:8080/fedora/describe
	ProxyPassReverse /fedora/describe http://localhost:8080/fedora/describe
	ProxyPass /fedora/risearch http://localhost:8080/fedora/risearch
	ProxyPassReverse /fedora/risearch http://localhost:8080/fedora/risearch
	ProxyPass /adore-djatoka http://localhost:8080/adore-djatoka
	ProxyPassReverse /adore-djatoka http://localhost:8080/adore-djatoka
APACHE_CONFIG_TEXT

sed -i "/<\/VirtualHost>/i $(echo "|	$APACHE_CONFIG" | tr '\n' '|')" $APACHE_CONFIG_FILE
tr '|' '\n' < $APACHE_CONFIG_FILE > $APACHE_CONFIG_FILE.t 2> /dev/null; mv $APACHE_CONFIG_FILE{.t,}

fi

# Torch the default index.html
rm /var/www/html/index.html

# Cycle apache
systemctl restart httpd

# Make the modules directory
if [ ! -d sites/all/modules ]; then
  mkdir -p sites/all/modules
fi
cd sites/all/modules

# Modules
drush dl devel imagemagick ctools jquery_update pathauto xmlsitemap views variable token libraries datepicker date
drush -y en devel imagemagick ctools jquery_update pathauto xmlsitemap views variable token libraries datepicker_views

drush dl coder-7.x-2.5
drush -y en coder

# php.ini templating
cp -v "$SHARED_DIR"/configs/php.ini /etc/php.ini

systemctl restart httpd

# sites/default/files ownership
chown -hR apache:apache "$DRUPAL_HOME"/sites/default/files

# Run cron
cd "$DRUPAL_HOME"/sites/all/modules
drush cron
