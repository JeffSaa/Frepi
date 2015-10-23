(function() {
  window.LoginVM = (function() {
    function LoginVM() {
      this.email = ko.observable();
      this.password = ko.observable();
      this.errorTextResponse = ko.observable();
      this.shouldShowError = ko.observable(false);
    }

    LoginVM.prototype.login = function() {
      var data;
      this.shouldShowError(false);
      if (!!this.email() && !!this.password()) {
        data = {
          email: 'shopper@frepi.com',
          password: 'frepi123'
        };
        $('.loader .preloader-wrapper').addClass('active');
        $('form .btn').addClass('disabled');
        return RESTfulService.makeRequest('POST', '/auth_shopper/sign_in', data, (function(_this) {
          return function(error, success, headers) {
            $('.loader .preloader-wrapper').removeClass('active');
            $('form .btn').removeClass('disabled');
            if (error) {
              console.log('An error has ocurred in the authentication.');
              console.log(error.responseJSON);
              _this.shouldShowError(true);
              if (error.responseJSON) {
                return _this.errorTextResponse(error.responseJSON.errors.toString());
              } else {
                return _this.errorTextResponse('No se pudo establecer conexión!');
              }
            } else {
              console.log(success);
              window.currentSession = {
                user: success.data
              };
              Config.setItem('headers', JSON.stringify(headers));
              return window.location.hash = 'home';
            }
          };
        })(this));
      } else {
        console.log('INCOMPLETE FIELDS');
        this.errorTextResponse('INCOMPLETE FIELDS');
        return this.shouldShowError(true);
      }
    };

    return LoginVM;

  })();

}).call(this);
