(function() {
  var LoginVM, login;

  LoginVM = (function() {
    function LoginVM() {
      this.setDOMElements();
    }

    LoginVM.prototype.login = function() {
      return LoginService.regularLogin((function(_this) {
        return function(error, success) {
          if (error) {
            return console.log('An error ocurred while trying to login');
          } else {
            if (success.data.administrator) {
              return window.location.href = 'admin/products.html';
            } else {
              return window.location.href = 'store/index.html';
            }
          }
        };
      })(this));
    };

    LoginVM.prototype.loginFB = function() {
      return LoginService.FBLogin((function(_this) {
        return function(error, success) {
          if (error) {
            return console.log('An error ocurred while trying to login to FB');
          } else {
            if (success.administrator) {
              return window.location.href = 'admin/products.html';
            } else {
              return window.location.href = 'store/index.html';
            }
          }
        };
      })(this));
    };

    LoginVM.prototype.resetPassword = function() {
      var $form, data;
      $form = $('.reset-password .form');
      if ($form.form('is valid')) {
        data = {
          email: $form.form('get value', 'email'),
          redirect_url: '/'
        };
        $('.reset-password .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/auth/password", data, (function(_this) {
          return function(error, success, headers) {
            $('.reset-password .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred while fetching the categories!');
              return console.log(error);
            } else {
              console.log(success);
              $('.reset-password .green.button').addClass('disabled');
              $('.reset-password .success.segment').transition('fade down');
              return setTimeout((function() {
                return $('.reset-password.modal').modal('hide');
              }), 5000);
            }
          };
        })(this));
      }
    };

    LoginVM.prototype.setDOMElements = function() {
      $('.reset-password .form').form({
        fields: {
          email: {
            identifier: 'email',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner el correo'
              }, {
                type: 'email',
                prompt: 'La dirección de correo no es válida'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
      $('.ui.login.form').form({
        fields: {
          username: {
            identifier: 'username',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner un usuario'
              }, {
                type: 'email',
                prompt: 'La dirección de correo no es válida'
              }
            ]
          },
          password: {
            identifier: 'password',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner una contraseña'
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
      return $('.reset-password.modal').modal({
        onHidden: function() {
          $('.reset-password .success.segment').attr('style', 'display: none !important');
          $('.reset-password .green.button').removeClass('disabled');
          return $('.reset-password form').form('clear');
        }
      }).modal('attach events', '.reset.trigger', 'show').modal('attach events', '.reset-password .cancel.button', 'hide');
    };

    return LoginVM;

  })();

  login = new LoginVM;

  ko.applyBindings(login);

}).call(this);
