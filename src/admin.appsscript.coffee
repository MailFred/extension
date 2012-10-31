class Admin
	@ACTIONS:
		OVERVIEW: 'overview'
		MAILS: 'mails'

	DB: MailButlerDBLibrary.Db

	getUsers: ->
		@DB.getUsers()
	getMails: (user) ->
		@DB.getMails user

doGet = (request) ->
	a = new Admin()

	switch request.parameter.action
		when Admin.ACTIONS.OVERVIEW
			t = HtmlService.createTemplateFromFile 'admin_usertable'
			t.users = a.getUsers()
			t.baseUrl = ScriptApp.getService().getUrl()
		when Admin.ACTIONS.MAILS
			u = request.parameter.user
			return unless u
			t = HtmlService.createTemplateFromFile 'admin_mailtable'
			t.user = u
			t.emails = a.getMails u
		else
			t = HtmlService.createTemplateFromFile 'admin_default'
			t.baseUrl = ScriptApp.getService().getUrl()
			t.actions = Admin.ACTIONS
	t.evaluate()



`function _doGet() {
  doGet.apply(null, {parameter: {action: 'overview'}});
}`