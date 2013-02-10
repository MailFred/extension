# Gmailr.debug = true
Gmailr.init (G) ->
	message =
		from: "GMAILR"
		event:
			type: 'init'
			email: G.emailAddress()
	window.postMessage message, "*"

	G.observe Gmailr.EVENT_ANY, (type, args) ->
		console.log '[mailfred] (Gmailr)', type, args if Gmailr.debug
		message =
			from: "GMAILR"
			event: 
				type: type
				args: args
		window.postMessage message, "*"
		return
	return