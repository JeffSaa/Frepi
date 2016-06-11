(function() {
  window.LoginService = (function() {
    function LoginService() {}

    LoginService.initFB = function() {
      return openFB.init({
        appId: '433427986841087'
      });
    };

    LoginService.FBLogin = function(callback) {
      var FBcredentials, token;
      LoginService.initFB();
      FBcredentials = {};
      token = null;
      return openFB.login((function(response) {
        console.log(response);
        if (response.status === 'connected') {
          token = response.authResponse.accessToken;
          return openFB.api({
            path: '/me',
            success: (function(_this) {
              return function(responseAPI) {
                var idFB;
                idFB = void 0;
                idFB = responseAPI.id;
                return RESTfulService.makeRequest('POST', '/auth/facebook/callback', {
                  uid: idFB
                }, function(error, success, headers) {
                  if (error) {
                    console.log('First time this user is trying to log with FB');
                    console.log('Now the request with user info is going to be sent...');
                    openFB.api({
                      path: '/' + idFB,
                      params: {
                        'fields': 'email,first_name,last_name,picture.height(400).width(400)',
                        'access_token': token
                      },
                      success: function(responseAPI) {
                        console.log('Successful login for: ' + responseAPI.name);
                        console.log('Successful login for: ' + responseAPI.email);
                        FBcredentials = {
                          email: responseAPI.email,
                          name: responseAPI.first_name,
                          last_name: responseAPI.last_name,
                          image: responseAPI.picture.data.url,
                          uid: responseAPI.id
                        };
                        console.log(responseAPI);
                        return RESTfulService.makeRequest('POST', '/auth/facebook/callback', FBcredentials, (function(_this) {
                          return function(error, success, headers) {
                            if (error) {
                              console.log('The user couldnt be created');
                              return callback(error, null);
                            } else {
                              console.log(success);
                              Config.destroyLocalStorage();
                              Config.setItem('headers', JSON.stringify(headers));
                              return Config.setItem('userObject', JSON.stringify(success.user));
                            }
                          };
                        })(this));
                      }
                    });
                  } else {
                    console.log(success);
                    Config.destroyLocalStorage();
                    Config.setItem('headers', JSON.stringify(headers));
                    Config.setItem('userObject', JSON.stringify(success.user));
                    console.log('FB user is registered in our DB');
                  }
                  return callback(null, success);
                });
              };
            })(this)
          });
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
      console.log('normal log');
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
