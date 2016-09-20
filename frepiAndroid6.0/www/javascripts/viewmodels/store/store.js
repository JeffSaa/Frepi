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
      this.showDepartmentButton = ko.observable($(window).width() < 991);
      this.setExistingSession();
      this.session.categories([]);
      this.setUserInfo();
      this.fetchCategories();
      this.setDOMElements();
      this.setSizeSidebar();
    }

    StoreVM.prototype.fetchCategories = function() {
      return RESTfulService.makeRequest('GET', "/stores/" + (this.session.currentStore.id()) + "/categories", '', (function(_this) {
        return function(error, success, headers) {
          _this.shouldDisplayLoader(false);
          $('section.products').css('display', 'block');
          if (error) {
            $('#error-container').css('display', 'block');
            return console.log(error);
          } else {
            _this.session.categories(success);
            _this.setDOMElems();
            _this.setCartItemsLabels();
            return $('.ui.blank.card').css('height', $('#products-x-categories .column').first().height());
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
        transition: 'overlay',
        mobileTransition: 'overlay'
      }).sidebar('attach events', '#store-secondary-navbar button.basic', 'show');
      $('#mobile-menu').sidebar('setting', 'transition', 'overlay').sidebar('setting', 'mobileTransition', 'overlay').sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show');
      return $('#modal-dropdown').dropdown();
    };

    StoreVM.prototype.setSizeSidebar = function() {
      if ($(window).width() < 480) {
        $('#shopping-cart').removeClass('wide');
      } else {
        $('#shopping-cart').addClass('wide');
      }
      return $(window).resize((function(_this) {
        return function() {
          _this.showDepartmentButton($(window).width() < 976);
          $('.ui.blank.card').css('height', $('#products-x-categories .column').first().height());
          if ($(window).width() < 480) {
            return $('#shopping-cart').removeClass('wide');
          } else {
            return $('#shopping-cart').addClass('wide');
          }
        };
      })(this));
    };

    return StoreVM;

  })(TransactionalPageVM);

  store = new StoreVM;

  ko.applyBindings(store);

}).call(this);
