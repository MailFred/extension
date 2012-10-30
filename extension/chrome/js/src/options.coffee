
class Settings
  @EMAIL: 'email'
  @DEBUG: 'debug'

__msg = chrome.i18n.getMessage
o =
  "label[for='email']": 'optionsLabelGmailAddress'
  "label[for='debug']": 'optionsLabelDebugging'
  'title':              'optionsPageTitle'
  '#save':              'optionsButtonSaveLabel'

init = ->
  for sel, key of o
    (document.querySelector sel).innerText = __msg key

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

  input = document.getElementById Settings.EMAIL
  email = input.value
  localStorage[Settings.EMAIL] = email ? null

  input = document.getElementById Settings.DEBUG
  debug = input.checked
  localStorage[Settings.DEBUG] = debug ? false

  status __msg 'optionsFeedbackOptionsSaved'

  return

# Restores select box state to saved value from localStorage.
restore_options = ->
  email = localStorage[Settings.EMAIL]
  if email
    input = document.getElementById Settings.EMAIL
    input.setAttribute 'value', email

  debug = String(localStorage['debug']) is 'true'
  if debug
    input = document.getElementById Settings.DEBUG
    input.setAttribute 'checked', debug
  return

document.addEventListener 'DOMContentLoaded', () ->
  init()
  restore_options()
  document.querySelector('#save').addEventListener 'click', save_options
  return