(function() {
  var ShoppersVM, shoppers,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ShoppersVM = (function(superClass) {
    extend(ShoppersVM, superClass);

    function ShoppersVM() {
      this.fetchShoppersPage = bind(this.fetchShoppersPage, this);
      this.showDelete = bind(this.showDelete, this);
      this.showUpdate = bind(this.showUpdate, this);
      this.deleteShopper = bind(this.deleteShopper, this);
      ShoppersVM.__super__.constructor.call(this);
      this.shouldShowShoppersAlert = ko.observable(true);
      this.shoppersAlertText = ko.observable();
      this.currentShoppers = ko.observableArray();
      this.chosenShopper = {
        id: ko.observable(),
        name: ko.observable()
      };
      this.shoppersPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.fetchShoppers();
      this.setRulesValidation();
      this.setDOMProperties();
    }

    ShoppersVM.prototype.createShopper = function() {
      var $form, data;
      $form = $('.create.modal form');
      data = {
        email: $form.form('get value', 'email'),
        identification: $form.form('get value', 'cc'),
        lastName: $form.form('get value', 'lastName'),
        firstName: $form.form('get value', 'firstName'),
        phoneNumber: $form.form('get value', 'phoneNumber'),
        shopperType: $form.form('get value', 'shopperType')
      };
      if ($form.form('is valid')) {
        $('.create.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/shoppers", data, (function(_this) {
          return function(error, success, headers) {
            $('.create.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the shopper.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              _this.currentShoppers.push(success);
              return $('.create.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    ShoppersVM.prototype.updateShopper = function() {
      var $form, data;
      $form = $('.update.modal form');
      data = {
        email: $form.form('get value', 'email'),
        identification: $form.form('get value', 'cc'),
        lastName: $form.form('get value', 'lastName'),
        firstName: $form.form('get value', 'firstName'),
        phoneNumber: $form.form('get value', 'phoneNumber'),
        shopperType: $form.form('get value', 'shopperType')
      };
      if ($form.form('is valid')) {
        $('.update.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('PUT', "/shoppers/" + (this.chosenShopper.id()), data, (function(_this) {
          return function(error, success, headers) {
            $('.update.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the admin.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              $('.update.modal').modal('hide');
              return _this.fetchShoppers();
            }
          };
        })(this));
      }
    };

    ShoppersVM.prototype.deleteShopper = function() {
      $('.delete.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/shoppers/" + (this.chosenShopper.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            console.log(success);
            _this.currentShoppers.remove(function(shopper) {
              return shopper.id === _this.chosenShopper.id();
            });
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.modal').modal('hide');
          }
        };
      })(this));
    };

    ShoppersVM.prototype.showUpdate = function(shopper) {
      this.chosenShopper.id(shopper.id);
      $('.update.modal form').form('set values', {
        email: shopper.email,
        cc: shopper.identification,
        lastName: shopper.lastName,
        firstName: shopper.firstName,
        phoneNumber: shopper.phoneNumber,
        shopperType: shopper.shopperType
      });
      return $('.update.modal').modal('show');
    };

    ShoppersVM.prototype.showDelete = function(shopper) {
      this.chosenShopper.id(shopper.id);
      this.chosenShopper.name(shopper.firstName + ' ' + shopper.lastName);
      return $('.delete.modal').modal('show');
    };

    ShoppersVM.prototype.setPrevShopperPage = function() {
      var nextPage;
      if (this.shoppersPages.activePage === 1) {
        nextPage = this.shoppersPages.allPages.length - 1;
      } else {
        nextPage = this.shoppersPages.activePage - 1;
      }
      return this.fetchShoppersPage({
        num: nextPage
      });
    };

    ShoppersVM.prototype.setNextShopperPage = function() {
      var nextPage;
      if (this.shoppersPages.activePage === this.shoppersPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.shoppersPages.activePage + 1;
      }
      return this.fetchShoppersPage({
        num: nextPage
      });
    };

    ShoppersVM.prototype.fetchShoppersPage = function(page) {
      this.shoppersPages.activePage = page.num;
      this.setPaginationItemsToShow(this.shoppersPages, 'table.shoppers');
      return this.fetchShoppers(page.num);
    };

    ShoppersVM.prototype.fetchShoppers = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      this.isLoading(true);
      data = {
        page: numPage,
        per_page: 30
      };
      return RESTfulService.makeRequest('GET', "/shoppers", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the shoppers!');
            _this.shouldShowShoppersAlert(true);
            return _this.shoppersAlertText('Hubo un problema buscando la información de los shoppers');
          } else {
            console.log(success);
            if (success.length > 0) {
              if (_this.shoppersPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 30);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  _this.shoppersPages.allPages.push({
                    num: i + 1
                  });
                }
                _this.shoppersPages.activePage = 1;
                _this.shoppersPages.lowerLimit = 0;
                _this.shoppersPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.shoppersPages.showablePages(_this.shoppersPages.allPages.slice(_this.shoppersPages.lowerLimit, _this.shoppersPages.upperLimit));
                $("table.shoppers .pagination .pages .item:first-of-type").addClass('active');
              }
              _this.currentShoppers(success);
              _this.shouldShowShoppersAlert(false);
            } else {
              _this.shouldShowShoppersAlert(true);
              _this.shoppersAlertText('No hay shoppers');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    ShoppersVM.prototype.setRulesValidation = function() {
      var emptyRule;
      emptyRule = {
        type: 'empty',
        prompt: 'No puede estar vacío'
      };
      return $('.ui.modal form').form({
        fields: {
          cc: {
            identifier: 'cc',
            rules: [emptyRule]
          },
          firstName: {
            identifier: 'firstName',
            rules: [emptyRule]
          },
          lastName: {
            identifier: 'lastName',
            rules: [emptyRule]
          },
          phoneNumber: {
            identifier: 'phoneNumber',
            rules: [emptyRule]
          },
          email: {
            identifier: 'email',
            rules: [
              {
                type: 'email',
                prompt: 'Ingrese un email válido'
              }
            ]
          },
          shopperType: {
            identifier: 'shopperType',
            rules: [emptyRule]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
    };

    ShoppersVM.prototype.setDOMProperties = function() {
      $('.ui.modal').modal({
        onHidden: function() {
          return $('.ui.modal form').form('clear');
        }
      });
      return $('.ui.modal .dropdown').dropdown();
    };

    return ShoppersVM;

  })(AdminPageVM);

  shoppers = new ShoppersVM;

  ko.applyBindings(shoppers);

}).call(this);
