(function() {
  window.Config = (function() {
    function Config() {}

    Config.TAG = 'FrepiStorage';

    Config.setItem = function(key, value) {
      var configObject, decryptedConfigObject, encryptedJSON;
      configObject = window.localStorage.getItem(this.TAG);
      if (configObject === null) {
        configObject = new Object();
      } else {
        decryptedConfigObject = Encrypter.decrypt(configObject, 'frepiKey');
        configObject = JSON.parse(decryptedConfigObject);
      }
      configObject[key] = value;
      encryptedJSON = Encrypter.encrypt(JSON.stringify(configObject), 'frepiKey');
      window.localStorage.setItem(this.TAG, encryptedJSON);
    };

    Config.getItem = function(key) {
      var configObject, encryptedConfigObject;
      encryptedConfigObject = window.localStorage.getItem(this.TAG);
      if (encryptedConfigObject === null) {
        return null;
      } else {
        configObject = Encrypter.decrypt(encryptedConfigObject, 'frepiKey');
        return JSON.parse(configObject)[key];
      }
    };

    Config.removeItem = function(key) {
      var configObject, decryptedConfigObject, encryptedConfigObject;
      encryptedConfigObject = window.localStorage.getItem(this.TAG);
      if (encryptedConfigObject !== null) {
        decryptedConfigObject = Encrypter.decrypt(encryptedConfigObject, 'frepiKey');
        configObject = JSON.parse(decryptedConfigObject);
        delete configObject[key];
        return window.localStorage.setItem(this.TAG, JSON.stringify(configObject));
      }
    };

    Config.destroyLocalStorage = function() {
      return window.localStorage.removeItem(this.TAG);
    };

    return Config;

  })();

}).call(this);
