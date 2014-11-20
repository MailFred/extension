if top.document is document
  yepnope [
    {
      load: [
        # chrome.extension.getURL "js/lib/jquery-ui/css/mailfred_theme/jquery-ui-1.10.3.custom.min.css"
        chrome.extension.getURL "bower_components/jquery/dist/jquery.min.js"
        chrome.extension.getURL "bower_components/jquery-deparam/jquery.ba-deparam.min.js"
        chrome.extension.getURL "bower_components/gmailr/build/gmailr.min.js"
        chrome.extension.getURL "js/build/mediator.min.js"
      ]
      complete: -> jQuery.noConflict true
    }
  ]
