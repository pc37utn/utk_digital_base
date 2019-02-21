#!/bin/bash

sudo systemctl restart httpd
# Set correct permissions on sites/default/files
sudo chown -R apache.apache /vhosts/digital/web/collections/sites/default/files
cd /vhosts/digital/web/collections
drush vset islandora_openseadragon_tilesource 'iiif'
drush vset islandora_openseadragon_iiif_url 'http://localhost:8000/iiif/2'
drush vset islandora_openseadragon_iiif_token_header 1
drush vset islandora_openseadragon_iiif_identifier '[islandora_openseadragon:pid]~[islandora_openseadragon:dsid]~[islandora_openseadragon:token]'

drush vset islandora_internet_archive_bookreader_iiif_identifier '[islandora_iareader:pid]~[islandora_iareader:dsid]~[islandora_iareader:token]'
drush vset islandora_internet_archive_bookreader_iiif_url 'http://localhost:8000/iiif/2'
drush vset islandora_internet_archive_bookreader_iiif_token_header 1
drush vset islandora_internet_archive_bookreader_pagesource 'iiif'
