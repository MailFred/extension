class Db
	@DB:			ScriptDb.getMyDb()

	@TYPE_MAIL:		'mail'
	@TYPE_USER:		'user'

	@getMails: (user, version, time) ->
		q =
			type:		@TYPE_MAIL

		q.user = user if user
		q.version = @DB.lessThanOrEqualTo version if version
		q.when = @DB.lessThanOrEqualTo time if time

		result = @DB.query q
		result = result.sortBy 'when'
		result

	@storeMail: (user, version, props) ->
		return null if not props or not user or not version
		props.user = user
		props.version = version
		props.type = @TYPE_MAIL

		@DB.save props

	@removeMail: (mail) ->
		ret = @DB.remove mail if mail.type is @TYPE_MAIL
		ret

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
		user.version = version
		@DB.save user

	@getCurrentVersion: (user) ->
		(@getOrCreateUser user).version ? 0

	@setLastUsed: (user) ->
		user = @getOrCreateUser user
		user.lastUsed = @now()
		@DB.save user

	@isEnabled: (user, version) ->
		user = @getOrCreateUser user
		now = (new Date()).getTime()
		# User must be active
		ret = user.active
		# have paid until now
		ret &= user.until >= now if user.until isnt -1
		# and the version of the script calling this method is higher or the same the user used lastly
		ret &= version >= user.version if user.version
		ret

	@isCurrent: (user, version) ->
		version >= @getCurrentVersion user


`function showDb() {
  var result = Db.getMails()
  Logger.log('Size: %s', result.getSize());
  while(result.hasNext()) {
    Logger.log(result.next());
  }
}`

