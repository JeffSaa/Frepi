class window.Encrypter
  @encrypt: (data, key) ->
    encrypted = CryptoJS.AES.encrypt(data, key)
    encrypted.toString()

  @decrypt: (encryptedData, key) ->
    decrypted = CryptoJS.AES.decrypt(encryptedData, key)
    decrypted.toString(CryptoJS.enc.Utf8)