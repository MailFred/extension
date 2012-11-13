(($, window) ->

	log = (args...) ->
		console.log.apply console, args if console?.log and mb?.debug is true
		return

	#__msg = (args...) ->
	#	ret = chrome.i18n.getMessage.apply chrome.i18n, args
	#	log args, ret
	#	ret
	__msg = chrome.i18n.getMessage

	class M
		debug: 	false
		dev: 	false
		
		@CLS: 			'mailfred'
		#@CLS_NAV: 		M.CLS + '-nav'
		@CLS_THREAD: 	M.CLS + '-thread'
		@CLS_POPUP: 	M.CLS + '-popup'
		@CLS_MENU: 		M.CLS + '-menu'
		@CLS_PICKER: 	M.CLS + '-picker'
		@CLS_LOADER: 	M.CLS + '-loader'

		@ID_PREFIX: 	M.CLS + '-id-'

		@TYPE_THREAD: 	'thread'
		@TYPE_NAV: 		'nav'

		@STOREJS:
			LASTUSED: 'lastUsed'
			BOX_PREFIX: 'selection_act_'

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
						# GMailr is ready
							@currentGmail = evt.email
							GMailUI.Breadcrumbs.add (__msg 'extName'), -> GMailUI.ModalDialog.open (__msg 'extName')

						when 'viewThread'
						# User moves to previous or next convo
							@inject()
						when 'viewChanged'
						# User switches view (conversation <-> threads)
							@currentView = evt.args[0]
							log "User switched to #{@currentView} view"
							@inject()

			return

		inject: ->
			return unless @inConversation()
			@getSettingEmail (settingEmail) =>
				log 'Email address in settings', settingEmail
				log 'Current Gmail window', @currentGmail

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

		actionOps: [
					'unread'
					'star'
					'inbox'
					]

		ucFirst: (str) ->
			str[0].toUpperCase() + str.substring(1).toLowerCase()

		getTexts: (key, time) ->
			i18nKey = @ucFirst key
			x = "menuTimePresetCloseFutureItem#{i18nKey}#{time}"
			[
				(__msg "#{x}Selected")
				(__msg x)
			]

		composeButton: (type) =>

			props =
				noanswer: 	false
				unread:		false
				star:		false
				inbox:		false
				archive:	false
				#when:		_delta _1m

			schedule = (wen) =>
				pickerMenu.close()
				presetMenu.close()
				button.close()

				loading = ->
					button.addClass M.CLS_LOADER
					return
				reset = ->
					button.removeClass M.CLS_LOADER
					return

				props.when = wen
				@onSchedule props, loading, reset

				return

			_.each props, (v, op) ->
				selected = !! store.get "#{M.STOREJS.BOX_PREFIX}#{op}"
				props[op] = selected
				return

			isValid = =>
				valid = false
				for op in @actionOps
					valid |= props[op]
				valid = !!valid
				timeSection.toggle valid
				constraintSection.toggle valid
				errorSection.toggle !valid
				return

			propStoreFn = (checkbox, propName) ->
				checkbox.addOnChange (e, checked) ->
					props[propName] = checked
					store.set "#{M.STOREJS.BOX_PREFIX}#{propName}", checked
					isValid()
				return

			presets = {}
			presets.minutes 	= [1,5] if @debug
			presets.hours 		= [2,4]
			presets.tomorrow 	= [8,14]
			presets.days 		= [2,7,14]
			presets.months 		= [1]

			# UI

			bar = new GMailUI.ButtonBar
			bar.addClass M.CLS
			bar.addClass M.CLS_THREAD

			popup = new GMailUI.Popup
			popup.addClass M.CLS_POPUP

			popup.append new GMailUI.PopupLabel __msg 'menuMailActions'

			# Actions section

			actionSection = popup.append new GMailUI.Section
			actionSectionCheckboxes =
				unread: actionSection.append (new GMailUI.PopupCheckbox (__msg 'mailActionMarkUnread'), 	props.unread, 	'', (__msg 'mailActionMarkUnreadTitle'))
				star:	actionSection.append (new GMailUI.PopupCheckbox (__msg 'mailActionStar'), 			props.star, 	'', (__msg 'mailActionStarTitle'))
				inbox:	actionSection.append (new GMailUI.PopupCheckbox (__msg 'mailActionMoveToInbox'), 	props.inbox, 	'', (__msg 'mailActionMoveToInboxTitle'))

			_.each actionSectionCheckboxes, propStoreFn

			# Constraints section

			constraintSection = popup.append new GMailUI.Section
			constraintSection.append new GMailUI.Separator
			constraintSectionCheckboxes =
				noanswer:	constraintSection.append (new GMailUI.PopupCheckbox (__msg 'menuConstraintsNoAnswer'),		props.noanswer,	'', (__msg 'menuConstraintsNoAnswerTitle'))
				archive:	constraintSection.append (new GMailUI.PopupCheckbox (__msg 'menuAdditionalActionsArchive'), props.archive,	'', (__msg 'menuAdditionalActionsArchiveTitle'))

			_.each constraintSectionCheckboxes, propStoreFn


			presetMenu = new GMailUI.PopupMenu popup
			presetMenu.addClass M.CLS_MENU

			# Date picker

			pickerMenu = new GMailUI.PopupMenu popup
			pickerMenu.addClass M.CLS_PICKER

			datePicker = (pickerMenu.append new GMailUI.RawHTML '<div>').getElement()

			locale = window.navigator.language
			$.datepicker.setDefaults $.datepicker.regional[ if locale isnt 'en' then locale else '' ]

			datePicker.datepicker
							minDate: '+1d'
							maxDate: '+1y'
							dateFormat: __msg 'dateFormat'
							showOtherMonths: true
							selectOtherMonths: true
							changeMonth: true
							changeYear: true
							onSelect: (dateText, inst) =>
												if (date = datePicker.datepicker 'getDate')
													#timeSectionElements.manual.setSelected true, true
													log 'schedule', date
													schedule @_specified date.getTime()
												return

			# Time section

			timeSection = popup.append new GMailUI.Section
			timeSection.append new GMailUI.Separator
			timeSection.append new GMailUI.PopupLabel __msg 'menuTime'

			lastUsed = @getLastUsed()
			unless _.isEmpty lastUsed
				lastUsedSection = timeSection.append new GMailUI.Section

				_.each lastUsed, (tuple) =>
					key = tuple.key
					time = tuple.time
					# Remove the last used presets from the list
					presets[key] = _.without presets[key], time if presets[key]

					[label, title] = @getTexts key, time
					button = lastUsedSection.append new GMailUI.Button label, title
					timeFn = @generateTimeFn key
					button.on 'click', (e) =>
						@storeLastUsed key, time
						wen = timeFn time
						log "schedule: #{time}, #{key}: #{wen}"
						schedule wen
						return
					return
				lastUsedSection.append new GMailUI.Separator

			timeSection.append 				(new GMailUI.PopupMenuItem pickerMenu, (__msg 'menuTimePresetSpecifiedDate'),	'',	'',	true)
			presetItem = timeSection.append (new GMailUI.PopupMenuItem presetMenu, (__msg 'menuTimePresetCloseFuture'), 	'', '',	true)


			# Presets

			sep = null
			_.each presets, (times, key) =>
				unless _.isEmpty times
					presetMenu.append sep if sep
					_.each times, (time) =>
						timeFn = @generateTimeFn key
						[label, title] = @getTexts key, time
						item = new GMailUI.PopupMenuItem presetItem, label, title, '', false
						onChange = (e, checked) =>
							if checked
								@storeLastUsed key, time
								wen = timeFn time
								log "schedule: #{time}, #{key}: #{wen}"
								schedule wen
							return
						item.addOnChange onChange, true
						presetMenu.append item
						return
					sep = new GMailUI.Separator
				return

			button = bar.append new GMailUI.ButtonBarPopupButton popup, '', (__msg 'extName')

			errorSection = popup.append new GMailUI.ErrorSection __msg 'errorNoActionSpecified' # __msg 'errorNoTimeSpecified'

			isValid()

			bar.getElement()

		storeLastUsed: (key, time) ->
			lastUsed = @getLastUsed()
			entry =
				key: key
				time: time

			lastUsed = _.reject lastUsed, (item) -> _.isEqual item, entry

			lastUsed.unshift entry
			store.set M.STOREJS.LASTUSED, (_.first lastUsed, 3)

		getLastUsed: ->
			(store.get M.STOREJS.LASTUSED) ? []

		_delta: (offset) ->
			"delta:#{offset}"

		_specified: (time) ->
			"specified:#{time}"

		generateTimeFn: (unit) ->
			_1d = 24 * (_1h = 60 * (_1m = 60 * 1000))

			switch unit
				when 'minutes'
					(time) => @_delta (_1m * time)
				when 'hours'
					(time) => @_delta (_1h * time)
				when 'tomorrow'
					(hour) =>
						now = new Date
						tomorrow = new Date
						tomorrow.setDate (now.getDate() + 1)
						tomorrow.setHours hour
						tomorrow.setMinutes 0
						tomorrow.setSeconds 0
						tomorrow.setMilliseconds 0
						@_specified tomorrow.getTime()
				when 'days'
					(time) => @_delta (_1d * time)
				when 'month'
					(month) =>
						now = new Date
						other = new Date
						other.setMonth (now.getMonth() + month)
						@_specified other.getTime()
		
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

			archive = !!props.archive

			loadingIcon?() unless archive

			data = 
				action:		'schedule'
				messageId:	messageId
				when:		props.when
				unread:		!!props.unread
				star:		!!props.star
				noanswer:	!!props.noanswer
				inbox:		!!props.inbox
				archive:	archive
				#callback:	'alert'

			# remove false values to transmit less data over the wire
			_.each data, (val, key) ->
				delete data[key] if val is false
				return

			log 'scheduling mail...', data
			
			$.ajax
				url: 			@getServiceURL()
				dataType: 		'json'
				data:			data
				success:		(data, textStatus, jqXHR) =>
									@onScheduleSuccess data
									return
				error:			(jqXHR, textStatus, errorThrown) =>
									log arguments
									@onScheduleError textStatus, data, errorThrown
									return
				complete:		(jqXHR, textStatus) ->
									resetIcon?() unless data.archive
									return

			if archive
				@activateArchiveButton()
			else
				_.delay (->
						resetIcon?()
						return
						), 600
			return


		onScheduleSuccess: (data) =>
			log 'Scheduling success', data
			if data.success
				chrome.extension.sendMessage
					action: 	'notification'
					icon: 		"images/tie48x48.png"
					title: 		__msg 'notificationScheduleSuccessTitle'
					message: 	__msg 'notificationScheduleSuccess'
			else
				@onScheduleError data.error, null, data.error
			return

		onScheduleError: (status, params, error) =>
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