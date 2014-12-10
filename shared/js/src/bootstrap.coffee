if top.document is document
  yepnope [
    {
      load: [
        ExtensionFacade.getURL "shared/bower_components/jquery/dist/jquery.min.js"
        ExtensionFacade.getURL "shared/bower_components/jquery-deparam/jquery.ba-deparam.min.js"
        ExtensionFacade.getURL "shared/bower_components/gmailr/build/gmailr.min.js"
        ExtensionFacade.getURL "shared/js/mediator.min.js"
      ]
      complete: ->
        jQuery.noConflict true
        return
    }
  ]
