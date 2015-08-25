class window.Config
  @TAG = 'FrepiStorage'
  
  @setItem : (key, value) ->
    configObject = window.localStorage.getItem(@TAG)
    if configObject is null
      configObject = new Object()
    else
      configObject = JSON.parse(configObject)

    configObject[key] = value
    window.localStorage.setItem(@TAG, JSON.stringify(configObject))
    return

  @getItem : (key) ->
    configObject = window.localStorage.getItem(@TAG)
    if configObject is null
      return null
    else
      return JSON.parse(configObject)[key]

  @removeItem : (key) ->
    configObject = window.localStorage.getItem(@TAG)
    if configObject isnt null
      configObject = JSON.parse(configObject)
      delete configObject[key]
      window.localStorage.setItem(@TAG, JSON.stringify(configObject))