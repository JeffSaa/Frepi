class window.Config
  @TAG = 'FrepiStorage'
  
  @setItem : (key, value) ->
    configObject = window.localStorage.getItem(@TAG)
    if configObject is null
      configObject = new Object()
    else
      decryptedConfigObject = Encrypter.decrypt(configObject, 'frepiKey')
      configObject = JSON.parse(decryptedConfigObject)

    configObject[key] = value
    encryptedJSON = Encrypter.encrypt(JSON.stringify(configObject), 'frepiKey')
    window.localStorage.setItem(@TAG, encryptedJSON)
    return

  @getItem : (key) ->
    encryptedConfigObject = window.localStorage.getItem(@TAG)
    if encryptedConfigObject is null
      return null
    else
      configObject = Encrypter.decrypt(encryptedConfigObject, 'frepiKey')
      return JSON.parse(configObject)[key]

  @removeItem : (key) ->
    encryptedConfigObject = window.localStorage.getItem(@TAG)    
    if encryptedConfigObject isnt null
      decryptedConfigObject = Encrypter.decrypt(encryptedConfigObject, 'frepiKey')
      configObject = JSON.parse(decryptedConfigObject)
      delete configObject[key]
      window.localStorage.setItem(@TAG, JSON.stringify(configObject))

  @destroyLocalStorage : ->
    window.localStorage.removeItem(@TAG)