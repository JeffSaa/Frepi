(function() {
  var LoadingVM, loading;

  LoadingVM = (function() {
    function LoadingVM() {
      this.shouldShowError = ko.observable(false);
      setTimeout(((function(_this) {
        return function() {
          return _this.checkSession();
        };
      })(this)), 1000);
    }

    LoadingVM.prototype.checkSession = function() {
      var data;
      if (Config.getItem('uid')) {
        if (Config.getItem('pass')) {
          data = {
            email: Config.getItem('user'),
            password: Config.getItem('pass')
          };
          return RESTfulService.makeRequest('POST', '/auth/sign_in', data, (function(_this) {
            return function(error, success, headers) {
              if (error) {
                return _this.shouldShowError = ko.observable(true);
              } else {
                Config.setItem('accessToken', headers.accessToken);
                Config.setItem('client', headers.client);
                if (success.data.user_type === 'user') {
                  return window.location.href = '../store.html';
                } else {
                  return window.location.href = '../admin.html';
                }
              }
            };
          })(this));
        } else {
          data = {
            uid: Config.getItem('uid')
          };
          alert('Authenticating with FB user saved in localStorage.');
          return RESTfulService.makeRequest('POST', '/auth/facebook/callback', data, (function(_this) {
            return function(error, success, headers) {
              if (error) {
                return _this.shouldShowError = ko.observable(true);
              } else {
                Config.setItem('accessToken', headers.accessToken);
                Config.setItem('client', headers.client);
                if (success.user.userType === 'user') {
                  return window.location.href = '../store.html';
                } else {
                  return window.location.href = '../admin.html';
                }
              }
            };
          })(this));
        }
      } else {
        return window.location.href = '../login.html';
      }
    };

    return LoadingVM;

  })();

  loading = new LoadingVM;

  ko.applyBindings(loading);

}).call(this);
