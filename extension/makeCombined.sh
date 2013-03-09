#!/bin/bash


cd ./chrome/js/lib

cat jquery/jquery.js gmailr/chrome/lib/jquery-bbq/jquery.ba-bbq.js gmailr/chrome/lib/gmailr.js mediator.js > combined.js
	echo >> combined.js
	echo >> combined.js
	echo "jQuery.noConflict(true);" >> combined.js