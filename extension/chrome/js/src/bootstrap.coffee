#  This is the bootstrapping code that sets up the scripts to be used in the 
#  Gmailr example Chrome plugin.

if top.document is document
	yepnope [
		chrome.extension.getURL "js/lib/jquery-ui/css/mailfred_theme/jquery-ui-1.10.3.custom.min.css"
		chrome.extension.getURL "js/lib/combined.js"
	]