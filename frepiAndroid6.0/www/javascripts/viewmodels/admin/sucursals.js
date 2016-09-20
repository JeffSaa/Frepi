(function() {
  var SucursalsVM, sucursals,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  SucursalsVM = (function(superClass) {
    extend(SucursalsVM, superClass);

    function SucursalsVM() {
      this.fetchSucursalsPage = bind(this.fetchSucursalsPage, this);
      this.showDelete = bind(this.showDelete, this);
      this.showUpdate = bind(this.showUpdate, this);
      this.deleteSucursal = bind(this.deleteSucursal, this);
      SucursalsVM.__super__.constructor.call(this);
      this.shouldShowSucursalsAlert = ko.observable(false);
      this.sucursalsAlertText = ko.observable();
      this.currentSucursals = ko.observableArray();
      this.chosenSucursal = {
        id: ko.observable(),
        name: ko.observable()
      };
      this.sucursalsPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.fetchSucursals();
      this.setDOMProperties();
      this.setRulesValidation();
    }

    SucursalsVM.prototype.createSucursal = function() {
      var $form, data;
      $form = $('.create.modal form');
      data = {
        name: $form.form('get value', 'name'),
        address: $form.form('get value', 'address'),
        phoneNumber: $form.form('get value', 'phoneNumber'),
        managerFullName: $form.form('get value', 'managerFullName'),
        managerPhoneNumber: $form.form('get value', 'managerPhoneNumber')
      };
      console.log(data);
      if ($form.form('is valid')) {
        $('.create.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/stores/1/sucursals", data, (function(_this) {
          return function(error, success, headers) {
            $('.create.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the authentication.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              _this.currentSucursals.push(success);
              return $('.create.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    SucursalsVM.prototype.updateSucursal = function() {
      var $form, data;
      $form = $('.update.modal form');
      data = {
        name: $form.form('get value', 'name'),
        address: $form.form('get value', 'address'),
        phoneNumber: $form.form('get value', 'phoneNumber'),
        managerFullName: $form.form('get value', 'managerFullName'),
        managerPhoneNumber: $form.form('get value', 'managerPhoneNumber')
      };
      if ($form.form('is valid')) {
        $('.update.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('PUT', "/stores/1/sucursals/" + (this.chosenSucursal.id()), data, (function(_this) {
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
              return _this.fetchSucursals();
            }
          };
        })(this));
      }
    };

    SucursalsVM.prototype.deleteSucursal = function() {
      $('.delete.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/stores/1/sucursals/" + (this.chosenSucursal.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            console.log(success);
            _this.currentSucursals.remove(function(sucursal) {
              return sucursal.id === _this.chosenSucursal.id();
            });
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.modal').modal('hide');
          }
        };
      })(this));
    };

    SucursalsVM.prototype.showUpdate = function(sucursal) {
      this.chosenSucursal.id(sucursal.id);
      this.chosenSucursal.name(sucursal.name);
      $('.update.modal form').form('set values', {
        name: sucursal.name,
        address: sucursal.address,
        phoneNumber: sucursal.phoneNumber,
        managerFullName: sucursal.managerFullName,
        managerPhoneNumber: sucursal.managerPhoneNumber
      });
      return $('.update.modal').modal('show');
    };

    SucursalsVM.prototype.showDelete = function(sucursal) {
      this.chosenSucursal.id(sucursal.id);
      this.chosenSucursal.name(sucursal.name);
      return $('.delete.modal').modal('show');
    };

    SucursalsVM.prototype.setPrevSucursalPage = function() {
      var nextPage;
      if (this.sucursalsPages.activePage === 1) {
        nextPage = this.sucursalsPages.allPages.length - 1;
      } else {
        nextPage = this.sucursalsPages.activePage - 1;
      }
      return this.fetchSucursalsPage({
        num: nextPage
      });
    };

    SucursalsVM.prototype.setNextSucursalPage = function() {
      var nextPage;
      if (this.sucursalsPages.activePage === this.sucursalsPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.sucursalsPages.activePage + 1;
      }
      return this.fetchSucursalsPage({
        num: nextPage
      });
    };

    SucursalsVM.prototype.fetchSucursalsPage = function(page) {
      this.sucursalsPages.activePage = page.num;
      this.setPaginationItemsToShow(this.sucursalsPages, 'table.sucursals');
      return this.fetchSucursals(page.num);
    };

    SucursalsVM.prototype.fetchSucursals = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      this.isLoading(true);
      data = {
        page: numPage,
        per_page: 30
      };
      return RESTfulService.makeRequest('GET', "/stores/1/sucursals", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the sucursals!');
            _this.shouldShowSucursalsAlert(true);
            return _this.sucursalsAlertText('Hubo un problema buscando la información de las sucursales');
          } else {
            console.log(success);
            if (success.length > 0) {
              if (_this.sucursalsPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 30);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  _this.sucursalsPages.allPages.push({
                    num: i + 1
                  });
                }
                _this.sucursalsPages.activePage = 1;
                _this.sucursalsPages.lowerLimit = 0;
                _this.sucursalsPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.sucursalsPages.showablePages(_this.sucursalsPages.allPages.slice(_this.sucursalsPages.lowerLimit, _this.sucursalsPages.upperLimit));
                $("table.sucursals .pagination .pages .item:first-of-type").addClass('active');
              }
              _this.currentSucursals(success);
              _this.shouldShowSucursalsAlert(false);
            } else {
              _this.shouldShowSucursalsAlert(true);
              _this.sucursalsAlertText('No hay sucursales');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    SucursalsVM.prototype.setRulesValidation = function() {
      var emptyRule;
      emptyRule = {
        type: 'empty',
        prompt: 'No puede estar vacío'
      };
      return $('.ui.modal form').form({
        fields: {
          name: {
            identifier: 'name',
            rules: [emptyRule]
          },
          address: {
            identifier: 'address',
            rules: [emptyRule]
          },
          phoneNumber: {
            identifier: 'phoneNumber',
            rules: [emptyRule]
          },
          managerPhoneNumber: {
            identifier: 'managerPhoneNumber',
            rules: [emptyRule]
          },
          managerFullName: {
            identifier: 'managerFullName',
            rules: [emptyRule]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
    };

    SucursalsVM.prototype.setDOMProperties = function() {
      return $('.ui.modal').modal({
        onHidden: function() {
          return $('.ui.modal form').form('clear');
        }
      });
    };

    return SucursalsVM;

  })(AdminPageVM);

  sucursals = new SucursalsVM;

  ko.applyBindings(sucursals);

}).call(this);
