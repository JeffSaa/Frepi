(function() {
  window.Encrypter = (function() {
    function Encrypter() {}

    Encrypter.encrypt = function(data, key) {
      var encrypted;
      encrypted = CryptoJS.AES.encrypt(data, key);
      return encrypted.toString();
    };

    Encrypter.decrypt = function(encryptedData, key) {
      var decrypted;
      decrypted = CryptoJS.AES.decrypt(encryptedData, key);
      return decrypted.toString(CryptoJS.enc.Utf8);
    };

    return Encrypter;

  })();

}).call(this);
