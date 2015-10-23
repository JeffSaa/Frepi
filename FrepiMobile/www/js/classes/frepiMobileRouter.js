(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.FrepiRouter = (function(superClass) {
    extend(FrepiRouter, superClass);

    function FrepiRouter() {
      return FrepiRouter.__super__.constructor.apply(this, arguments);
    }

    FrepiRouter.prototype.routes = {
      '': 'loading',
      'login': 'login',
      'home': 'home',
      'nearby': 'nearby',
      'active': 'active'
    };

    FrepiRouter.prototype.active = function() {
      return MasterVM.target('active');
    };

    FrepiRouter.prototype.home = function() {
      return MasterVM.target('home');
    };

    FrepiRouter.prototype.loading = function() {
      return MasterVM.target('login');
    };

    FrepiRouter.prototype.login = function() {
      return MasterVM.target('login');
    };

    FrepiRouter.prototype.nearby = function() {
      return MasterVM.target('nearby');
    };

    return FrepiRouter;

  })(Backbone.Router);

}).call(this);
