
save_options = ->
  status = (message) ->
    # Update status to let user know options were saved.
    s = document.getElementById "status"
    s.innerHTML = message
    setTimeout (->
      s.innerHTML = ""
    ), 750
    return

  input = document.getElementById "email"
  email = input.value
  localStorage["email"] = email ? null
  status "Options Saved."

  return

# Restores select box state to saved value from localStorage.
restore_options = ->
  email = localStorage["email"]
  return unless email
  input = document.getElementById "email"
  input.setAttribute 'value', email
  return

document.addEventListener "DOMContentLoaded", () ->
  restore_options()
  document.querySelector("#save").addEventListener "click", save_options
  return