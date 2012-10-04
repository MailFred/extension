
class MailButler
	@MB_CLASS: 'mailbutler'
	@MB_CLASS_THREAD: MailButler.MB_CLASS + '-thread'

	@TYPE_THREAD: 'thread'

	constructor: ->
		chrome.extension.onMessage.addListener @onMessage

	getIconURL: ->
		chrome.extension.getURL 'images/tie32x15.png'

	getNavigation: ->
		$ '.iH > div'

	injectCompose: ->
		$ ".dW.E[role=navigation]"

	injectThread: ->
		return if @isThreadInjected()
		nav = @getNavigation()
		return unless nav

		# console.log div
		nav.append @composeButton MailButler.TYPE_THREAD
		return

	composeButton: (type) ->
		icon = @getIconURL()

		cls = [MailButler.MB_CLASS]

		switch type
			when MailButler.TYPE_THREAD
				cls.push MailButler.MB_CLASS_THREAD

		div = $ "<div class='G-Ni J-J5-Ji #{cls.join ''}'>"
		button = $("<a><img src='#{icon}'></a>")
		div.append button
		div

	isThreadInjected: ->
		($ '.'+MailButler.MB_CLASS_THREAD).length > 0

	injectButtons: ->
		@injectThread()
		@injectCompose()
		return

	onMessage: (request, sender, sendResponse) =>
		#console.log request
		switch request.type
			when "fragment"
				@injectButtons()
			when "loaded"
				@injectButtons()
		return
		

mb = new MailButler