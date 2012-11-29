#!/bin/sh
cake watch &
BASE=`pwd`
cd "$BASE/extension/chrome/js/lib/gmailr/chrome"
cake watch &
cd "$BASE/extension/chrome/js"
cake watch &