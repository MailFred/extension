#!/bin/sh
# Install JS packages
bower install
# Install tools for signing XPI files
easy_install -Z M2Crypto
pip install https://github.com/nmaier/xpisign.py/zipball/master
