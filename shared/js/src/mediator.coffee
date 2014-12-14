(->
  # Gmailr.debug = true
  receiveMessage = (e) ->
    # console.log 'GMAILR receiveMessage', e.data
    if e.data?.from is 'MAILFRED'
      switch e.data?.type
        when 'debug.enable'
          Gmailr.debug = true
    return

  window.addEventListener "message", receiveMessage, false

  Gmailr.init (G) ->
    sendMessage = (payload) ->
      message =
        from: "GMAILR"
        event: payload
      window.postMessage message, "*"
      return

    sendMessage
      type: 'init'
      email: G.emailAddress()

    G.observe Gmailr.EVENT_ANY, (type, args) ->
      console.log '[mailfred] [Gmailr]', type, args if Gmailr.debug
      sendMessage
        type: type
        args: args
      return
    return
)() if top.document is document
