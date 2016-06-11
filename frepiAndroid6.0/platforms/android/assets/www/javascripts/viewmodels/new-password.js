(function() {
  var ChangePasswordVM, changePassword;

  ChangePasswordVM = (function() {
    function ChangePasswordVM() {
      this.setDOMElements();
    }

    ChangePasswordVM.prototype.changePassword = function() {
      var $form, data, resetToken, url;
      $form = $('.ui.form');
      url = window.location.href;
      resetToken = url.split('reset_password_token=')[1];
      if ($form.form('is valid') && resetToken) {
        data = {
          reset_password_token: resetToken,
          password: $form.form('get value', 'new-password'),
          password_confirmation: $form.form('get value', 'confirmation-new-password')
        };
        $('.change.green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/passwords", data, (function(_this) {
          return function(error, success, headers) {
            $('.change.green.button').removeClass('loading');
            if (error) {
              $form.addClass('error');
              $('.ui.error.hidden.message').removeClass('hidden');
              if (error.responseJSON) {
                return $form.form('add errors', ['La solicitud no es válida']);
              } else {
                return $form.form('add errors', ['No se pudo establecer conexión']);
              }
            } else {
              console.log(success);
              return $('.success.segment').transition('fade down');
            }
          };
        })(this));
      }
    };

    ChangePasswordVM.prototype.setDOMElements = function() {
      return $('.ui.form').form({
        fields: {
          newPassword: {
            identifier: 'new-password',
            rules: [
              {
                type: 'empty',
                prompt: 'No puede estar vacía'
              }, {
                type: 'length[6]',
                prompt: 'La contraseña debe tener por lo menos 6 caracteres'
              }
            ]
          },
          match: {
            identifier: 'confirmation-new-password',
            rules: [
              {
                type: 'match[new-password]',
                prompt: 'Las contraseñas no coinciden'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
    };

    return ChangePasswordVM;

  })();

  changePassword = new ChangePasswordVM;

  ko.applyBindings(changePassword);

}).call(this);
