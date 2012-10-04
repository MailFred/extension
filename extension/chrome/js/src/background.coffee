
send = (details, type) ->
	# console.log type, details
	chrome.tabs.getSelected null, (tab) ->
		ret =
			url: details.url
			type: type
		chrome.tabs.sendMessage tab.id, ret, () ->

chrome.webNavigation.onReferenceFragmentUpdated.addListener (details) ->
	send details, 'fragment'

chrome.webNavigation.onDOMContentLoaded.addListener (details) ->
	send details, 'loaded'


#chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
#	#console.log(sender.tab "from a content script:" + sender.tab.url :
#	#	"from the extension");
#
#	if request.url and request.data
#		$.ajax
#			url: 			request.url
#			dataType: 		'json'
#			data:			request.data
#			success:		-> sendResponse 'success', arguments
#			error:			-> sendResponse 'error', arguments
#	true