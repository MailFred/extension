Gmailr.init (G) ->
	message =
		from: "GMAILR"
		event:
			type: 'init'
			email: G.emailAddress()
	window.postMessage message, "*"

	G.observe Gmailr.EVENT_ANY, (type, args) ->
		# console.log 'Gmailr', type, args
		message =
			from: "GMAILR"
			event: 
				type: type
				args: args
		window.postMessage message, "*"
		return
	return