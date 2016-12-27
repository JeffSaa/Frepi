(function() {
  window.LoginService = (function() {
    function LoginService() {}

    LoginService.initFB = function() {
      return FB.init({
        appId: 433427986841087,
        cookie: true,
        version: 'v2.4'
      });
    };

    LoginService.FBLogin = function(callback) {
      var FBInfo;
      LoginService.initFB();
      FBInfo = {};
      return FB.login((function(response) {
        if (response.status === 'connected') {
          return RESTfulService.makeRequest('POST', '/auth/facebook/callback', {
            uid: response.authResponse.userID
          }, (function(_this) {
            return function(error, success, headers) {
              if (error) {
                FB.api('/me', {
                  fields: 'email, first_name, last_name, picture.height(400).width(400)'
                }, function(responseAPI) {
                  FBInfo = {
                    email: responseAPI.email,
                    name: responseAPI.first_name,
                    last_name: responseAPI.last_name,
                    image: responseAPI.picture.data.url,
                    uid: responseAPI.id
                  };
                  return RESTfulService.makeRequest('POST', '/auth/facebook/callback', FBInfo, (function(_this) {
                    return function(error, success, headers) {
                      if (error) {
                        console.log('The user couldnt be created');
                        return callback(error, null);
                      } else {
                        Config.destroyLocalStorage();
                        Config.setItem('headers', JSON.stringify(headers));
                        return Config.setItem('userObject', JSON.stringify(success.user));
                      }
                    };
                  })(this));
                });
              } else {
                Config.destroyLocalStorage();
                Config.setItem('headers', JSON.stringify(headers));
                Config.setItem('userObject', JSON.stringify(success.user));
              }
              return callback(null, success);
            };
          })(this));
        } else if (response.status === 'not_authorized') {
          console.log('Doesnt logged into FrepiTest!');
          return callback(response.status, null);
        } else {
          console.log('Doesnt logged into Facebook!');
          return callback(response.status, null);
        }
      }), {
        scope: 'public_profile,email'
      });
    };

    LoginService.regularLogin = function(callback) {
      var $form, data;
      $form = $('.ui.login.form');
      $form.removeClass('error');
      if ($form.form('is valid')) {
        data = {
          email: $form.form('get value', 'username'),
          password: $form.form('get value', 'password')
        };
        $('.login.button').addClass('loading');
        return RESTfulService.makeRequest('POST', '/auth/sign_in', data, function(error, success, headers) {
          if (error) {
            $('.login.button').removeClass('loading');
            $form.addClass('error');
            console.log('An error has ocurred in the authentication.');
            if (error.responseJSON) {
              $form.form('add errors', error.responseJSON.errors);
            } else {
              $form.form('add errors', ['No se pudo establecer conexión']);
            }
            return callback(error, null);
          } else {
            Config.setItem('headers', JSON.stringify(headers));
            Config.setItem('userObject', JSON.stringify(success.data));
            return callback(null, success);
          }
        });
      }
    };

    return LoginService;

  })();

}).call(this);
