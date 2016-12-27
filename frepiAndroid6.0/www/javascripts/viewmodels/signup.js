(function() {
  var SignUpVM, signUp;

  SignUpVM = (function() {
    function SignUpVM() {
      this.errorTextResponse = ko.observable();
      this.initFB();
      this.setDOMElements();
    }

    SignUpVM.prototype.initFB = function() {
      return FB.init({
        appId: 433427986841087,
        cookie: true,
        version: 'v2.4'
      });
    };

    SignUpVM.prototype.signUp = function() {
      var $form, data;
      $form = $('.ui.form');
      $form.removeClass('error');
      if ($form.form('is valid')) {
        data = {
          name: $form.form('get value', 'firstName'),
          address: $form.form('get value', 'address'),
          last_name: $form.form('get value', 'lastName'),
          email: $form.form('get value', 'email'),
          phone_number: $form.form('get value', 'phoneNumber'),
          password: $form.form('get value', 'password'),
          password_confirmation: $form.form('get value', 'password')
        };
        $('.ui.form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', '/users', data, (function(_this) {
          return function(error, success, headers) {
            var errors;
            if (error) {
              $('.ui.form .green.button').removeClass('loading');
              $form.addClass('error');
              console.log('An error has ocurred in the authentication.');
              errors = [];
              $.each(error.responseJSON, function(key, value) {
                return errors.push((key.charAt(0).toUpperCase() + key.slice(1)) + " " + value[0]);
              });
              return $form.form('add errors', errors);
            } else {
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              Config.setItem('userObject', JSON.stringify(success));
              return window.location.href = '../store/index.html';
            }
          };
        })(this));
      }
    };

    SignUpVM.prototype.signWithFB = function() {
      var FBcredentials;
      FBcredentials = {};
      return FB.login((function(response) {
        if (response.status === 'connected') {
          console.log('User logged into FrepiTest');
          console.log("FB user ID is " + response.authResponse.userID);
          return RESTfulService.makeRequest('POST', '/auth/facebook/callback', {
            uid: response.authResponse.userID
          }, (function(_this) {
            return function(error, success, headers) {
              if (error) {
                console.log('First time this user is trying to log with FB');
                console.log('Now the request with user info is going to be sent...');
                return FB.api('/me', {
                  fields: 'email, first_name, last_name, picture.height(400).width(400)'
                }, function(responseAPI) {
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
                        return console.log('The user couldnt be created');
                      } else {
                        console.log(success);
                        Config.setItem('headers', JSON.stringify(headers));
                        Config.setItem('userObject', JSON.stringify(success.user));
                        if (success.user.administrator) {
                          return window.location.href = '../admin/index.html';
                        } else {
                          return window.location.href = '../store/index.html';
                        }
                      }
                    };
                  })(this));
                });
              } else {
                console.log(success);
                Config.setItem('accessToken', headers.accessToken);
                Config.setItem('client', headers.client);
                Config.setItem('uid', headers.uid);
                Config.setItem('userObject', JSON.stringify(success.user));
                console.log('FB user is registered in our DB');
                if (success.user.administrator) {
                  return window.location.href = '../admin/index.html';
                } else {
                  return window.location.href = '../store/index.html';
                }
              }
            };
          })(this));
        } else if (response.status === 'not_authorized') {
          return console.log('Doesnt logged into FrepiTest!');
        } else {
          return console.log('Doesnt logged into Facebook!');
        }
      }), {
        scope: 'public_profile,email'
      });
    };

    SignUpVM.prototype.setDOMElements = function() {
      return $('.ui.form').form({
        fields: {
          firstName: {
            identifier: 'firstName',
            rules: [
              {
                type: 'empty',
                prompt: 'Por favor digite su nombre'
              }
            ]
          },
          lastName: {
            identifier: 'lastName',
            rules: [
              {
                type: 'empty',
                prompt: 'Por favor digite su apellido'
              }
            ]
          },
          address: {
            identifier: 'address',
            rules: [
              {
                type: 'empty',
                prompt: 'Por favor digite su dirección'
              }
            ]
          },
          phoneNumber: {
            identifier: 'phoneNumber',
            rules: [
              {
                type: 'empty',
                prompt: 'Por favor digite su teléfono'
              }
            ]
          },
          email: {
            identifier: 'email',
            rules: [
              {
                type: 'empty',
                prompt: 'Por favor digite un email'
              }, {
                type: 'email',
                prompt: 'Por favor digite un e-mail válido'
              }
            ]
          },
          password: {
            identifier: 'password',
            rules: [
              {
                type: 'empty',
                prompt: 'Por favor digite una contraseña'
              }, {
                type: 'length[6]',
                prompt: 'La contraseña debe tener por lo menos 6 caracteres'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
    };

    return SignUpVM;

  })();

  signUp = new SignUpVM;

  ko.applyBindings(signUp);

}).call(this);
