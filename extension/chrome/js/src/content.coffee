(($) ->

	log = (args...) ->
    	console.log.apply console, args if console?.log and mb.debug is true

	class MailButler
		debug: true
		@MB_CLASS: 'mailbutler'
		@MB_CLASS_THREAD: MailButler.MB_CLASS + '-thread'
		@MB_CLASS_NAV: MailButler.MB_CLASS + '-nav'

		@TYPE_THREAD: 'thread'
		@TYPE_NAV: 'nav'

		# production URL
		pUrl: "https://script.google.com/a/macros/feth.com/s/AKfycbxf5DLvznehMYEK5u3p9d-f1F_iwIIqs11SCw_loUDogp3iDg/exec"

		# dev URL
		dUrl: "https://script.google.com/a/macros/feth.com/s/AKfycbztqUX2xb2_w4NnlsaUP_f5sdLl8h9Fsc5AORb9Pg/dev"

		#injectScript: (url) ->
		#	e = document.createElement 'script'
		#	(document.body.appendChild e).src = url
		#	e

		constructor: ->
			chrome.extension.onMessage.addListener @onMessage

		getServiceURL: ->
			if @debug then @dUrl else @pUrl

		getIconURL: ->
			chrome.extension.getURL 'images/tie32x15.png'

		getLoaderURL: ->
			chrome.extension.getURL 'images/loader.gif'

		injectCompose: ->
			navs = ($ ".dW.E[role=navigation] > .J-Jw").filter (index) ->
				($ ".#{MailButler.MB_CLASS_NAV}", @).length is 0

			# log 'navs', navs
			#return unless navs.length > 0
			#_.each navs, @injectNav
			navs.append @composeButton MailButler.TYPE_NAV
			return

		injectThread: ->
			thread = ($ '.iH > div').filter (index) ->
				($ ".#{MailButler.MB_CLASS_THREAD}", @).length is 0
			# log 'thread', thread
			thread.append @composeButton MailButler.TYPE_THREAD
			return

		composeButton: (type) ->
			icon = @getIconURL()

			cls = [MailButler.MB_CLASS]

			switch type
				when MailButler.TYPE_THREAD
					cls.push MailButler.MB_CLASS_THREAD
				when MailButler.TYPE_NAV
					cls.push MailButler.MB_CLASS_NAV

			div = $ "<div class='G-Ni J-J5-Ji #{cls.join ' '}'>"
			img = $ "<img src='#{icon}'>"
			button = $ "<a>"
			button.append img
			div.append button
			button.on 'click', () =>
				loading = =>
					img.attr 'src', @getLoaderURL()
					return
				reset = =>
					img.attr 'src', @getIconURL()
					return

				@onSchedule loading, reset
				return
			div

		onSchedule: (loadingIcon, resetIcon) =>
			address = window.location.href

			catPos = address.lastIndexOf '#'
			slashPos = address.lastIndexOf '/'
			if catPos > slashPos
				alert 'Not within a message!'
				return
			else
				messageId = address.substr (1 + slashPos)
				
				data = 
					action:		'schedule'
					messageId: 	messageId
					when:		"delta:"+60000
					unread:		true
					star:		false
					noanswer:	false
					inbox:		true
					#callback:	'alert'

				#jQuery.getJSON @url, data, @onScheduleSuccess
				log 'scheduling mail...'

				loadingIcon()

				#u = @url + "?" + ($.param data)
				#log 'URL is: ', u
				#@injectScript u

				#chrome.extension.sendMessage {data: data, url: @url}, (response) ->
				#  log "res", response
				#  return

				#xhr = new XMLHttpRequest
				#xhr.onreadystatechange = -> log arguments
				#xhr.open "GET", (@url + "?" + ($.param data)), true
				#xhr.send()
				#return
				
				$.ajax
					url: 			@getServiceURL()
					dataType: 		'json'
					data:			data
					success:		(data, textStatus, jqXHR) =>
										@onScheduleSuccess data
					error:			(jqXHR, textStatus, errorThrown) =>
										log arguments
										@onScheduleError data, textStatus
					complete:		(jqXHR, textStatus) ->
										resetIcon()
			return


		onScheduleSuccess: (data) =>
			log arguments
			if data.error
				# TODO handle this
				alert data.error
			else
				alert 'scheduled!'
			return

		onScheduleError: (params, status) =>
			log arguments
			if status is 'parsererror'
				params.action = 'setup'
				delete params.callback

				query = $.param params
				window.open "#{@url}?#{query}", 'mailbutler', 'width=500,height=500,location=0,menubar=0,scrollbars=0,status=0,toolbar=0,resizable=1'
			else
				# TODO handle this
				alert status
			return

		injectButtons: ->
			@injectThread()
			@injectCompose()
			return

		onMessage: (request, sender, sendResponse) =>
			# log request
			switch request.type
				when "fragment"
					@injectButtons()
				when "loaded"
					@injectButtons()
			return		

	mb = new MailButler
)(jQuery)