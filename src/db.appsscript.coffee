class Db
	@DB:			ScriptDb.getMyDb()

	@TYPE_MAIL:		'mail'
	@TYPE_USER:		'user'

	@getMails: (user, version, time, processed = null, messageId = null) ->
		q =
			type:		@TYPE_MAIL

		q.user = user if user
		q.version = @DB.lessThanOrEqualTo Number version if version
		q.when = @DB.lessThanOrEqualTo Number time if time
		q.processed = !! processed if processed isnt null
		q.messageId = messageId if messageId

		Logger.log 'getting mails with query %s', q

		result = @DB.query q
		result = result.sortBy 'processed', @DB.ASCENDING, @DB.NUMERIC
		result = result.sortBy 'when', @DB.ASCENDING, @DB.NUMERIC
		result

	@getLastScheduled: (user) ->
		result = @DB.query
			type:		@TYPE_MAIL
			user:		user
		result = result.sortBy 'scheduled', @DB.DESCENDING, @DB.NUMERIC
		result = result.limit 1
		if result.hasNext()
			result.next().scheduled
		else
			-1

	@getUsers: ->
		q =
			type: @TYPE_USER
		result = @DB.query q
		result = result.sortBy 'user'
		result

	@cancelMails: (user, messageId) ->
		scheduledMails = @getMails user, null, null, false, messageId
		modified = while result.hasNext()
			mail.next().processed = 'canceled'

		if modified.length > 0
			@DB.saveBatch modified, false
			@DB.allOk modified
		else
			true

	@storeMail: (user, version, props) ->
		return null if not props or not user or not version
		props.user = user
		props.version = version
		props.type = @TYPE_MAIL
		props.processed = false

		@cancelMails user, props.messageId
		@DB.save props

	@removeMail: (mail) ->
		ret = @DB.remove mail if mail.type is @TYPE_MAIL
		ret

	@updateMail: (entity) ->
		return unless entity.type in [@TYPE_MAIL]
		@DB.save entity

	@now: ->
		(new Date()).getTime()

	@getOrCreateUser: (user) ->
		entity =
			type: @TYPE_USER
			user: user

		result = @DB.query entity
		if result.hasNext()
			entity = result.next()
		else
			now = @now()

			entity.active	= true
			entity.until	= -1
			entity.signup	= now
			entity.lastUsed	= now
			entity.version	= 0
			
			entity = @DB.save entity
		entity

	@setCurrentVersion: (user, version) ->
		user = @getOrCreateUser user
		if user.version isnt version
			user.version = version
			user = @DB.save user
		user

	@getCurrentVersion: (user) ->
		(@getOrCreateUser user).version ? 0

	@setLastUsed: (user) ->
		user = @getOrCreateUser user
		now = @now()
		if user.lastUsed isnt now
			user.lastUsed = now
			user = @DB.save user
		user

	@isEnabled: (user, version) ->
		user = @getOrCreateUser user
		# User must be active
		ret = user.active
		# have paid until now
		ret &= user.until >= @now() if user.until isnt -1
		# and the version of the script calling this method is higher or the same the user used lastly
		ret &= version >= user.version if user.version
		ret

	@isCurrent: (user, version) ->
		version >= @getCurrentVersion user

	@removeById: (id) ->
		@DB.removeById id

_showMails = (user, version, time) ->
	result = Db.getMails user, version, time
	Logger.log 'There are %s scheduled mails', result.getSize()
	while result.hasNext()
		Logger.log result.next()
	return

`function showMails() {
	_showMails();
}`

_showUsers = ->
	result = Db.getUsers()
	Logger.log 'There are %s users', result.getSize()
	while result.hasNext()
		Logger.log result.next()
	return

`function showUsers() {
	_showUsers();
}`

`function showToScheduleMailsForUser() {
	var now = new Date().getTime();
	_showMails('joscha@feth.com','1.09',now);
}`


