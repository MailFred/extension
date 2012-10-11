(($, window) ->

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
		url: "https://script.google.com/a/macros/feth.com/s/AKfycbxf5DLvznehMYEK5u3p9d-f1F_iwIIqs11SCw_loUDogp3iDg/exec"

		# dev URL
		# url: "https://script.google.com/a/macros/feth.com/s/AKfycbztqUX2xb2_w4NnlsaUP_f5sdLl8h9Fsc5AORb9Pg/dev"

		#injectScript: (url) ->
		#	e = document.createElement 'script'
		#	(document.body.appendChild e).src = url
		#	e

		constructor: ->
			chrome.extension.onMessage.addListener @onMessage

		getServiceURL: -> @url

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

		composeButton: (type) =>
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
							return),
						((e) ->
							$(@).removeClass 'T-I-JW'
							return)

			popup = null
			menu  = null
			close = null
			self  = @
			inMenu = false

			# Don't focus the item when clicking on it
			item.on 'mousedown', (e) ->
				e.preventDefault()
				return

			item.on 'click', (e) ->
				e.stopPropagation()
				t = $ @

				if !popup

					toggle = (target, selectedClass, selected, exclusive) ->
						target.toggleClass selectedClass, selected
						target.attr 'aria-checked', if selected then 'true' else 'false'
						if exclusive
							toggle target.siblings(), selectedClass, false, false
						return

					# Toggling checkboxes
					boxToggle = (target, selectedClass, exclusive, onChange) ->
						target.on 'click', (e) ->
							e = $ @
							checked = e.hasClass selectedClass

							# We can't deselect the selected item if we are in exclusive mode
							return if exclusive and checked
							
							toggle e, selectedClass, !checked, exclusive
							onChange? e, !checked
							return
						return
					
					
					delay = 300
					menu = 	$ 	"""
								<div class="J-M J-M-ayU" style="-webkit-user-select: none; left: 178px; top: 239px; display: none; " role="menu" aria-haspopup="true" aria-activedescendant="">
								</div>
								"""

					hideMenu = ->
						return if inMenu
						menu.hide()
						return


					menu.hover ((e) -> 
									inMenu = true
									return),
								((e) ->
									inMenu = false
									_.delay hideMenu, delay
									return)

					addMenuElement = (text, checked, parentMenuItem, onChange) ->
						selectedClass = 'J-Ks-KO'
						element = $ """	
									<div class="J-N J-Ks" role="menuitemcheckbox" style="-webkit-user-select: none; " aria-checked="true">
										<div class="J-N-Jz" style="-webkit-user-select: none; ">
											<div class="J-N-Jo" style="-webkit-user-select: none; "></div>
											<div style="-webkit-user-select: none; ">#{text}</div>
										</div>
									</div>
									"""

						toggle element, selectedClass, checked, false

						addHovering element

						boxToggle element, selectedClass, true, (e, checked) ->
							toggle parentMenuItem, selectedClass, true, true
							onChange e, checked
							return
						menu.append element
						element


					popup = $ 	"""
								<div class="J-M agd jQjAxd J-M-ayU aCP" style="display: none; -webkit-user-select: none;" role="menu" aria-haspopup="true" aria-activedescendant="">
									<div class="SK AX" style="-webkit-user-select: none;">

										<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; ">When?</div>
										<div>
											<div class="J-N J-Ks" role="menuitem" style="-webkit-user-select: none; " act="presets">
												<div class="J-N-Jz">
													<div class="J-N-Jo"></div>
													At a predefined time
													<span class="J-Ph-hFsbo"></span>
												</div>
											</div>
											<div class="J-N J-Ks" role="menuitemcheckbox" style="-webkit-user-select: none; " act="manual">
												<div class="J-N-Jz">
													<div class="J-N-Jo"></div>
													<div>Specify time</div>
												</div>
											</div>
										</div>

										<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>

										<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; ">What to do?</div>

										<div style="-webkit-user-select: none;">
											<div act="unread" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Mark as unread">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>Mark as unread
												</div>
											</div>

											<div act="star" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Star it">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>Star it
												</div>
											</div>

											<div act="inbox" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Move to inbox">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>Move to inbox
												</div>
											</div>

											<div style="-webkit-user-select: none;"></div>
										</div>

										<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>

										<div act="noanswer" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Only if noone answered">
											<div class="J-LC-Jz" style="-webkit-user-select: none;">
												<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>&hellip; but only if noone answered
											</div>
										</div>

										<div act="error" class="b7o7Ic" style="-webkit-user-select: none;">
											<div class="J-Kh" style="-webkit-user-select: none; "></div>
											<div class="asd ja" style="-webkit-user-select: none; ">Specify a time and action to schedule the email</div>
										</div>
										<div act="submit" style="display: none;">
											<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>

											<div act="schedule" class="J-JK" role="menuitem" style="-webkit-user-select: none;">
												<div class="J-JK-Jz" style="-webkit-user-select: none;">
													Schedule!
												</div>
											</div>
										</div>
									</div>
								</div>
								"""


					t.parent().parent().append popup

					# Hovering
					addHovering = (target) ->
						for cls in ['J-N','J-LC','J-JK']
							hoverClass = cls+'-JT'
							target.find('.'+cls).hover 	((e) ->
															$(@).addClass hoverClass
															return),
														((e) ->
															$(@).removeClass hoverClass
															return)
						return

					addHovering popup

					# Popup menu
					menuElement = popup.find(".J-N.J-Ks[role='menuitem']")
					popup.parent().append menu
					menuElement.hover 	((e) ->
											inMenu = true

											x = =>
												return unless inMenu
												ppos = popup.position()
												menu.css
													top: 	$(@).position().top + ppos.top
													left: 	ppos.left + popup.outerWidth()
												menu.show()
												return

											_.delay x, delay

											return),
										((e) ->
											inMenu = false

											x = ->
												hideMenu()
												return

											_.delay x, delay

											return)

					_1m = 60 * 1000
					_1h = 60 * _1m
					_1d = 24 * _1h

					_delta = (offset) ->
						"delta:#{offset}"

					props =
						noanswer: 	false
						unread:		false
						star:		false
						inbox:		false
						#when:		_delta _1m


					boxToggle (popup.find "[act='manual']"), 'J-Ks-KO', true, (e, checked) ->
						if checked
							toggle menu.children(), 'J-Ks-KO', false, false
							props.when = 'specified:0'
						isValid()
						return


					submit = popup.find "[act='submit']"
					error = popup.find "[act='error']"
					isValid = ->
						valid = (props.unread or props.star or props.inbox) and props.when
						submit.toggle !!valid
						error.toggle !valid
						return

					# This shows the error message or the submit button
					boxToggle popup.find('.J-LC'), 'J-LC-JR-Jp', false, (e, checked) ->
						props[e.attr 'act'] = checked
						isValid()
						return


					presets = popup.find "[act='presets']"

					if self.debug
						addMenuElement 'in 1 minute', false, presets, (e, checked) ->
							if checked
								props.when = _delta _1m
							isValid()
							return

					addMenuElement 'in 5 minutes', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1m * 5
						isValid()
						return

					addMenuElement 'in 1 hour', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1h
						isValid()
						return

					addMenuElement 'in 2 days', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1d * 2
						isValid()
						return

					addMenuElement 'in 1 week', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1d * 7
						isValid()
						return

					addHovering menu

					# Clicks on menu do not close the popup
					menu.on 'click', (e) ->
						e.stopPropagation()

					# Clicks on popup itself do not close it either
					popup.on 'click', (e) ->
						e.stopPropagation()

					# Close the popup
					close = ->
						# Disable the body listener
						$('body').off 'click', close

						# Remove the pushed state from the menu button
						t.removeClass 'T-I-Kq'
						t.attr 'aria-expanded', 'false'

						# hide the popup
						popup.hide()

					popup.find("[act='schedule']").on 'click', (e) ->
						cls = 'loader'
						loading = =>
							div.addClass cls
							return
						reset = =>
							div.removeClass cls
							return

						self.onSchedule props, loading, reset
						close()
						return

				if popup.is ':visible'
					# Popup is visible, so close it
					close()
				else
					# As long as the popup is open, clicks anywhere else should close it
					$('body').on 'click', close

					# Add the pushed state to the button
					t.addClass 'T-I-Kq'
					t.attr 'aria-expanded', 'true'

					# Set the position of the popup menu right beneath the menu button (lower left corner)
					popup.css
						left: 	t.parent().position().left
						top:	t.outerHeight()

					# and show it :-)
					popup.show()

				return

			div

		getMessageId: ->
			address = window.location.href

			catPos = address.lastIndexOf '#'
			slashPos = address.lastIndexOf '/'
			if catPos > slashPos
				throw 'Not within a message!'
			else
				address.substr (1 + slashPos)

		onSchedule: (props, loadingIcon, resetIcon) =>
			try
				messageId = @getMessageId()
			catch e
				chrome.extension.sendMessage
					error: e.toString()
				return
			
			
			data = 
				action:		'schedule'
				messageId: 	messageId
				when:		props.when
				unread:		!!props.unread
				star:		!!props.star
				noanswer:	!!props.noanswer
				inbox:		!!props.inbox
				#callback:	'alert'

			#jQuery.getJSON @url, data, @onScheduleSuccess
			log 'scheduling mail...', data

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
			chrome.extension.sendMessage data
			return

		onScheduleError: (params, status) =>
			log arguments
			if status is 'parsererror'
				params.action = 'setup'
				delete params.callback if params.callback

				query = $.param params
				window.open "#{@getServiceURL()}?#{query}", 'mailbutler', 'width=500,height=500,location=0,menubar=0,scrollbars=0,status=0,toolbar=0,resizable=1'
			else
				chrome.extension.sendMessage 
					error: status
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
) jQuery, window