((window, Gmailr) ->
  EVENT_SOURCE_MAILFRED = 'MAILFRED'
  EVENT_SOURCE_GMAILR = 'GMAILR'

  # Gmailr.debug = true

  receiveMessage = (e) ->
    # console.log '[mailfred] [mediator]', 'receiveMessage', e.detail
    switch e.detail.type
      when 'debug.enable'
        Gmailr.debug = true
    return

  sendMessage = (payload) ->
    event = new CustomEvent EVENT_SOURCE_GMAILR, detail: payload
    window.dispatchEvent event
    return

  # Last parameter is for Mozilla (untrusted sources)
  window.addEventListener EVENT_SOURCE_MAILFRED, receiveMessage, true, true

  Gmailr.init (G) ->
    sendMessage
      type: 'init'
      email: G.emailAddress()

    G.observe Gmailr.EVENT_ANY, (type, args) ->
      console.log '[mailfred] [mediator]', type, args if Gmailr.debug
      sendMessage
        type: type
        args: args
      return
    return
) @, window.Gmailr if top.document is document
