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

		@STORE:
			LASTUSED:		'lastUsed'
			BOX_SETTING:	'settings'
			DEBUG:			'debug'
			EMAIL:			'email'
			LAST_VERSION:	'lastVersion'

		@GM_SEL:
			ARCHIVE_BUTTON: 	'.T-I.J-J5-Ji.lR.T-I-ax7.T-I-Js-IF.ar7:visible'
			THREAD_BUTTON_BAR: 	'.iH > div'

		# URL
		url: null

		# Current GMail address of the logged in user
		currentGmail: null
		settingEmail: null
		settingProps: {}
		lastUsed: []

		currentView: null

		constructor: ->
			window.addEventListener "message", @messageListener, false
			
			# Get the settings
			chrome.storage.local.get null, (items) =>
				_.each items, (value, key) =>
					switch key
						when M.STORE.DEBUG
							@debug = value
							log 'MailFred debugging is enabled'
						when M.STORE.EMAIL
							@settingEmail = value
					return
				return

			# Get the selected options
			chrome.storage.sync.get M.STORE.BOX_SETTING, (items) =>
				@settingProps = items[M.STORE.BOX_SETTING]
				return

			# Get the last used presets
			M.getLastUsed (lastUsed) =>
				@lastUsed = lastUsed
				return

			# Get the service URL
			chrome.extension.sendMessage {action: 'url'}, (url) =>
				@url = url
				@checkVersion()
				return

		@storeLastVersion: (version) ->
			store = {}
			store[M.STORE.LAST_VERSION] = version
			chrome.storage.sync.set store, ->
				log 'Set the last used version to', version
				return
			return

		@getLastVersion: (resp) ->
			chrome.storage.sync.get M.STORE.LAST_VERSION, (items) =>
				resp items[M.STORE.LAST_VERSION]
				return
			return

		@isAuthorisationErrorPage: (contents) ->
			/require.*?authorization/i.test contents

		checkAuthorised: (resp) ->
			url = @getServiceURL()
			log 'checking if the user authorised', url
			$.ajax
				url: 			url
				dataType: 		'json'
				data:			action: 'status'
				success:		(data, textStatus, jqXHR) =>
									log '...yes'
									resp true
									return
				error:			(jqXHR, textStatus, errorThrown) =>
									isError = M.isAuthorisationErrorPage jqXHR.responseText
									resp !isError
									return

		firstInstall: (version) ->
			log 'first install', version
			@welcome()
			return

		upgradeInstall: (oldVersion, newVersion) ->
			log 'upgrade from', oldVersion, newVersion
			@checkAuthorised (authorised) =>
				@gettingStarted action: 'setupNoSchedule' unless authorised
				return
			return

		sameInstall: (version) ->
			log 'no version change', version
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

		messageListener: (e) =>
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
							# GMailUI.Breadcrumbs.add (__msg 'extName'), => @gettingStarted()

						when 'viewThread'
						# User moves to previous or next convo
							@inject()
						when 'viewChanged'
						# User switches view (conversation <-> threads)
							@currentView = evt.args[0]
							log "User switched to #{@currentView} view"
							@inject()

			return

		checkVersion: ->
			# Get the extension version
			chrome.extension.sendMessage {action: "version"}, (version) =>
				M.getLastVersion (lastVersion) =>
					unless lastVersion
						M.storeLastVersion version
						@firstInstall version
					else if lastVersion < version
						M.storeLastVersion version
						@upgradeInstall lastVersion, version
					else
						@sameInstall version
					return
				return
			return

		inject: ->
			return unless @inConversation()
			log 'Email address in settings', @settingEmail
			log 'Current Gmail window', @currentGmail

			@injectThread() if (not @settingEmail or not @currentGmail) or @currentGmail.trim() in @settingEmail.split /[, ]+/ig
			return

		getServiceURL: -> @url

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

			_.each props, (v, op) =>
				selected = !! @settingProps[op]
				props[op] = selected
				return

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
					toStore = {}
					toStore[M.STORE.BOX_SETTING] = props
					chrome.storage.sync.set toStore, ->
						log 'Storing properties finished'
						return
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

			pickerDiv = (pickerMenu.append new GMailUI.RawHTML '<div>').getElement()

			initPicker = false
			pickerMenu.onShow = =>
				unless initPicker
					locale = window.navigator.language
					$.datepicker.setDefaults $.datepicker.regional[ if locale isnt 'en' then locale else '' ]
					pickerDiv.datepicker
									minDate: '+1d'
									maxDate: '+1y'
									dateFormat: __msg 'dateFormat'
									showOtherMonths: true
									selectOtherMonths: true
									changeMonth: true
									changeYear: true
									onSelect: (dateText, inst) =>
														if (date = pickerDiv.datepicker 'getDate')
															#timeSectionElements.manual.setSelected true, true
															log 'schedule', date
															schedule @_specified date.getTime()
														return
					initPicker = true
				return

			# Time section

			timeSection = popup.append new GMailUI.Section
			timeSection.append new GMailUI.Separator
			timeSection.append new GMailUI.PopupLabel __msg 'menuTime'

			
			unless _.isEmpty @lastUsed
				lastUsedSection = timeSection.append new GMailUI.Section

				_.each @lastUsed, (tuple) =>
					key = tuple.key
					time = tuple.time
					# Remove the last used presets from the list
					presets[key] = _.without presets[key], time if presets[key]

					[label, title] = @getTexts key, time
					button = lastUsedSection.append new GMailUI.Button label, title
					timeFn = @generateTimeFn key
					button.on 'click', (e) =>
						M.storeLastUsed key, time
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
								M.storeLastUsed key, time
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

		@storeLastUsed: (key, time) ->
			@getLastUsed (lastUsed) =>
				entry =
					key: key
					time: time

				lastUsed = _.reject lastUsed, (item) -> _.isEqual item, entry

				lastUsed.unshift entry
				store = {}
				lastUsed = store[@STORE.LASTUSED] = (_.first lastUsed, 3)
				chrome.storage.sync.set store, ->
					log 'Last used items saved', lastUsed
					return
				return
			return

		@getLastUsed: (resp) ->
			chrome.storage.sync.get @STORE.LASTUSED, (items) =>
				resp (items[@STORE.LASTUSED] ? [])
				return
			return

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
				when 'months'
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
									# log arguments
									@onScheduleError textStatus, data, errorThrown, jqXHR.responseText
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

		createDialog: (title, okButton, cancelButton) ->
			dialog = new GMailUI.ModalDialog title

			[okButtonLabel, okButtonTooltip] = okButton
			[cancelButtonLabel, cancelButtonTooltip] = cancelButton

			container = dialog.append new GMailUI.ModalDialog.Container

			footer = dialog.append new GMailUI.ModalDialog.Footer
			okButton = footer.append new GMailUI.ModalDialog.Button okButtonLabel, okButtonTooltip
			cancelButton = footer.append new GMailUI.ModalDialog.Button cancelButtonLabel, cancelButtonTooltip, 'cancel'

			[dialog, okButton, cancelButton, container, footer]

		welcome: ->
			extName = __msg 'extName'
			[dialog, okButton, cancelButton, container, footer] = @createDialog (__msg 'welcomeDialogTitle', extName), [(__msg 'welcomeDialogButtonOk'), (__msg 'welcomeDialogButtonOkTooltip')], [(__msg 'welcomeDialogButtonCancel'), (__msg 'welcomeDialogButtonCancelTooltip', extName)]
			
			container.append	"""
								<div style="text-align: justify;">
									<img src="#{chrome.extension.getURL 'images/button_example.png'}" data-tooltip="#{__msg 'welcomeDialogImageHint'}" alt="#{__msg 'welcomeDialogImageAlt'}" align="right" style="padding-left: 10px; padding-bottom: 10px;">
									#{__msg 'welcomeDialogText', extName}
								</div>
								"""

			okButton.on 'click', =>
				[authDialog, authOkButton, authCancelButton, authContainer, authFooter] = @gettingStartedDialog()
				container.replaceWith authContainer
				okButton.replaceWith authOkButton
				cancelButton.replaceWith authCancelButton
				dialog.title authDialog.title()

				authOkButton.on 'click', =>
					@openAuthWindow action: 'setupNoSchedule'
					dialog.close()
					return

				authCancelButton.on 'click', dialog.close

			cancelButton.on 'click', dialog.close
			dialog.open()

		gettingStartedDialogContent: ->
			extName = __msg 'extName'
			"""
			<div style="float: left; width: 250px; text-align: justify; padding-right: 10px;">
				#{__msg 'authorizeDialogText', extName}
			</div>
			<div>
				<img src="#{chrome.extension.getURL 'images/clickToAuthorize.png'}" data-tooltip="#{__msg 'authorizeDialogImageHint'}" alt="#{__msg 'authorizeDialogImageAlt'}">
			</div>
			"""

		gettingStartedDialog: ->
			extName = __msg 'extName'
			[dialog, okButton, cancelButton, container, footer] = @createDialog (__msg 'authorizeDialogTitle', extName), [(__msg 'authorizeDialogButtonOk'), (__msg 'authorizeDialogButtonOkTooltip')], [(__msg 'authorizeDialogButtonCancel'), (__msg 'authorizeDialogButtonCancelTooltip', extName)]
			container.append @gettingStartedDialogContent()
			[dialog, okButton, cancelButton, container, footer]

		gettingStarted: (params) ->
			[dialog, okButton, cancelButton, container, footer] = @gettingStartedDialog()
			
			okButton.on 'click', =>
				@openAuthWindow params
				dialog.close()
				return

			cancelButton.on 'click', dialog.close

			dialog.open()

		openAuthWindow: (params) ->
			url = @getServiceURL()
			if params
				query = $.param params
				url += "?#{query}"
			window.open url, M.CLS, 'width=860,height=470,location=0,menubar=0,scrollbars=0,status=0,toolbar=0,resizable=1'
			return

		onScheduleError: (status, params, error, responseText) =>
			log 'There was an error', arguments
			if status is 'parsererror' and M.isAuthorisationErrorPage responseText
				params.action = 'setup'
				delete params.callback if params.callback
				@gettingStarted params
			else
				notification =
					action: 	'notification'
					icon: 		"images/tie48x48.png"
					title:		__msg 'notificationScheduleErrorTitle'
					message:	if 'code' of error then (__msg "notificationScheduleError#{error.code}") else (__msg 'notificationScheduleError', '' + new String error)

				chrome.extension.sendMessage notification

			return

	mb = new M
	return

) jQuery, window if top.document is document