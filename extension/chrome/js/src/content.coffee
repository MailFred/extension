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

					# Toggling checkboxes
					boxToggle = (target, onChange) ->
						target.on 'click', (e) ->
							e = $ @
							e.toggleClass 'J-LC-JR-Jp'
							checked = e.hasClass 'J-LC-JR-Jp'
							e.attr 'aria-checked', if checked then 'true' else 'false'
							props[e.attr 'act'] = checked
							onChange? checked
							return
						return
					
					
					delay = 300
					menu = 	$ """
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

					addMenuElement = (text, checked, onChange) ->
						element = $ """	
									<div class="J-N J-Ks" role="menuitemcheckbox" style="-webkit-user-select: none; " aria-checked="true">
										<div class="J-N-Jz" style="-webkit-user-select: none; ">
											<div class="J-N-Jo" style="-webkit-user-select: none; "></div>
											<div style="-webkit-user-select: none; ">#{text}</div>
										</div>
									</div>
									"""

						element.attr 'aria-checked', if checked then 'true' else 'false'
						element.toggleClass 'J-Ks-KO', checked

						addHovering element
						boxToggle element, onChange
						menu.append element
						return


					popup = $ 	"""
								<div class="J-M agd jQjAxd J-M-ayU aCP" style="display: none; -webkit-user-select: none;" role="menu" aria-haspopup="true" aria-activedescendant="">
									<div class="SK AX" style="-webkit-user-select: none;">

										<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; ">When?</div>
										<div>
											<div class="J-N J-Ks-KO J-Ks" role="menuitem" style="-webkit-user-select: none; ">
												<div class="J-N-Jz">
													<div class="J-N-Jo"></div>
													At a predefined time
													<span class="J-Ph-hFsbo"></span>
												</div>
											</div>
											<div class="J-N J-Ks" role="menuitemcheckbox" style="-webkit-user-select: none; ">
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
											ppos = popup.position()
											css =
												top: 	$(@).position().top + ppos.top
												left: 	ppos.left + popup.outerWidth()

											inMenu = true

											x = ->
												return unless inMenu
												menu.css css
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


					props =
						noanswer: 	false
						unread:		false
						star:		false
						inbox:		false

					submit = popup.find "[act='submit']"
					error = popup.find "[act='error']"

					# This shows the error message or the submit button
					boxToggle popup.find('.J-LC'), () ->
						valid = !!(props.unread or props.star or props.inbox)
						submit.toggle valid
						error.toggle !valid
						return

					addMenuElement 'in 1 minute', true, (checked) ->
					addMenuElement 'in 5 minutes', false, (checked) ->
					addMenuElement 'in 2 days', false, (checked) ->
					addMenuElement 'in 1 week', false, (checked) ->

					addHovering menu

					# Clicks on popup do not close it
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
				when:		"delta:"+60000
				unread:		!!props.unread
				star:		!!props.star
				noanswer:	!!props.noanswer
				inbox:		!!props.inbox
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