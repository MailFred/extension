settings =
  url: 'https://api.mailfred.de'
  # use the following with
  # --allow-running-insecure-content
  # to allow non-HTTPS calls
  #url: 'http://localhost:8080'

NOTIFICATION_ID = 'mailfred.notification'

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  # console.log 'got message', request

  switch request.action
    when 'notification'
      chrome.notifications.clear NOTIFICATION_ID, ->

      opt =
        type: "basic"
        title: request.title
        message: request.message
        iconUrl: request.icon
      chrome.notifications.create NOTIFICATION_ID, opt, ->

    when 'version'
      ret = chrome.app.getDetails().version

    else
      ret = settings[request.action]

  sendResponse? ret
  false # we don't want to message back anything after the script finished
