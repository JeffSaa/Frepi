(function() {
  window.RouteValidator = (function() {
    function RouteValidator() {}

    RouteValidator.checkUser = function() {
      if (!Config.getItem('userObject')) {
        return window.location.href = "../store/";
      }
    };

    RouteValidator.checkCart = function() {
      var parsedSession, session;
      session = Config.getItem('currentSession');
      if (session) {
        parsedSession = JSON.parse(session);
        if (!parsedSession.currentOrder.products.length > 0 || parsedSession.currentOrder.price < 34000) {
          return window.location.href = "store/";
        }
      } else {
        return window.location.href = "store/";
      }
    };

    return RouteValidator;

  })();

}).call(this);
