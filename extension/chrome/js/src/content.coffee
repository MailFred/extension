(($, window) ->

	log = (args...) ->
    	console.log.apply console, args if console?.log and mb.debug is true

	class MailButler
		debug: true
		@MB_CLASS: 'mailbutler'
		@MB_CLASS_THREAD: MailButler.MB_CLASS + '-thread'
		@MB_CLASS_NAV: MailButler.MB_CLASS + '-nav'
		@MB_CLASS_POPUP: MailButler.MB_CLASS + '-popup'
		@MB_CLASS_MENU: MailButler.MB_CLASS + '-menu'
		@MB_CLASS_PICKER: MailButler.MB_CLASS + '-picker'

		@TYPE_THREAD: 'thread'
		@TYPE_NAV: 'nav'

		@ID_PREFIX: 'mailbutler-id-'

		# production URL
		url: "https://script.google.com/macros/s/AKfycbxf5DLvznehMYEK5u3p9d-f1F_iwIIqs11SCw_loUDogp3iDg/exec"

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
			picker = null
			close = null
			self  = @
			

			# Don't focus the item when clicking on it
			item.on 'mousedown', (e) ->
				e.preventDefault()
				return

			item.on 'click', (e) ->
				e.stopPropagation()
				t = $ @

				unless popup

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
					menuBase = 	"""
								<div class="J-M J-M-ayU" style="-webkit-user-select: none; display: none; " role="menu" aria-haspopup="true" aria-activedescendant="">
								</div>
								"""
					menu = 	$ menuBase
					menu.addClass MailButler.MB_CLASS_MENU
					menu.inMenu = false

					# Clicks on menu do not close the popup
					menu.on 'click', (e) ->
						e.stopPropagation()
						return

					hideMenu = ->
						return if menu.inMenu
						menu.hide()
						return


					menu.hover ((e) -> 
									menu.inMenu = true
									return),
								((e) ->
									menu.inMenu = false
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
						element.attr 'id', MailButler.ID_PREFIX + (Math.random()+"").substr 2

						toggle element, selectedClass, checked, false

						addHovering element, ((e) ->
												menu.attr 'aria-activedescendant', element.attr 'id'
												return),
											((e) ->
												menu.attr 'aria-activedescendant', null
												return)

						boxToggle element, selectedClass, true, (e, checked) ->
							toggle parentMenuItem, selectedClass, true, true
							onChange e, checked
							return
						menu.append element
						element

					picker = $ menuBase
					picker.inMenu = false
					picker.addClass MailButler.MB_CLASS_PICKER

					# Clicks on menu do not close the popup
					picker.on 'click', (e) ->
						e.stopPropagation()
						return

					datePicker = $ '<div act="picker"></div>'
					picker.append datePicker

					hidePicker = ->
						return if picker.inMenu
						picker.hide()
						return

					picker.hover ((e) -> 
									picker.inMenu = true
									return),
								((e) ->
									picker.inMenu = false
									_.delay hidePicker, delay
									return)


					popup = $ 	"""
								<div class="J-M agd jQjAxd J-M-ayU aCP" style="display: none; -webkit-user-select: none;" role="menu" aria-haspopup="true" aria-activedescendant="">
									<div class="SK AX" style="-webkit-user-select: none;">


										<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; ">Thy letters shalt be</div>

										<div style="-webkit-user-select: none;">
											<div act="unread" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Mark as unread">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>markedth unread
												</div>
											</div>

											<div act="star" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Star it">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div><span act="and_star" style="display: none">and</span> starredth
												</div>
											</div>

											<div act="inbox" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Move to inbox">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div><span act="and_inbox" style="display: none">and</span> movedth to thy inbox
												</div>
											</div>

											<div style="-webkit-user-select: none;"></div>
										</div>


										<div act="when_section" style="display: none">
											<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>
											<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; ">At the time you giveth us</div>

											<div>
												<div class="J-N J-Ks" role="menuitem" style="-webkit-user-select: none; " act="presets">
													<div class="J-N-Jz">
														<div class="J-N-Jo"></div>
														<span class="default">In close future</span><span class="selected"></span>
														<span class="J-Ph-hFsbo"></span>
													</div>
												</div>
												<div class="J-N J-Ks" role="menuitem" style="-webkit-user-select: none; " act="manual">
													<div class="J-N-Jz">
														<div class="J-N-Jo"></div>
														<span class="default">On a specified date</span><span class="selected"></span>
														<span class="J-Ph-hFsbo"></span>
													</div>
												</div>
											</div>
										</div>

										<div act="noanswer_section" style="display: none">
											<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>

											<div act="noanswer" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="Only if noone answered">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>But only if noone answered.
												</div>
											</div>
										</div>

										<div act="error" class="b7o7Ic" style="-webkit-user-select: none;">
											<div class="J-Kh" style="-webkit-user-select: none; "></div>
											<div class="asd ja" style="-webkit-user-select: none; ">
												<span act="when" style="display: none;">When shalt thy butler fulfill thy wishes?</span>
												<span act="what">Wilt ye tell us what thy butler shalt to do with thy letters?</span>
											</div>
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

					# Clicks on popup itself do not close it either
					popup.on 'click', (e) ->
						e.stopPropagation()
						return

					popup.addClass MailButler.MB_CLASS_POPUP
					t.parent().parent().append popup

					# Hovering
					addHovering = (target, over, out) ->
						for cls in ['J-N','J-LC','J-JK']
							hoverClass = cls+'-JT'
							target.find('.'+cls).hover 	((e) ->
															$(@).addClass hoverClass
															over? e
															return),
														((e) ->
															$(@).removeClass hoverClass
															out? e
															return)
						return

					addHovering popup

					actionOps = [
						'unread'
						'star'
						'inbox'
					]

					manual 				= popup.find "[act='manual']"
					presets 			= popup.find "[act='presets']"
					submit 				= popup.find "[act='submit']"
					error 				= popup.find "[act='error']"
					ands = {}
					for op in actionOps
						ret = popup.find "[act='and_#{op}']"
						ands[op] = ret if ret.length > 0

					noanswer_section 	= popup.find "[act='noanswer_section']"
					when_section 		= popup.find "[act='when_section']"
					error_when 		 	= popup.find "[act='when']"
					error_what 		 	= popup.find "[act='what']"

					# Picker
					popup.parent().append picker
					datePicker.datepicker
									minDate: '+1d'
									showOtherMonths: true
									selectOtherMonths: true
									changeMonth: true
									changeYear: true
									onSelect: (dateText, inst) ->
														date = datePicker.datepicker 'getDate'
														if date
															props.when = "specified:#{date.getTime()}"
															toggle manual, 'J-Ks-KO', true, true
															toggle menu.children(), 'J-Ks-KO', false, false
															(manual.find '.selected').html "On #{dateText}"
														isValid()
														return
					manual.hover 		((e) ->
											picker.inMenu = true

											x = =>
												return unless picker.inMenu
												ppos = popup.position()
												picker.css
													top: 	$(@).position().top + ppos.top
													left: 	ppos.left + popup.outerWidth()
												#datePicker.datepicker 'hide'
												#datePicker.blur()
												picker.show()
												return

											_.delay x, delay

											return),
										((e) ->
											picker.inMenu = false

											_.delay hidePicker, delay

											return)

					# Popup menu
					popup.parent().append menu
					presets.hover 		((e) ->
											menu.inMenu = true

											x = =>
												return unless menu.inMenu
												ppos = popup.position()
												menu.css
													top: 	$(@).position().top + ppos.top
													left: 	ppos.left + popup.outerWidth()
												datePicker.datepicker 'hide'
												datePicker.blur()
												menu.show()
												return

											_.delay x, delay

											return),
										((e) ->
											menu.inMenu = false

											_.delay hideMenu, delay

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

					isValid = ->
						actionToggle = false
						for op,i in actionOps
							ands[op].toggle !!actionToggle if i > 0
							actionToggle |= props[op]

						wat = !! (props.unread or props.star or props.inbox)
						wen  = !! props.when

						valid = wat and wen

						unless valid
							error_what.toggle not wat and wen
							error_when.toggle wat and not wen
						
						noanswer_section.toggle valid
						when_section.toggle wat
						submit.toggle valid
						error.toggle !valid
						return

					# This shows the error message or the submit button
					boxToggle popup.find('.J-LC'), 'J-LC-JR-Jp', false, (e, checked) ->
						props[e.attr 'act'] = checked
						isValid()
						return

					if self.debug
						addMenuElement 'in 1 minute', false, presets, (e, checked) ->
							if checked
								props.when = _delta _1m
								(presets.find '.selected').html 'In about a minute'
							isValid()
							return

					addMenuElement 'in 5 minutes', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1m * 5
							(presets.find '.selected').html 'In five minutes'
						isValid()
						return

					addMenuElement 'in 1 hour', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1h
							(presets.find '.selected').html 'In one hour'
						isValid()
						return

					addMenuElement 'in 2 days', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1d * 2
							(presets.find '.selected').html 'In two days'
						isValid()
						return

					addMenuElement 'in 1 week', false, presets, (e, checked) ->
						if checked
							props.when = _delta _1d * 7
							(presets.find '.selected').html 'Next week'
						isValid()
						return

					addHovering menu



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