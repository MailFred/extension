### global require, chrome ###
((global) ->
  class Firefox
    self: null
    constructor: ->
      @self = require 'sdk/self'
      return

    getURL: (path) ->
      @self.data.url path

    sendMessage: ->
      args = arguments[..]
      args.unshift 'facade.message'
      @self.port.emit.apply @self.port, args
      return


  class Chrome
    constructor: ->
    getURL: (path) ->
      chrome.extension.getURL 'data/' + path

    sendMessage: ->
      chrome.runtime.sendMessage.apply chrome.runtime, arguments
      return

  class ExtensionFacade
    browser: null
    constructor: ->
      if typeof chrome is 'object' and 'extension' of chrome
        @browser = new Chrome()
      else if typeof require is 'function' and typeof (require 'sdk/simple-storage') is 'object'
        @browser = new Firefox()

    getURL: ->
      @browser.getURL.apply @browser, arguments

    sendMessage: ->
      @browser.sendMessage.apply @browser, arguments


  global.ExtensionFacade = new ExtensionFacade()

)(this)
