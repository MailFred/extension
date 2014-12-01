
class Settings
  @EMAIL: 'email'
  @DEBUG: 'debug'

__msg = chrome.i18n.getMessage
o =
  "label[for='email']": 'optionsLabelGmailAddress'
  "label[for='debug']": 'optionsLabelDebugging'
  'title':              'optionsPageTitle'
  '#save':              'optionsButtonSaveLabel'
  '#uninstall':         'optionsLinkUninstall'

init = ->
  for sel, key of o
    (document.querySelector sel).innerText = __msg key

  a = document.getElementById 'uninstall'
  a.onclick = ->
    alert __msg 'optionsLinkUninstallConfirm'
    return
  return

save_options = ->
  status = (message) ->
    # Update status to let user know options were saved.
    s = document.getElementById 'status'
    s.innerHTML = message
    setTimeout (->
      s.innerHTML = ''
    ), 750
    return

  store = {}
  input = document.getElementById Settings.EMAIL
  email = input.value
  store[Settings.EMAIL] = email ? null

  input = document.getElementById Settings.DEBUG
  debug = input.checked
  store[Settings.DEBUG] = debug ? false

  chrome.storage.local.set store, ->
    status __msg 'optionsFeedbackOptionsSaved'
    return

  return

# Restores select box state to saved value from localStorage.
restore_options = ->
  chrome.storage.local.get null, (items) ->
    for key, val of items
      switch key
        when Settings.EMAIL
          input = document.getElementById Settings.EMAIL
          input.setAttribute 'value', val
        when Settings.DEBUG
          input = document.getElementById Settings.DEBUG
          input.setAttribute 'checked', val if val
    return
  return

document.addEventListener 'DOMContentLoaded', () ->
  init()
  restore_options()
  document.querySelector('#save').addEventListener 'click', save_options
  return
