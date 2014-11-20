settings =
	url: 'https://sodium-hue-766.appspot.com'

chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
  #console.log(sender.tab "from a content script:" + sender.tab.url :
  #  "from the extension");

  switch request.action
    when 'notification'
      opt =
        type: "basic"
        title: request.title
        message: request.message
        iconUrl: request.icon
      chrome.notifications.create 'mailfred.scheduled', opt, ->

    when 'version'
      ret = chrome.app.getDetails().version

    else
      ret = settings[request.action]

  sendResponse? ret
  false # we don't want to message back anything after the script finished
