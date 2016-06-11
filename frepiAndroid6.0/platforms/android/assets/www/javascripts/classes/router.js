(function() {
  window.RouteValidator = (function() {
    function RouteValidator() {}

    RouteValidator.checkUser = function() {
      if (!Config.getItem('userObject')) {
        return window.location.href = "../store/index.html";
      }
    };

    RouteValidator.checkCart = function() {
      var parsedSession, session;
      session = Config.getItem('currentSession');
      if (session) {
        parsedSession = JSON.parse(session);
        if (!(parsedSession.currentOrder.products.length > 0)) {
          return window.location.href = "store/index.html";
        }
      } else {
        return window.location.href = "store/index.html";
      }
    };

    return RouteValidator;

  })();

}).call(this);
