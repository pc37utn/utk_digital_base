#!/bin/bash

# Sets up a developer environment

# Install doxygen and pear for installing PHP_CodeSniffer
yum -y install php-pear doxygen

# Create a configuration script to help get a Git environment set up
sudo tee /usr/local/bin/git-config > /dev/null << GIT_CONFIG_EOF
#! /bin/bash

if [ "\$#" -eq 3 ]; then
  NAME="\$1"
  EMAIL="\$2"
  PUSH="\$3"
elif [ "\$#" -eq 2 ]; then
  NAME="\$1"
  EMAIL="\$2"
  PUSH="simple"
else
  echo 'Usage: git-config "Your Name" "your@email.com" [PUSH_DEFAULT]'
  exit 1
fi

git config --global user.name "\$NAME"
git config --global user.email "\$EMAIL"
git config --global push.default "\$PUSH"

GIT_CONFIG_EOF

chmod 755 /usr/local/bin/git-config

# Install tools used by Islandora Ant builds
wget -q https://phar.phpunit.de/phploc.phar
mv phploc.phar /usr/local/bin/phploc
chmod +x /usr/local/bin/phploc

wget -q https://phar.phpunit.de/phpcpd.phar
mv phpcpd.phar /usr/local/bin/phpcpd
chmod +x /usr/local/bin/phpcpd

wget -q http://static.pdepend.org/php/latest/pdepend.phar
mv pdepend.phar /usr/local/bin/pdepend
chmod +x /usr/local/bin/pdepend

wget -q https://github.com/mayflower/PHP_CodeBrowser/releases/download/1.1.1/phpcb-1.1.1.phar
mv phpcb-1.1.1.phar /usr/local/bin/phpcb
chmod +x /usr/local/bin/phpcb

# Coder & Code Sniffer
pear install PHP_CodeSniffer-1.5.6
