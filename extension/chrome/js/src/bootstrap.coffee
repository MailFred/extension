#  This is the bootstrapping code that sets up the scripts to be used in the 
#  Gmailr example Chrome plugin.

if top.document is document
    yepnope [
    	chrome.extension.getURL "js/lib/jquery-ui/css/mailfred_theme/jquery-ui-1.9.1.custom.min.css"
    	chrome.extension.getURL "js/lib/jquery/jquery.min.js"
        chrome.extension.getURL "js/lib/gmailr/chrome/lib/jquery-bbq/jquery.ba-bbq.js"
        chrome.extension.getURL "js/lib/gmailr/chrome/lib/gmailr.js"
        chrome.extension.getURL "js/lib/mediator.js"
    ]