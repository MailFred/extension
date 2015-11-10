if top.document is document
  debug = false
  infix = if debug then '' else '.min'
  if /Protractor/.test navigator.userAgent
    ExtensionFacade.storage.sync.clear -> console.log 'cleared storage'

  head.load [
    ExtensionFacade.getURL "shared/bower_components/jquery/dist/jquery#{infix}.js"
    ExtensionFacade.getURL "shared/bower_components/jquery-deparam/jquery.ba-deparam#{infix}.js"
    ExtensionFacade.getURL "shared/bower_components/gmailr/build/gmailr#{infix}.js"
    ExtensionFacade.getURL "shared/js/mediator#{infix}.js"
  ], ->
    jQuery.noConflict true
    return
