class Admin
	DB: MailButlerDBLibrary.Db

	getUsers: ->
		@DB.getUsers()
	getMails: (user) ->
		@DB.getMails user

doGet = (request) ->
	a = new Admin()

	switch request.parameter.action
		when 'overview'
			t = HtmlService.createTemplateFromFile 'admin_usertable'
			t.users = a.getUsers()
			t.baseUrl = ScriptApp.getService().getUrl()
			t.evaluate()
		when 'mails'
			u = request.parameter.user
			return unless u
			t = HtmlService.createTemplateFromFile 'admin_mailtable'
			t.user = u
			t.emails = a.getMails u
			t.evaluate()

`function _doGet() {
  doGet.apply(null, {parameter: {action: 'overview'}});
}`