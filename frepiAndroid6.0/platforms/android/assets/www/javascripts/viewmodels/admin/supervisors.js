(function() {
  var SupervisorsVM, supervisors,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  SupervisorsVM = (function(superClass) {
    extend(SupervisorsVM, superClass);

    function SupervisorsVM() {
      this.fetchSupervisorsPage = bind(this.fetchSupervisorsPage, this);
      this.showDelete = bind(this.showDelete, this);
      this.showUpdate = bind(this.showUpdate, this);
      this.deleteSupervisor = bind(this.deleteSupervisor, this);
      SupervisorsVM.__super__.constructor.call(this);
      this.shouldShowSupervisorsAlert = ko.observable(true);
      this.supervisorsAlertText = ko.observable();
      this.currentSupervisors = ko.observableArray();
      this.chosenSupervisor = {
        id: ko.observable(),
        name: ko.observable()
      };
      this.supervisorsPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.fetchSupervisors();
      this.setRulesValidation();
      this.setDOMProperties();
    }

    SupervisorsVM.prototype.createSupervisor = function() {
      var $form, data;
      $form = $('.create.modal form');
      data = {
        email: $form.form('get value', 'email'),
        identification: $form.form('get value', 'cc'),
        firstName: $form.form('get value', 'firstName'),
        lastName: $form.form('get value', 'lastName'),
        password: $form.form('get value', 'password'),
        phoneNumber: $form.form('get value', 'phoneNumber'),
        passwordConfirmation: $form.form('get value', 'confirmationPassword')
      };
      if ($form.form('is valid')) {
        $('.create.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/supervisors", data, (function(_this) {
          return function(error, success, headers) {
            $('.create.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the supervisor.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              _this.currentSupervisors.push(success);
              return $('.create.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    SupervisorsVM.prototype.updateSupervisor = function() {
      var $form, data, passwordConfirmation;
      $form = $('.update.modal form');
      passwordConfirmation = $form.form('get value', 'confirmationPasswordUpdate');
      data = {
        email: $form.form('get value', 'email'),
        firstName: $form.form('get value', 'firstName'),
        lastName: $form.form('get value', 'lastName'),
        phoneNumber: $form.form('get value', 'phoneNumber')
      };
      if ($form.form('is valid')) {
        if (passwordConfirmation.length > 0) {
          data.password = passwordConfirmation;
        }
        $('.update.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('PUT', "/supervisors/" + (this.chosenSupervisor.id()), data, (function(_this) {
          return function(error, success, headers) {
            $('.update.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the update of the supervisor.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              $('.update.modal').modal('hide');
              return _this.fetchSupervisors();
            }
          };
        })(this));
      }
    };

    SupervisorsVM.prototype.deleteSupervisor = function() {
      $('.delete.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/supervisors/" + (this.chosenSupervisor.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            console.log(success);
            _this.currentSupervisors.remove(function(supervisor) {
              return supervisor.id === _this.chosenSupervisor.id();
            });
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.modal').modal('hide');
          }
        };
      })(this));
    };

    SupervisorsVM.prototype.showUpdate = function(supervisor) {
      this.chosenSupervisor.id(supervisor.id);
      $('.update.modal form').form('set values', {
        email: supervisor.email,
        firstName: supervisor.firstName,
        lastName: supervisor.lastName,
        address: supervisor.address,
        phoneNumber: supervisor.phoneNumber
      });
      return $('.update.modal').modal('show');
    };

    SupervisorsVM.prototype.showDelete = function(supervisor) {
      this.chosenSupervisor.id(supervisor.id);
      this.chosenSupervisor.name(supervisor.firstName + ' ' + supervisor.lastName);
      return $('.delete.modal').modal('show');
    };

    SupervisorsVM.prototype.setPrevSupervisorPage = function() {
      var nextPage;
      if (this.supervisorsPages.activePage === 1) {
        nextPage = this.supervisorsPages.allPages.length - 1;
      } else {
        nextPage = this.supervisorsPages.activePage - 1;
      }
      return this.fetchSupervisorsPage({
        num: nextPage
      });
    };

    SupervisorsVM.prototype.setNextSupervisorPage = function() {
      var nextPage;
      if (this.supervisorsPages.activePage === this.supervisorsPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.supervisorsPages.activePage + 1;
      }
      return this.fetchSupervisorsPage({
        num: nextPage
      });
    };

    SupervisorsVM.prototype.fetchSupervisorsPage = function(page) {
      this.supervisorsPages.activePage = page.num;
      this.setPaginationItemsToShow(this.supervisorsPages, 'table.supervisors');
      return this.fetchSupervisors(page.num);
    };

    SupervisorsVM.prototype.fetchSupervisors = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      this.isLoading(true);
      data = {
        page: numPage
      };
      return RESTfulService.makeRequest('GET', "/supervisors", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the supervisors!');
            _this.shouldShowSupervisorsAlert(true);
            return _this.supervisorsAlertText('Hubo un problema buscando la información de los supervisors');
          } else {
            console.log(success);
            if (success.length > 0) {
              if (_this.supervisorsPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 10);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  _this.supervisorsPages.allPages.push({
                    num: i + 1
                  });
                }
                _this.supervisorsPages.activePage = 1;
                _this.supervisorsPages.lowerLimit = 0;
                _this.supervisorsPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.supervisorsPages.showablePages(_this.supervisorsPages.allPages.slice(_this.supervisorsPages.lowerLimit, _this.supervisorsPages.upperLimit));
                $("table.supervisors .pagination .pages .item:first-of-type").addClass('active');
              }
              _this.currentSupervisors(success);
              _this.shouldShowSupervisorsAlert(false);
            } else {
              _this.shouldShowSupervisorsAlert(true);
              _this.supervisorsAlertText('No hay supervisores');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    SupervisorsVM.prototype.setRulesValidation = function() {
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
          password: {
            identifier: 'password',
            rules: [
              emptyRule, {
                type: 'minLength[6]',
                prompt: 'La contraseña debe tener 6 caracteres mínimo'
              }
            ]
          },
          confirmationPassword: {
            identifier: 'confirmationPassword',
            rules: [
              emptyRule, {
                type: 'match[password]',
                prompt: 'Las contraseñas no coinciden'
              }
            ]
          },
          passwordUpdate: {
            identifier: 'passwordUpdate',
            rules: []
          },
          confirmationPasswordUpdate: {
            identifier: 'confirmationPasswordUpdate',
            rules: [
              {
                type: 'match[passwordUpdate]',
                prompt: 'Las contraseñas no coinciden'
              }
            ]
          },
          email: {
            identifier: 'email',
            rules: [
              emptyRule, {
                type: 'email',
                prompt: 'Ingrese un email válido'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
    };

    SupervisorsVM.prototype.setDOMProperties = function() {
      $('.ui.modal').modal({
        onHidden: function() {
          return $('.ui.modal form').form('clear');
        }
      });
      return $('.ui.modal .dropdown').dropdown();
    };

    return SupervisorsVM;

  })(AdminPageVM);

  supervisors = new SupervisorsVM;

  ko.applyBindings(supervisors);

}).call(this);
