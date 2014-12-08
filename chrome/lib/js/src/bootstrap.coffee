if top.document is document
  yepnope [
    {
      load: [
        chrome.extension.getURL "data/shared/bower_components/jquery/dist/jquery.min.js"
        chrome.extension.getURL "data/shared/bower_components/jquery-deparam/jquery.ba-deparam.min.js"
        chrome.extension.getURL "data/shared/bower_components/gmailr/build/gmailr.min.js"
        chrome.extension.getURL "data/shared/js/mediator.min.js"
      ]
      complete: ->
        jQuery.noConflict true
        return
    }
  ]
