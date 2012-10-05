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

		injectCompose: ->
			navs = ($ ".dW.E[role=navigation] > .J-Jw").filter (index) ->
				($ ".#{MailButler.MB_CLASS_NAV}", @).length is 0

			if navs.length > 0
				navs.append @composeButton MailButler.TYPE_NAV
			return

		injectThread: ->
			threads = ($ '.iH > div').filter (index) ->
				($ ".#{MailButler.MB_CLASS_THREAD}", @).length is 0
			
			if threads.length > 0
				threads.append @composeButton MailButler.TYPE_THREAD
			return

		copyAttrs: (attrs, source, target) ->
			for attr in attrs
				target.attr attr, (source.attr attr)
			return

		composeButton: (type) ->
			cls = [MailButler.MB_CLASS]

			switch type
				when MailButler.TYPE_THREAD
					cls.push MailButler.MB_CLASS_THREAD
				when MailButler.TYPE_NAV
					cls.push MailButler.MB_CLASS_NAV

			div = $ "<div class='G-Ni J-J5-Ji #{cls.join ' '}'>"

			orig = $ ".T-I.J-J5-Ji.T-I-Js-IF.ar7.ns.T-I-ax7.L3"
			item = orig.first().clone()

			div.append item

			item.attr
				id: 				null
				title: 				null
				'data-tooltip': 	'MailButler'
				'aria-label': 		'MailButler'
				'aria-expanded': 	'false'
				'aria-haspopup': 	'true'

			item.css '-webkit-user-select', 'none'


			item.hover ((e) ->
				$(@).addClass 'T-I-JW'
				return), ((e) ->
				$(@).removeClass 'T-I-JW'
				return)

			popup = null
			close = null
			item.on 'click', (e) ->
				e.stopPropagation()
				t = $ @

				if !popup
					popup = $ """
								<div class="J-M agd jQjAxd" style="display: none; -webkit-user-select: none;" role="menu" aria-haspopup="true" aria-activedescendant="">
									<div class="SK AX" style="-webkit-user-select: none;">
										<div class="asc" style="-webkit-user-select: none;">
											Label as:
										</div>
										<div class="J-M-JJ asg" style="-webkit-user-select: none;">
											<div style="-webkit-user-select: none; visibility: visible;"></div><input type="text" maxlength="225" ignoreesc="true" style="" tabindex="0">
											<div class="A0" style="-webkit-user-select: none;"></div>
										</div>
										<div class="J-M-Jz aXjCH" style="-webkit-user-select: none; min-width: 135px;">
											<div class="J-LC J-Ks-KO J-LC-JR-Jp" aria-checked="true" role="menuitem" style="-webkit-user-select: none;" id=":tz__" title="MailButler">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>MailButler
												</div>
											</div>
											<div class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" id=":sx__" title="[Imap]/Drafts">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>[Imap]/Drafts
												</div>
											</div>
											<div style="-webkit-user-select: none;"></div>
										</div>
										<div class="J-Kh" style="-webkit-user-select: none;" role="separator" id=":uf__"></div>
										<div class="J-JK" style="display: none; -webkit-user-select: none;" role="menuitem" id=":ug__">
											<div class="J-JK-Jz" style="-webkit-user-select: none;">
												Apply
											</div>
										</div>
										<div class="J-JK" act="14" role="menuitem" style="-webkit-user-select: none;" id=":uh__">
											<div class="J-JK-Jz" style="-webkit-user-select: none;">
												Create new
											</div>
										</div>
										<div class="J-JK" act="78" role="menuitem" style="-webkit-user-select: none;" id=":ui__">
											<div class="J-JK-Jz" style="-webkit-user-select: none;">
												Manage labels
											</div>
										</div>
									</div>
								</div>
								"""


					t.parent().parent().append popup

					close = ->
						$('body').off 'click', close
						t.removeClass 'T-I-Kq'
						t.attr 'aria-expanded', 'false'
						popup.hide()
						t.blur()

				if popup.is ':visible'
					close()
				else		
					$('body').on 'click', close
					t.addClass 'T-I-Kq'
					t.attr 'aria-expanded', 'true'

					popup.css
						left: 	t.parent().position().left
						top:	t.outerHeight()

					popup.show()

				return


			###
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
			###
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

				loadingIcon?()

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
										resetIcon?()
			return


		onScheduleSuccess: (data) =>
			chrome.extension.sendMessage data, (response) ->
			return

		onScheduleError: (params, status) =>
			log arguments
			if status is 'parsererror'
				params.action = 'setup'
				delete params.callback if params.callback

				query = $.param params
				window.open "#{@url}?#{query}", 'mailbutler', 'width=500,height=500,location=0,menubar=0,scrollbars=0,status=0,toolbar=0,resizable=1'
			else
				chrome.extension.sendMessage {error: status}, (response) ->
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