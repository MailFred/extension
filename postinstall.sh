#!/bin/sh
# Install JS packages
bower install
# Install tools for signing XPI files
# If we have OpenSSL, we don't need M2Crypto, although it is recommended
# easy_install -Z M2Crypto
pip install https://github.com/nmaier/xpisign.py/zipball/master
