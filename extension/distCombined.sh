#!/bin/bash


cd ./chrome/js/lib

cat jquery/jquery.min.js gmailr/chrome/lib/jquery-bbq/jquery.ba-bbq.min.js > combined.js
echo >> combined.js
cat gmailr/chrome/lib/gmailr.js >> combined.js
echo >> combined.js
cat mediator.js >> combined.js
echo >> combined.js
echo "jQuery.noConflict(true);" >> combined.js