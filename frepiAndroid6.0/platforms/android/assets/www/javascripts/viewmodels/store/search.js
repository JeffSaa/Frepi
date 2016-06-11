(function() {
  var SearchVM, searchVM,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  SearchVM = (function(superClass) {
    extend(SearchVM, superClass);

    function SearchVM() {
      this.fetchProducts = bind(this.fetchProducts, this);
      SearchVM.__super__.constructor.call(this);
      this.deparment = ko.mapping.fromJS(DefaultModels.DEPARMENT);
      this.subcategories = ko.observableArray();
      this.products = ko.observableArray();
      this.valueSearchingFor = ko.observable();
      this.selectedProduct = null;
      this.selectedProductCategory = ko.observable();
      this.selectedProductImage = ko.observable();
      this.selectedProductName = ko.observable();
      this.selectedProductPrice = ko.observable();
      this.setExistingSession();
      this.setUserInfo();
      this.fetchProducts();
      this.setDOMElements();
      this.setSizeSidebar();
    }

    SearchVM.prototype.fetchProducts = function() {
      var data;
      data = {
        search: this.session.stringToSearch
      };
      return RESTfulService.makeRequest('GET', "/search/products", data, (function(_this) {
        return function(error, success, headers) {
          if (error) {
            return console.log(error);
          } else {
            console.log(success);
            _this.products(success);
            return _this.setCartItemsLabels();
          }
        };
      })(this));
    };

    SearchVM.prototype.profile = function() {
      this.saveOrder();
      Config.setItem('showOrders', 'false');
      return window.location.href = '../store/profile.html';
    };

    SearchVM.prototype.orders = function() {
      this.saveOrder();
      Config.setItem('showOrders', 'true');
      return window.location.href = '../store/profile.html';
    };

    SearchVM.prototype.setDOMElements = function() {
      $('#departments-menu').sidebar({
        transition: 'overlay'
      }).sidebar('attach events', '#store-secondary-navbar button.basic', 'show');
      $('#mobile-menu').sidebar('setting', 'transition', 'overlay').sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show');
      return $('#modal-dropdown').dropdown();
    };

    SearchVM.prototype.setSizeSidebar = function() {
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

    return SearchVM;

  })(TransactionalPageVM);

  searchVM = new SearchVM;

  ko.applyBindings(searchVM);

}).call(this);
