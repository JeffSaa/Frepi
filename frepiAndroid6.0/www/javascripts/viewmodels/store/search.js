(function() {
  var SearchVM, searchVM,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  SearchVM = (function(superClass) {
    extend(SearchVM, superClass);

    function SearchVM() {
      this.fetchNextPage = bind(this.fetchNextPage, this);
      this.fetchProducts = bind(this.fetchProducts, this);
      SearchVM.__super__.constructor.call(this);
      this.deparment = ko.mapping.fromJS(DefaultModels.DEPARMENT);
      this.subcategories = ko.observableArray();
      this.products = ko.observableArray([]);
      this.valueSearchingFor = ko.observable();
      this.totalResultsNumber = ko.observable(0);
      this.selectedProduct = null;
      this.selectedProductCategory = ko.observable();
      this.selectedProductImage = ko.observable();
      this.selectedProductName = ko.observable();
      this.selectedProductPrice = ko.observable();
      this.shouldShowLoadMore = ko.observable(false);
      this.pages = {
        currentPage: 1,
        totalNumber: 0
      };
      this.setExistingSession();
      this.setUserInfo();
      this.fetchProducts();
      this.setDOMElements();
      this.setSizeSidebar();
    }

    SearchVM.prototype.fetchProducts = function() {
      var data;
      if (this.session.stringToSearch) {
        data = {
          search: this.session.stringToSearch
        };
        return RESTfulService.makeRequest('GET', "/search/products", data, (function(_this) {
          return function(error, success, headers) {
            if (error) {
              return console.log(error);
            } else {
              $('.search section.products').css('display', 'block');
              if (success.length > 0) {
                _this.pages.totalNumber = Math.ceil(headers.totalItems / 10);
                _this.totalResultsNumber(headers.totalItems);
                _this.products(success);
                _this.setCartItemsLabels();
                if (_this.pages.totalNumber > 1) {
                  return _this.shouldShowLoadMore(true);
                }
              } else {
                return $('.search .no-results-message').css('display', 'block');
              }
            }
          };
        })(this));
      }
    };

    SearchVM.prototype.fetchNextPage = function() {
      var $loadMoreButton, data;
      $loadMoreButton = $('.load-more.button');
      data = {
        search: this.session.stringToSearch,
        page: this.pages.currentPage + 1
      };
      $loadMoreButton.addClass('loading');
      return RESTfulService.makeRequest('GET', "/search/products", data, (function(_this) {
        return function(error, success, headers) {
          $loadMoreButton.removeClass('loading');
          if (error) {
            return console.log(error);
          } else {
            _this.pages.currentPage += 1;
            _this.products.push.apply(_this.products, success);
            _this.setCartItemsLabels();
            if (_this.pages.totalNumber <= _this.pages.currentPage) {
              return _this.shouldShowLoadMore(false);
            }
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
        transition: 'overlay',
        mobileTransition: 'overlay'
      }).sidebar('attach events', '#store-secondary-navbar button.basic', 'show');
      $('#mobile-menu').sidebar('setting', 'transition', 'overlay').sidebar('setting', 'mobileTransition', 'overlay').sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show');
      $('#modal-dropdown').dropdown();
      return setTimeout((function() {
        return $('#departments-menu .ui.dropdown').dropdown({
          on: 'hover'
        });
      }), 100);
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
