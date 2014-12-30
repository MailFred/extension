#!/bin/sh
set -e
# Install JS packages
bower install
# Install tools for signing XPI files
# If we have OpenSSL, we don't need M2Crypto, although it is recommended
# easy_install -Z M2Crypto
sudo pip install --no-dependencies https://github.com/nmaier/xpisign.py/zipball/master