(function() {
  var PerformanceVM, performance,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  PerformanceVM = (function(superClass) {
    extend(PerformanceVM, superClass);

    function PerformanceVM() {
      this.fetchShoppersPage = bind(this.fetchShoppersPage, this);
      this.fetchProductsPage = bind(this.fetchProductsPage, this);
      this.fetchEarningsPage = bind(this.fetchEarningsPage, this);
      PerformanceVM.__super__.constructor.call(this);
      this.productsAlertText = ko.observable('Seleccione un rango de búsqueda');
      this.shoppersAlertText = ko.observable('Seleccione un rango de búsqueda');
      this.sucursalsAlertText = ko.observable('Seleccione un rango de búsqueda');
      this.shouldShowShoppersAlert = ko.observable(true);
      this.shouldShowProductsAlert = ko.observable(true);
      this.shouldShowSucursalsAlert = ko.observable(true);
      this.currentProducts = ko.observableArray();
      this.currentShoppers = ko.observableArray();
      this.currentSucursals = ko.observableArray();
      this.shoppersPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.productsPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.sucursalsPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.setDOMProperties();
    }

    PerformanceVM.prototype.setPrevSucursalPage = function() {
      var nextPage;
      if (this.sucursalsPages.activePage === 1) {
        nextPage = this.sucursalsPages.allPages.length - 1;
      } else {
        nextPage = this.sucursalsPages.activePage - 1;
      }
      return this.fetchEarningsPage(this.sucursalsPages.allPages[nextPage - 1]);
    };

    PerformanceVM.prototype.setNextSucursalPage = function() {
      var nextPage;
      if (this.sucursalsPages.activePage === this.sucursalsPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.sucursalsPages.activePage + 1;
      }
      return this.fetchEarningsPage(this.sucursalsPages.allPages[nextPage - 1]);
    };

    PerformanceVM.prototype.fetchEarningsPage = function(page) {
      this.sucursalsPages.activePage = page.num;
      this.setPaginationItemsToShow(this.sucursalsPages, 'article.sucursals');
      return this.fetchEarningsStatistics(page.startDate, page.endDate, page.num);
    };

    PerformanceVM.prototype.fetchEarningsStatistics = function(startDate, endDate, numPage) {
      var data;
      this.isLoading(true);
      data = {
        start_date: startDate,
        end_date: endDate,
        page: numPage
      };
      return RESTfulService.makeRequest('GET', '/administrator/statistics/earnings', data, (function(_this) {
        return function(error, success, headers) {
          var i, j, obj, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching earnings statistics');
            return _this.productsAlertText('Ha ocurrido un error buscando la información');
          } else {
            console.log('Earnings statistics fetching done');
            console.log(success);
            if (success.length > 0) {
              _this.shouldShowSucursalsAlert(false);
              _this.currentSucursals(success);
              if (_this.sucursalsPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 10);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  obj = {
                    num: i + 1,
                    endDate: endDate,
                    startDate: startDate
                  };
                  _this.sucursalsPages.allPages.push(obj);
                }
                _this.sucursalsPages.activePage = 1;
                _this.sucursalsPages.lowerLimit = 0;
                _this.sucursalsPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.sucursalsPages.showablePages(_this.sucursalsPages.allPages.slice(_this.sucursalsPages.lowerLimit, _this.sucursalsPages.upperLimit));
                $("article.sucursals .pagination .pages .item:first-of-type").addClass('active');
              }
            } else {
              _this.shouldShowSucursalsAlert(true);
              _this.sucursalsAlertText('No hubo ventas en el rango escogido');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    PerformanceVM.prototype.setPrevProductPage = function() {
      var nextPage;
      if (this.productsPages.activePage === 1) {
        nextPage = this.productsPages.allPages.length - 1;
      } else {
        nextPage = this.productsPages.activePage - 1;
      }
      return this.fetchProductsPage(this.productsPages.allPages[nextPage - 1]);
    };

    PerformanceVM.prototype.setNextProductPage = function() {
      var nextPage;
      if (this.productsPages.activePage === this.productsPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.productsPages.activePage + 1;
      }
      return this.fetchProductsPage(this.productsPages.allPages[nextPage - 1]);
    };

    PerformanceVM.prototype.fetchProductsPage = function(page) {
      this.productsPages.activePage = page.num;
      this.setPaginationItemsToShow(this.productsPages, 'article.products');
      return this.fetchProductsStatistics(page.startDate, page.endDate, page.num);
    };

    PerformanceVM.prototype.fetchProductsStatistics = function(startDate, endDate, numPage) {
      var data;
      this.isLoading(true);
      data = {
        start_date: startDate,
        end_date: endDate,
        page: numPage
      };
      return RESTfulService.makeRequest('GET', '/administrator/statistics/products', data, (function(_this) {
        return function(error, success, headers) {
          var i, j, obj, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching products statistics');
            return _this.productsAlertText('Ha ocurrido un error buscando la información');
          } else {
            console.log('Products statistics fetching done');
            console.log(success);
            if (success.length > 0) {
              _this.currentProducts(success);
              _this.shouldShowProductsAlert(false);
              if (_this.productsPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 10);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  obj = {
                    num: i + 1,
                    endDate: endDate,
                    startDate: startDate
                  };
                  _this.productsPages.allPages.push(obj);
                }
                _this.productsPages.activePage = 1;
                _this.productsPages.lowerLimit = 0;
                _this.productsPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.productsPages.showablePages(_this.productsPages.allPages.slice(_this.productsPages.lowerLimit, _this.productsPages.upperLimit));
                $("article.products .pagination .pages .item:first-of-type").addClass('active');
              }
            } else {
              _this.shouldShowProductsAlert(true);
              _this.productsAlertText('No hubo ventas en el rango escogido');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    PerformanceVM.prototype.setPrevShopperPage = function() {
      var nextPage;
      if (this.shoppersPages.activePage === 1) {
        nextPage = this.shoppersPages.allPages.length - 1;
      } else {
        nextPage = this.shoppersPages.activePage - 1;
      }
      return this.fetchShoppersPage(this.shoppersPages.allPages[nextPage - 1]);
    };

    PerformanceVM.prototype.setNextShopperPage = function() {
      var nextPage;
      if (this.shoppersPages.activePage === this.shoppersPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.shoppersPages.activePage + 1;
      }
      return this.fetchShoppersPage(this.shoppersPages.allPages[nextPage - 1]);
    };

    PerformanceVM.prototype.fetchShoppersPage = function(page) {
      this.shoppersPages.activePage = page.num;
      this.setPaginationItemsToShow(this.shoppersPages, 'article.shoppers');
      return this.fetchShoppersStatistics(page.startDate, page.endDate, page.num);
    };

    PerformanceVM.prototype.fetchShoppersStatistics = function(startDate, endDate, numPage) {
      var data;
      this.isLoading(true);
      data = {
        start_date: startDate,
        end_date: endDate,
        page: numPage
      };
      return RESTfulService.makeRequest('GET', '/administrator/statistics/shoppers', data, (function(_this) {
        return function(error, success, headers) {
          var i, j, obj, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching shoppers statistics');
            return _this.productsAlertText('Ha ocurrido un error buscando la información');
          } else {
            console.log('Shoppers statistics fetching done');
            console.log(success);
            if (success.length > 0) {
              _this.currentShoppers(success);
              _this.shouldShowShoppersAlert(false);
              if (_this.shoppersPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 10);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  obj = {
                    num: i + 1,
                    endDate: endDate,
                    startDate: startDate
                  };
                  _this.shoppersPages.allPages.push(obj);
                }
                _this.shoppersPages.activePage = 1;
                _this.shoppersPages.lowerLimit = 0;
                _this.shoppersPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.shoppersPages.showablePages(_this.shoppersPages.allPages.slice(_this.shoppersPages.lowerLimit, _this.shoppersPages.upperLimit));
                $("article.shoppers .pagination .pages .item:first-of-type").addClass('active');
              }
            } else {
              _this.shouldShowShoppersAlert(true);
              _this.shoppersAlertText('No hubo ventas en el rango escogido');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    PerformanceVM.prototype.getProfit = function(frepiPrice, storePrice) {
      var profit;
      profit = frepiPrice - storePrice;
      return Math.round(profit * 100) / 100;
    };

    PerformanceVM.prototype.setDOMProperties = function() {
      this.isLoading(false);
      $('#products-daterange').daterangepicker({
        applyClass: 'positive',
        cancelClass: 'cancel'
      }).on('cancel.daterangepicker', function(ev, picker) {
        return $('#products-daterange').val = '';
      }).on('apply.daterangepicker', (function(_this) {
        return function(ev, picker) {
          return _this.fetchProductsStatistics(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'), 1);
        };
      })(this));
      $('#shoppers-daterange').daterangepicker({
        applyClass: 'positive',
        cancelClass: 'cancel'
      }).on('cancel.daterangepicker', function(ev, picker) {
        return $('#shoppers-daterange').val = '';
      }).on('apply.daterangepicker', (function(_this) {
        return function(ev, picker) {
          return _this.fetchShoppersStatistics(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'), 1);
        };
      })(this));
      return $('#sucursals-daterange').daterangepicker({
        applyClass: 'positive',
        cancelClass: 'cancel'
      }).on('cancel.daterangepicker', function(ev, picker) {
        return $('#sucursals-daterange').val = '';
      }).on('apply.daterangepicker', (function(_this) {
        return function(ev, picker) {
          return _this.fetchEarningsStatistics(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'), 1);
        };
      })(this));
    };

    return PerformanceVM;

  })(AdminPageVM);

  performance = new PerformanceVM;

  ko.applyBindings(performance);

}).call(this);
