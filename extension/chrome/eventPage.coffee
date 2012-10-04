
send = (details, type) ->
	console.log type, details
	chrome.tabs.getSelected null, (tab) ->
		ret =
			url: details.url
			type: type
		chrome.tabs.sendMessage tab.id, ret, () ->

chrome.webNavigation.onReferenceFragmentUpdated.addListener (details) ->
	send details, 'fragment'

chrome.webNavigation.onDOMContentLoaded.addListener (details) ->
	send details, 'loaded'