(function() {
  var StoreVM, store,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  StoreVM = (function(superClass) {
    extend(StoreVM, superClass);

    function StoreVM() {
      StoreVM.__super__.constructor.call(this);
      this.shouldShowError = ko.observable(false);
      this.shouldDisplayLoader = ko.observable(true);
      this.setExistingSession();
      this.setUserInfo();
      this.fetchCategories();
      this.setDOMElements();
      this.setSizeSidebar();
      console.log('Is signed Up? ' + this.session.signedUp());
    }

    StoreVM.prototype.fetchCategories = function() {
      return RESTfulService.makeRequest('GET', "/stores/" + (this.session.currentStore.id()) + "/categories", '', (function(_this) {
        return function(error, success, headers) {
          _this.shouldDisplayLoader(false);
          if (error) {
            _this.shouldShowError(true);
            return console.log(error);
          } else {
            console.log(success);
            _this.session.categories(success);
            _this.setDOMElems();
            return _this.setCartItemsLabels();
          }
        };
      })(this));
    };

    StoreVM.prototype.profile = function() {
      this.saveOrder();
      Config.setItem('showOrders', 'false');
      return window.location.href = '../store/profile.html';
    };

    StoreVM.prototype.orders = function() {
      this.saveOrder();
      Config.setItem('showOrders', 'true');
      return window.location.href = '../store/profile.html';
    };

    StoreVM.prototype.setDOMElements = function() {
      $('#departments-menu').sidebar({
        transition: 'overlay'
      }).sidebar('attach events', '#store-secondary-navbar button.basic', 'show');
      $('#mobile-menu').sidebar('setting', 'transition', 'overlay').sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show');
      return $('#modal-dropdown').dropdown();
    };

    StoreVM.prototype.setSizeSidebar = function() {
      if ($(window).width() < 480) {
        $('#shopping-cart').removeClass('wide');
      } else {
        $('#shopping-cart').addClass('wide');
      }
      return $(window).resize(function() {
        if ($(window).width() < 480) {
          return $('#shopping-cart').removeClass('wide');
        } else {
          return $('#shopping-cart').addClass('wide');
        }
      });
    };

    return StoreVM;

  })(TransactionalPageVM);

  store = new StoreVM;

  ko.applyBindings(store);

}).call(this);
