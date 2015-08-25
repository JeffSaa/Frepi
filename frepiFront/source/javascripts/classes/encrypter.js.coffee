class window.Encryptor
  @JsonFormatter = 
    stringify: (cipherParams) ->
      # create json object with ciphertext
      jsonObj = ct: cipherParams.ciphertext.toString(CryptoJS.enc.Base64)
      # optionally add iv and salt
      if cipherParams.iv
        jsonObj.iv = cipherParams.iv.toString()
      if cipherParams.salt
        jsonObj.s = cipherParams.salt.toString()
      # stringify json object
      JSON.stringify jsonObj
    parse: (jsonStr) ->
      # parse json string
      jsonObj = JSON.parse(jsonStr)
      # extract ciphertext from json object, and create cipher params object
      cipherParams = CryptoJS.lib.CipherParams.create(ciphertext: CryptoJS.enc.Base64.parse(jsonObj.ct))
      # optionally extract iv and salt
      if jsonObj.iv
        cipherParams.iv = CryptoJS.enc.Hex.parse(jsonObj.iv)
      if jsonObj.s
        cipherParams.salt = CryptoJS.enc.Hex.parse(jsonObj.s)
      cipherParams

  @encrypt: (data, key) ->
    encrypted = CryptoJS.AES.encrypt(data, key, { format: @JsonFormatter })
    encrypted.toString()

  @decrypt: (encryptedData, key) ->
    decrypted = CryptoJS.AES.decrypt(encryptedData, key, { format: @JsonFormatter })
    decrypted.toString(CryptoJS.enc.Utf8)