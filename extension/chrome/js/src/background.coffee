chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
	#console.log(sender.tab "from a content script:" + sender.tab.url :
	#	"from the extension");
	
	switch request.action
		when 'notification'
			if not request.success
				title 	= 'Something went wrong!'
				message = request.error
			else
				title 	= 'Message scheduled!'
				message = 'Your message was scheduled successfully.'

			notification = webkitNotifications.createNotification "images/tie48x48.png",  title, message

			# Or create an HTML notification:
			# notification = webkitNotifications.createHTMLNotification 'notification.html'
			notification.show()
		when 'setting'
			ret = localStorage[request.key]
			switch request.key
				when 'debug'
					ret = String(ret) is "true"

	sendResponse? ret
	false # we don't want to message back anything after the script finished