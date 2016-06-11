(function() {
  var DeparmentVM, store,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  DeparmentVM = (function(superClass) {
    extend(DeparmentVM, superClass);

    function DeparmentVM() {
      this.fetchProducts = bind(this.fetchProducts, this);
      this.fetchAllProducts = bind(this.fetchAllProducts, this);
      DeparmentVM.__super__.constructor.call(this);
      this.deparment = ko.mapping.fromJS(DefaultModels.DEPARMENT);
      this.subcategories = ko.observableArray();
      this.products = ko.observableArray();
      this.currentSubcatBtn = null;
      this.shouldDisplayNoResultAlert = ko.observable(false);
      this.shouldDisplayLoader = ko.observable(true);
      this.selectedProduct = null;
      this.selectedProductCategory = ko.observable();
      this.selectedProductImage = ko.observable();
      this.selectedProductName = ko.observable();
      this.selectedProductPrice = ko.observable();
      this.setExistingSession();
      this.setUserInfo();
      this.setDeparment();
      this.setSizeSidebar();
      this.setSizeButtons();
      this.setDOMElements();
    }

    DeparmentVM.prototype.setDeparment = function() {
      return RESTfulService.makeRequest('GET', "/categories/" + this.session.currentDeparmentID, '', (function(_this) {
        return function(error, success, headers) {
          if (error) {
            return console.log(error);
          } else {
            console.log(success);
            ko.mapping.fromJS(success, _this.deparment);
            return RESTfulService.makeRequest('GET', "/categories/" + _this.session.currentDeparmentID + "/subcategories", '', function(error, success, headers) {
              if (error) {
                return console.log(error);
              } else {
                console.log(success);
                _this.setDOMElems();
                _this.subcategories(success);
                if (_this.session.currentSubcategorID) {
                  return _this.fetchProducts({
                    id: _this.session.currentSubcategorID
                  });
                } else {
                  return _this.fetchAllProducts();
                }
              }
            });
          }
        };
      })(this));
    };

    DeparmentVM.prototype.fetchAllProducts = function() {
      this.products([]);
      this.shouldDisplayLoader(true);
      this.shouldDisplayNoResultAlert(false);
      $('h1 + .horizontal.list .button').addClass('basic');
      $('.list .item.all .button').removeClass('basic');
      return RESTfulService.makeRequest('GET', "/categories/" + this.session.currentDeparmentID + "/products", '', (function(_this) {
        return function(error, success, headers) {
          _this.shouldDisplayLoader(false);
          if (error) {
            return console.log(error);
          } else {
            if (success.length > 0) {
              _this.products(success);
              return _this.setCartItemsLabels();
            } else {
              return _this.shouldDisplayNoResultAlert(true);
            }
          }
        };
      })(this));
    };

    DeparmentVM.prototype.fetchProducts = function(subcategory) {
      this.products([]);
      this.shouldDisplayLoader(true);
      this.shouldDisplayNoResultAlert(false);
      $('h1 + .horizontal.list .button').addClass('basic');
      $("#subcat" + subcategory.id).removeClass('basic');
      return RESTfulService.makeRequest('GET', "/subcategories/" + subcategory.id + "/products", '', (function(_this) {
        return function(error, success, headers) {
          _this.shouldDisplayLoader(false);
          if (error) {
            return console.log(error);
          } else {
            if (success.length > 0) {
              _this.products(success);
              return _this.setCartItemsLabels();
            } else {
              return _this.shouldDisplayNoResultAlert(true);
            }
          }
        };
      })(this));
    };

    DeparmentVM.prototype.profile = function() {
      this.saveOrder();
      Config.setItem('showOrders', 'false');
      return window.location.href = '../store/profile.html';
    };

    DeparmentVM.prototype.orders = function() {
      this.saveOrder();
      Config.setItem('showOrders', 'true');
      return window.location.href = '../store/profile.html';
    };

    DeparmentVM.prototype.setDOMElements = function() {
      $('#departments-menu').sidebar({
        transition: 'overlay'
      }).sidebar('attach events', '#store-secondary-navbar button.basic', 'show');
      $('#mobile-menu').sidebar('setting', 'transition', 'overlay').sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show');
      return $('#modal-dropdown').dropdown();
    };

    DeparmentVM.prototype.setSizeButtons = function() {
      if ($(window).width() < 480) {
        $('.horizontal.list .button').addClass('mini');
      }
      return $(window).resize(function() {
        if ($(window).width() < 480) {
          return $('.horizontal.list .button').addClass('mini');
        } else {
          return $('.horizontal.list .button').removeClass('mini');
        }
      });
    };

    return DeparmentVM;

  })(TransactionalPageVM);

  store = new DeparmentVM;

  ko.applyBindings(store);

}).call(this);
