###* global require, chrome, self ###
((global) ->
  class Firefox
    options: null
    self: null

    constructor: ->
      @self = self
      @options = @self.options
      console.log 'Firefox', @options

      get = (keys, callback) =>
        args =
          action: 'storage.get'
          keys:   keys
        @sendMessage args, callback
        return
      set = (items, callback) =>
        args =
          action: 'storage.set'
          items:   items
        @sendMessage args, callback
        return
      @storage =
        local:
          set: set
          get: get
        sync:
          set: set
          get: get
      return

    getURL: (path) => @options.baseUrl + path

    # sends a message from the content script
    sendMessage: (args, callback) =>
      # console.log 'sendMessage'
      if typeof callback is 'function'
        rand = 'callback_' + Math.random().toString(36).substr(2, 5)
        @self.port.once rand, callback
        args.callback = rand

      # console.log 'emitting', args
      @self.port.emit 'facade.message', args
      return

    showNotification: (icon, title, message) =>
      @sendMessage
        action: 'notification'
        icon: @getURL icon
        title: title
        message: message
      return

    i18n: (messageId, placeholders, callback) =>
      args =
        action: 'i18n'
        key: messageId
      @sendMessage args, (message) ->
        if placeholders
          for placeholderName, value of placeholders
            message.replace (new RegExp("\\$#{placeholderName}\\$", 'g')), value
        callback message
      return

    getVersion: => @options.version

  class Chrome
    constructor: ->
      return

    # Gets a URL beneath the data directory
    getURL: (path) ->
      chrome.extension.getURL 'data/' + path

    sendMessage: ->
      chrome.runtime.sendMessage.apply chrome.runtime, arguments
      return

    ### shows a notification
    @param {String} icon a path to an icon file beneath the data directory
    @param {String} title the title of the notification
    @param {String message} the message body of the notification
    ###
    showNotification: (icon, title, message) ->
      msgObj =
        action: 'notification'
        icon: @getURL icon
        title: title
        message: message
      @sendMessage msgObj


    ###
      uses the translation system of the according browser
      Supports named placeholders e.g. $placeholder$
    ###
    i18n: (key, substitutions, callback) ->
      callback (chrome.i18n.getMessage key, substitutions)
      return

    # gets the extension version
    getVersion: ->
      chrome.runtime.getManifest().version

    storage:
      local:
        get: (keys, callback) ->
          chrome.storage.local.get.apply chrome.storage.local, arguments
          return
        set: (items, callback) ->
          chrome.storage.local.set.apply chrome.storage.local, arguments
          return
      sync:
        get: (keys, callback) ->
          chrome.storage.sync.get.apply chrome.storage.sync, arguments
          return
        set: (items, callback) ->
          chrome.storage.sync.set.apply chrome.storage.sync, arguments
          return

  if /Chrome/.test navigator.userAgent
    global.ExtensionFacade = new Chrome()
  else if /Firefox/.test navigator.userAgent
    global.ExtensionFacade = new Firefox()
  else
    throw new Error 'Could not recognize browser'
  return

) this if top.document is document
