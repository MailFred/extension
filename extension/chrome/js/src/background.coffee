settings =
	url: 'https://script.google.com/macros/s/' +'AKfycbw9V8T6n79IkEUwZJNknuKWxHTvK2f_U66eIIRerEMU6VKmSq0'+'/exec'

chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
	#console.log(sender.tab "from a content script:" + sender.tab.url :
	#	"from the extension");
	
	switch request.action
		when 'notification'
			notification = webkitNotifications.createNotification request.icon, request.title, request.message

			# Or create an HTML notification:
			# notification = webkitNotifications.createHTMLNotification 'notification.html'
			notification.show()

		when 'version'
			ret = chrome.app.getDetails().version

		else
			ret = settings[request.action]

	sendResponse? ret
	false # we don't want to message back anything after the script finished
