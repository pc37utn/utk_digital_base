#!/bin/bash

echo "Installing Sleuthkit."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi


# Dependencies
yum -y install afflib afflib-devel afftools libewf-devel ewftools libtool gcc-c++ libstdc++ libstdc++-devel

# Clone and compile Sleuthkit
cd /tmp
#git clone https://github.com/sleuthkit/sleuthkit.git
#cd sleuthkit && ./bootstrap && ./configure && make && make install && ldconfig
#note ( for both centos and ubuntu) Sleuthkit currently failing on HEAD tying to known good commit for now.
git clone https://github.com/sleuthkit/sleuthkit.git && cd sleuthkit && git checkout 5f8a005475c3ea3e6547c3276aea381e9804c005 && ./bootstrap && ./configure && make && make install && ldconfig
