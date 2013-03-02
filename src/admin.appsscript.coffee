class Admin
	@ACTIONS:
		OVERVIEW: 'overview'
		MAILS: 'mails'
		REMOVE: 'remove'

	DB: MailButlerDBLibrary.Db

	getUsers: ->
		@DB.getUsers()
	getMails: (user) ->
		@DB.getMails user
	removeById: (id) ->
		@DB.removeById id

doGet = (request) ->
	a = new Admin()
	url = ScriptApp.getService().getUrl()

	switch request.parameter.action
		when Admin.ACTIONS.OVERVIEW
			t = HtmlService.createTemplateFromFile 'admin_usertable'
			t.f =
				getMails: (u) -> (a.getMails u).getSize()
			t.users = a.getUsers()
			t.baseUrl = url
			t.evaluate()
		when Admin.ACTIONS.MAILS
			u = request.parameter.user
			return unless u
			t = HtmlService.createTemplateFromFile 'admin_mailtable'
			t.baseUrl = url
			t.user = u
			t.emails = a.getMails u
			t.evaluate()
		when Admin.ACTIONS.REMOVE
			id = request.parameter.id
			return ContentService.createTextOutput 'No ID given' unless id
			a.removeById id
			ContentService.createTextOutput 'Removed'
		else
			t = HtmlService.createTemplateFromFile 'admin_default'
			t.baseUrl = url
			t.actions = Admin.ACTIONS
			t.evaluate()



`function _doGet() {
  doGet.apply(null, {parameter: {action: 'overview'}});
}`