settings =
  url: 'https://api.mailfred.de'
  # use the following with
  # --allow-running-insecure-content
  # to allow non-HTTPS calls
  #url: 'http://localhost:8080'

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
