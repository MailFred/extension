
class MailButler
	constructor: ->
		# @injectScript '//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'
		@injectButton()
	injectScript: (url) ->
		(document.body.appendChild document.createElement 'script').src = url
		return
	getIconURL: ->
		chrome.extension.getURL 'images/32x32.png'
	getNavigation: ->
		$ '.iH > div'

	injectButton: ->
		icon = @getIconURL()
		#console.log icon
		#icon = ""
		button = $("<a><img src='#{icon}'></a>").wrap('<div>')
		console.log button
		nav = @getNavigation()
		console.log nav
		button.appendTo $ document.querySelector '.iH > div'
		#$('body')
		return


$ () ->
	# alert 'works'
	mb = new MailButler
	console.debug mb