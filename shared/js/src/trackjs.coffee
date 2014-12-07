window._trackJs =
  token: "448654d46817437d9ba3df61b95c8196"
  enabled: true
  application: 'chrome'
  callback:
    enabled: false
  console:
    enabled: false
  network:
    enabled: false
  visitor:
    enabled: false
  window:
    enabled: false
  serialize: (what) ->
    ret = what
    if typeof what is 'object'
      try
        ret = JSON.stringify what
      catch e
        ret = what.toString?() ? what
    ret
