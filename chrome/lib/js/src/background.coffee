###* global chrome ###
NOTIFICATION_ID = 'mailfred.notification'

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  # console.log 'got message', request
  ret = null

  switch request.action
    when 'notification'
      chrome.notifications.clear NOTIFICATION_ID, ->

      opt =
        type: "basic"
        title: request.title
        message: request.message
        iconUrl: request.icon
      chrome.notifications.create NOTIFICATION_ID, opt, ->

  sendResponse? ret
  false # we don't want to message back anything after the script finished
