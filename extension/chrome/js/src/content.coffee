(($, window) ->

	log = (args...) ->
		console.log.apply console, args if console?.log and mb?.debug is true
		return

	#__msg = (args...) ->
	#	ret = chrome.i18n.getMessage.apply chrome.i18n, args
	#	log args, ret
	#	ret
	__msg = chrome.i18n.getMessage

	# Adapted from http://stackoverflow.com/questions/6157929
	class Eventr
		@eventMatchers:
			HTMLEvents:		/^(?:load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll)$/i
			MouseEvents:	/^(?:click|dblclick|mouse(?:down|up|over|move|out))$/i

		@defaults:
			pointerX: 	0
			pointerY: 	0
			button: 	0
			ctrlKey: 	false
			altKey: 	false
			shiftKey: 	false
			metaKey: 	false
			bubbles: 	true
			cancelable: true
		
		@simulate: (target, eventName, options = {}) ->
			for name,matcher of @eventMatchers
				if matcher.test eventName
					eventType = name
					break

			throw new SyntaxError 'Only HTMLEvents and MouseEvents interfaces are supported' unless eventType
			eventName = eventName.toLowerCase()
			options = _.defaults @defaults, options

			if document.createEvent
				evt = document.createEvent eventType
				switch eventType
					when 'HTMLEvents'
						evt.initEvent eventName, options.bubbles, options.cancelable
					else
						evt.initMouseEvent eventName, options.bubbles, options.cancelable, document.defaultView, options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY, options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, target
				target.dispatchEvent evt
			else
				options.clientX = options.pointerX
				options.clientY = options.pointerY
				delete options.pointerX
				delete options.pointerY
				evt = document.createEventObject()
				oEvent = _.extend evt, options
				target.fireEvent "on#{eventName}", oEvent
			
			target

	class GMailUI
		@Breadcrumbs: class
			@LIST_SEL: 'ol.gbtc'
			@markup: _.template """
								<li class="gbt">
									<a href="#" class="gbgt">
									<span class="gbts">
										<span><%- label %></span>
										<% if(isMenu) { %>
										<span class="gbma"></span>
										<% } %>
									</span>
									</a>
								</li>
								"""
			@add: (label, onClick, isMenu = false) ->
				obj =
					label: label
					isMenu: !!isMenu
				item = 	$ @markup obj
				(item.find '.gbgt').on 'click', onClick if onClick
				item.prependTo $ @LIST_SEL
				item


		@ModalDialog: class
			@BG: 	$ 	"""
						<div class="Kj-JD-Jh" style="opacity: 0.75; width: 2560px; height: 2560px; margin-left: -230px; margin-top: -64px;"></div>
						"""
			@dialog: _.template """
								<div class="Kj-JD" tabindex="0" style="left: 50%; top: 40%; width: 460px; overflow: visible; margin-left: -230px; margin-top: -64px;" role="dialog" aria-labelledby="<%= id %>">
									<div class="Kj-JD-K7 Kj-JD-K7-GIHV4" id="<%= id %>">
										<span class="Kj-JD-K7-K0"><%- title %></span>
										<span class="Kj-JD-K7-Jq" act="close"></span>
									</div>
									<!--
									<div class="Kj-JD-Jz">
										<div id="ri_selecttimezone_invalid" style="margin-bottom: 15px;display:none">
											<div class="asl T-I-J3 J-J5-Ji" style="margin-bottom: -5px;"></div>
											Invalid Date
										</div>
										<div style="float:left;padding-right:10px">
											<label for="ri_selectdate" class="el">Select date</label>
											<br><input id="ri_selectdate" class="rbx nr">
										</div>
										<div style="float:left;padding-right:10px">
											<label for="ri_selecttime" class="el">
												time <span class="font-gray">(24h format)</span>
											</label>
											<br><input id="ri_selecttime" class="rbx nr" style="width:120px" autocomplete="OFF">
										</div>
										<div style="float:left">
											<label for="ri_selecttimezone" class="el">timezone (optional)</label>
											<br><input id="ri_selecttimezone" class="rbx nr" style="width:120px" autocomplete="OFF">
										</div> 
										<div style="clear:both;"></div>
									</div>
									<div class="Kj-JD-Jl">
										<button id="ri_b2" class="J-at1-atl"> Add reminder </button>
										<button id="ri_b1" class="J-at1-auR"> Cancel </button>
									</div>
									-->
								</div>
								"""
			@open: (title, onClose) ->
				body = $ 'body'
				@BG.appendTo body
				obj =
					id: 	_.uniqueId 'modalDialog-'
					title: 	title

				dialog = $ @dialog obj
				closeButton = dialog.find "[act='close']"
				closeButton.on 'click', (e) =>
					@BG.detach()
					dialog.remove()
					onClose?()
					return
				dialog.appendTo body
				dialog


	class M
		debug: 	false
		dev: 	false
		
		@CLS: 			'mailfred'
		#@CLS_NAV: 		M.CLS + '-nav'
		@CLS_THREAD: 	M.CLS + '-thread'
		@CLS_POPUP: 	M.CLS + '-popup'
		@CLS_MENU: 		M.CLS + '-menu'
		@CLS_PICKER: 	M.CLS + '-picker'

		@ID_PREFIX: 	M.CLS + '-id-'

		@TYPE_THREAD: 	'thread'
		@TYPE_NAV: 		'nav'

		@GM_SEL:
			ARCHIVE_BUTTON: 	'.T-I.J-J5-Ji.lR.T-I-ax7.T-I-Js-IF.ar7'
			THREAD_BUTTON_BAR: 	'.iH > div'

		# production URL
		prodUrl: "https://script.google.com/macros/s/AKfycbzWm8LljtgQreQt2DoGe7g-fiZeXwjgy4rZQXw8CY7aFnucKtk/exec"

		# dev URL
		devUrl: "https://script.google.com/a/macros/feth.com/s/AKfycbwriDyhVS8RTcPDEvd1p_OZSc2w9r2pUd1ZtDhp6xo/dev"

		# Current GMail address of the logged in user
		currentGmail: null

		currentView: null

		constructor: ->
			window.addEventListener "message", @gmailrListener, false
			
			chrome.extension.sendMessage {action: "setting", key: 'debug'}, (debug) =>
				@debug = debug
				log 'MailFred debugging is enabled'
				return

			
		inConversation: ->
			@currentView is 'conversation'

		activateArchiveButton: ->
			return unless @inConversation()
			button = ($ M.GM_SEL.ARCHIVE_BUTTON).get 0
			if button
				Eventr.simulate button, 'mousedown'
				Eventr.simulate button, 'mouseup'
			return

		getSettingEmail: (resp) ->
			chrome.extension.sendMessage {action: "setting", key: 'email'}, resp
			return

		gmailrListener: (e) =>
			if e.source is window
				# We only accept messages from ourselves
				#log "event", e

				if e.data?.from is "GMAILR"
					# log 'Got Gmailr event: ', e.data.event.type
					evt = e.data.event
					switch evt.type
						when 'init'
							@currentGmail = evt.email
							GMailUI.Breadcrumbs.add (__msg 'extName'), -> GMailUI.ModalDialog.open (__msg 'extName')

						when 'viewThread'
							@inject()
						when 'viewChanged'
							@currentView = evt.args[0]
							log "User switched to #{@currentView} view"
							@inject()

			return

		inject: ->
			return unless @inConversation()
			@getSettingEmail (settingEmail) =>
				log 'Email address in settings', settingEmail
				log 'Email address of current Gmail window', @currentGmail

				@injectThread() if (not settingEmail or not @currentGmail) or @currentGmail.trim() in settingEmail.split /[, ]+/ig
				return
			return

		getServiceURL: ->
			if @dev then @devUrl else @prodUrl

		#injectCompose: ->
		#	navs = ($ ".dW.E[role=navigation] > .J-Jw").filter (index) ->
		#		($ ".#{M.CLS_NAV}", @).length is 0
		#
		#	navs.append @composeButton M.TYPE_NAV if navs.length > 0
		#	return

		injectThread: ->
			log 'Injecting buttons in thread view'
			threads = ($ M.GM_SEL.THREAD_BUTTON_BAR).filter (index) ->
				($ ".#{M.CLS_THREAD}", @).length is 0
			
			threads.append @composeButton M.TYPE_THREAD if threads.length > 0
			return

		composeButton: (type) =>
			cls = [M.CLS]

			switch type
				when M.TYPE_THREAD
					cls.push M.CLS_THREAD
				when M.TYPE_NAV
					cls.push M.CLS_NAV

			div = $ "<div class='G-Ni J-J5-Ji #{cls.join ' '}'>"

			item = $	"""
						<div class="T-I J-J5-Ji T-I-Js-IF ar7 ns T-I-ax7 L3" data-tooltip="#{__msg 'extName'}" aria-label="#{__msg 'extName'}" role="button" tabindex="0" aria-expanded="false" aria-haspopup="true" style="-webkit-user-select: none;">
							<div class="asa">
								<span class="J-J5-Ji ask">&nbsp;</span>
								<div class="ase T-I-J3 J-J5-Ji"></div>
							</div>
							<div class="G-asx T-I-J3 J-J5-Ji">&nbsp;</div>
						</div>
						"""

			div.append item

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
					menu.addClass M.CLS_MENU
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
						element.attr 'id', _.uniqueId M.ID_PREFIX

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
					picker.addClass M.CLS_PICKER

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


										<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; ">#{__msg 'menuMailActions'}</div>

										<div style="-webkit-user-select: none;">
											<div act="unread" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="#{__msg 'mailActionMarkUnreadTitle'}">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>#{__msg 'mailActionMarkUnread'}
												</div>
											</div>

											<div act="star" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="#{__msg 'mailActionStarTitle'}">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div><span act="and_star" style="display: none">#{__msg 'mailActionAndPrefix'}</span> #{__msg 'mailActionStar'}
												</div>
											</div>

											<div act="inbox" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="#{__msg 'mailActionMoveToInboxTitle'}">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div><span act="and_inbox" style="display: none">#{__msg 'mailActionAndPrefix'}</span> #{__msg 'mailActionMoveToInbox'}
												</div>
											</div>

											<div style="-webkit-user-select: none;"></div>
										</div>


										<div act="when_section" style="display: none">
											<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>
											<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; ">#{__msg 'menuTime'}</div>

											<div>
												<div class="J-N J-Ks" role="menuitem" style="-webkit-user-select: none; " act="presets">
													<div class="J-N-Jz">
														<div class="J-N-Jo"></div>
														<span class="default">#{__msg 'menuTimePresetCloseFuture'}</span><span class="selected"></span>
														<span class="J-Ph-hFsbo"></span>
													</div>
												</div>
												<div class="J-N J-Ks" role="menuitem" style="-webkit-user-select: none; " act="manual">
													<div class="J-N-Jz">
														<div class="J-N-Jo"></div>
														<span class="default">#{__msg 'menuTimePresetSpecifiedDate'}</span><span class="selected"></span>
														<span class="J-Ph-hFsbo"></span>
													</div>
												</div>
											</div>
										</div>

										<div act="noanswer_section" style="display: none">
											<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>

											<div act="noanswer" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="#{__msg 'menuConstraintsNoAnswerTitle'}">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>#{__msg 'menuConstraintsNoAnswer'}
												</div>
											</div>
											<div act="archive" class="J-LC" aria-checked="false" role="menuitem" style="-webkit-user-select: none;" title="#{__msg 'menuAdditionalActionsArchiveTitle'}">
												<div class="J-LC-Jz" style="-webkit-user-select: none;">
													<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div>#{__msg 'menuAdditionalActionsArchive'}
												</div>
											</div>
										</div>

										<div act="error" class="b7o7Ic" style="-webkit-user-select: none;">
											<div class="J-Kh" style="-webkit-user-select: none; "></div>
											<div class="asd ja" style="-webkit-user-select: none; ">
												<span act="when" style="display: none;">#{__msg 'errorNoTimeSpecified'}</span>
												<span act="what">#{__msg 'errorNoActionSpecified'}</span>
											</div>
										</div>
										<div act="submit" style="display: none;">
											<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>

											<div act="schedule" class="J-JK" role="menuitem" style="-webkit-user-select: none;">
												<div class="J-JK-Jz" style="-webkit-user-select: none;" title="#{__msg 'buttonScheduleTitle'}">
													#{__msg 'buttonSchedule'}
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

					popup.addClass M.CLS_POPUP
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
					ands 				= {}
					for op in actionOps
						ret = popup.find "[act='and_#{op}']"
						ands[op] = ret if ret.length > 0

					noanswer_section 	= popup.find "[act='noanswer_section']"
					when_section 		= popup.find "[act='when_section']"
					error_when 		 	= popup.find "[act='when']"
					error_what 		 	= popup.find "[act='what']"

					reposition = (menuElement, target) ->
						ppos = popup.position()
						target.css
							top: 	menuElement.position().top + ppos.top
							left: 	ppos.left + popup.outerWidth()
						return

					_delta = (offset) ->
						"delta:#{offset}"

					_specified = (time) ->
						"specified:#{time}"

					# Picker
					popup.parent().append picker
					locale = window.navigator.language
					$.datepicker.setDefaults $.datepicker.regional[ if locale isnt 'en' then locale else '' ]

					datePicker.datepicker
									minDate: '+1d'
									dateFormat: __msg 'dateFormat'
									showOtherMonths: true
									selectOtherMonths: true
									changeMonth: true
									changeYear: true
									onSelect: (dateText, inst) ->
														date = datePicker.datepicker 'getDate'
														if date
															props.when = _specified date.getTime()
															toggle manual, 'J-Ks-KO', true, true
															toggle menu.children(), 'J-Ks-KO', false, false
															(manual.find '.selected').html __msg 'menuTimePresetSpecifiedDateOnDate', dateText
														isValid()
														return
					manual.hover 		((e) ->
											picker.inMenu = true

											x = =>
												return unless picker.inMenu
												reposition $(@), picker
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
												reposition $(@), menu
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

					boxSelectedClass = 'J-LC-JR-Jp'

					props =
						noanswer: 	false
						unread:		false
						star:		false
						inbox:		false
						archive:	false
						#when:		_delta _1m

					_.each props, (v, op) ->
						selected = !! store.get "selection_act_#{op}"
						props[op] = selected
						toggle (popup.find "[act='#{op}']"), boxSelectedClass, selected, false
						return

					# This shows the error message or the submit button
					boxToggle popup.find('.J-LC'), boxSelectedClass, false, (e, checked) ->
						op = e.attr 'act'
						props[op] = checked
						store.set "selection_act_#{op}", checked
						isValid()
						return

					isValid = ->
						actionToggle = false
						for op,i in actionOps
							ands[op].toggle !!actionToggle if i > 0
							actionToggle |= props[op]

						wat = !! (props.unread or props.star or props.inbox)
						wen  = !! props.when

						valid = wat and wen

						error_what.toggle not wat
						error_when.toggle wat and not wen
						
						noanswer_section.toggle valid
						when_section.toggle wat
						submit.toggle valid
						error.toggle !valid
						reposition manual, picker
						reposition presets, menu
						return


					isValid()

					aME = (keySuffix, x, t) ->
						key = "menuTimePresetCloseFutureItem#{keySuffix}"
						addMenuElement (__msg key), false, presets, (e, checked) ->
							if checked
								props.when = t x
								(presets.find '.selected').html __msg "#{key}Selected"
							isValid()
							return

					if self.debug
						for minute in [1,5]
							aME "Minutes#{minute}", minute, (minute) ->
								log "in #{minute} minute"
								_delta (_1m * minute)

					for hour in [1,4]
						aME "Hours#{hour}", hour, (hour) -> 
							log "in #{hour} hour"
							_delta (_1h * hour)

					for hour in [8,14]
						aME "Tomorrow#{hour}", hour, (hour) ->
							log "tomorrow, #{hour}h"
							now = new Date
							tomorrow = new Date
							tomorrow.setDate (now.getDate() + 1)
							tomorrow.setHours hour
							tomorrow.setMinutes 0
							tomorrow.setSeconds 0
							tomorrow.setMilliseconds 0
							_specified tomorrow.getTime()

					for day in [2,7,14]
						aME "Days#{day}", day, (day) ->
							log "in #{day} day"
							_delta (_1d * day)

					for month in [1]
						aME "Months#{month}", month, (month) ->
							log "in #{month} month"
							now = new Date
							tomorrow = new Date
							tomorrow.setMonth (now.getMonth() + month)
							_specified tomorrow.getTime()

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
			id = /\/([0-9a-f]{16})/.exec window.location.hash
			if id is null
				throw __msg 'errorNotWithinAConversation'
			else
				id[1]

		onSchedule: (props, loadingIcon, resetIcon) =>
			try
				messageId = @getMessageId()
			catch e
				chrome.extension.sendMessage
					error: e.toString()
				return

			data = 
				action:		'schedule'
				messageId:	messageId
				when:		props.when
				unread:		!!props.unread
				star:		!!props.star
				noanswer:	!!props.noanswer
				inbox:		!!props.inbox
				archive:	!!props.archive
				#callback:	'alert'

			log 'scheduling mail...', data

			loadingIcon?() unless data.archive

			# remove false values to transmit less data over the wire
			_.each data, (val, key) ->
				delete data[key] if val is false
				return

			
			$.ajax
				url: 			@getServiceURL()
				dataType: 		'json'
				data:			data
				success:		(data, textStatus, jqXHR) =>
									@onScheduleSuccess data
									return
				error:			(jqXHR, textStatus, errorThrown) =>
									log arguments
									@onScheduleError data, textStatus, errorThrown
									return
				complete:		(jqXHR, textStatus) ->
									resetIcon?() unless data.archive
									return

			if data.archive
				@activateArchiveButton()
			else
				_.delay (->
						resetIcon?()
						return
						), 400
			return


		onScheduleSuccess: (data) =>
			log 'Scheduling success', data
			chrome.extension.sendMessage
				action: 	'notification'
				icon: 		"images/tie48x48.png"
				title: 		__msg 'notificationScheduleSuccessTitle'
				message: 	__msg 'notificationScheduleSuccess'
			return

		onScheduleError: (params, status, error) =>
			log 'There was an error', arguments
			if status is 'parsererror'
				params.action = 'setup'
				delete params.callback if params.callback

				query = $.param params
				window.open "#{@getServiceURL()}?#{query}", M.CLS, 'width=860,height=470,location=0,menubar=0,scrollbars=0,status=0,toolbar=0,resizable=1'
			else
				notification =
					action: 	'notification'
					icon: 		"images/tie48x48.png"
					title:		__msg 'notificationScheduleErrorTitle'
					message:	__msg 'notificationScheduleError', ''+error

				# we get 'InvalidScheduleTime' and we need to add 'notificationScheduleError' to it
				message = __msg "notificationScheduleError#{error}"
				notification.message = message if message

				chrome.extension.sendMessage notification

			return

	mb = new M
	return

) jQuery, window if top.document is document