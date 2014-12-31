#!/bin/sh
set -e
# Install JS packages
bower install
# Install tools for signing XPI files
# If we have OpenSSL, we don't need M2Crypto, although it is recommended
# easy_install -Z M2Crypto
sudo pip install --no-dependencies https://github.com/nmaier/xpisign.py/zipball/master
# Install MX Tools
mkdir -p tmp/mxtools
# http://www.softlights.net/projects/mxtools/
wget http://www.softlights.net/files/mxtools.tar.gz -O tmp/mxtools.tar.gz
tar -xzf tmp/mxtools.tar.gz -C tmp/mxtools
cpanm RDF::Core
