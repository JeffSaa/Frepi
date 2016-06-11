(function() {
  var AdminsVM, admins,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  AdminsVM = (function(superClass) {
    extend(AdminsVM, superClass);

    function AdminsVM() {
      this.fetchUsersPage = bind(this.fetchUsersPage, this);
      this.fetchAdmins = bind(this.fetchAdmins, this);
      this.fetchAdminsPage = bind(this.fetchAdminsPage, this);
      this.showDelete = bind(this.showDelete, this);
      this.showUpdate = bind(this.showUpdate, this);
      this.deleteUser = bind(this.deleteUser, this);
      AdminsVM.__super__.constructor.call(this);
      this.adminsAlertText = ko.observable();
      this.usersAlertText = ko.observable();
      this.shouldShowUsersAlert = ko.observable(true);
      this.shouldShowAdminsAlert = ko.observable(true);
      this.currentAdmins = ko.observableArray();
      this.currentUsers = ko.observableArray();
      this.chosenUser = {
        id: ko.observable(),
        name: ko.observable(),
        isAdmin: ko.observable()
      };
      this.adminsPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.usersPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.fetchUsers();
      this.setRulesValidation();
      this.setDOMProperties();
    }

    AdminsVM.prototype.activeTranslation = function(active) {
      if (active) {
        return 'Si';
      } else {
        return 'No';
      }
    };

    AdminsVM.prototype.createAdmin = function() {
      var $form, data;
      $form = $('.create.modal form');
      data = {
        email: $form.form('get value', 'email'),
        name: $form.form('get value', 'firstName'),
        address: $form.form('get value', 'address'),
        identification: $form.form('get value', 'cc'),
        lastName: $form.form('get value', 'lastName'),
        password: $form.form('get value', 'password'),
        phoneNumber: $form.form('get value', 'phoneNumber'),
        passwordConfirmation: $form.form('get value', 'confirmationPassword')
      };
      console.log(data);
      if ($form.form('is valid')) {
        $('.create.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/administrator/users", data, (function(_this) {
          return function(error, success, headers) {
            $('.create.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the admin.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              _this.currentAdmins.push(success);
              return $('.create.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    AdminsVM.prototype.updateUser = function() {
      var $form, data;
      $form = $('.update.modal form');
      data = {
        email: $form.form('get value', 'email'),
        name: $form.form('get value', 'firstName'),
        address: $form.form('get value', 'address'),
        identification: $form.form('get value', 'cc'),
        lastName: $form.form('get value', 'lastName'),
        phoneNumber: $form.form('get value', 'phoneNumber')
      };
      if ($form.form('is valid')) {
        $('.update.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('PUT', "/administrator/users/" + (this.chosenUser.id()), data, (function(_this) {
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
              return _this.fetchUsersPage({
                num: 1
              });
            }
          };
        })(this));
      }
    };

    AdminsVM.prototype.deleteUser = function() {
      $('.delete.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/administrator/users/" + (this.chosenUser.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            console.log(success);
            if (_this.chosenUser.isAdmin()) {
              _this.currentAdmins.remove(function(user) {
                return user.id === _this.chosenUser.id();
              });
            } else {
              _this.currentUsers.remove(function(user) {
                return user.id === _this.chosenUser.id();
              });
            }
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.modal').modal('hide');
          }
        };
      })(this));
    };

    AdminsVM.prototype.showUpdate = function(user) {
      this.chosenUser.id(user.id);
      $('.update.modal form').form('set values', {
        email: user.email,
        firstName: user.name,
        lastName: user.lastName,
        address: user.address,
        cc: user.identification,
        password: user.password,
        phoneNumber: user.phoneNumber
      });
      return $('.update.modal').modal('show');
    };

    AdminsVM.prototype.showDelete = function(user) {
      this.chosenUser.id(user.id);
      this.chosenUser.name(user.name + ' ' + user.lastName);
      this.chosenUser.isAdmin(user.administrator);
      return $('.delete.modal').modal('show');
    };

    AdminsVM.prototype.setPrevAdminPage = function() {
      var nextPage;
      if (this.adminsPages.activePage === 1) {
        nextPage = this.adminsPages.allPages.length - 1;
      } else {
        nextPage = this.adminsPages.activePage - 1;
      }
      return this.fetchAdminsPage({
        num: nextPage
      });
    };

    AdminsVM.prototype.setNextAdminPage = function() {
      var nextPage;
      if (this.adminsPages.activePage === this.adminsPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.adminsPages.activePage + 1;
      }
      return this.fetchAdminsPage({
        num: nextPage
      });
    };

    AdminsVM.prototype.fetchAdminsPage = function(page) {
      this.adminsPages.activePage = page.num;
      this.setPaginationItemsToShow(this.adminsPages, 'table.admins');
      return this.fetchAdmins(page.num);
    };

    AdminsVM.prototype.fetchAdmins = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      data = {
        page: numPage
      };
      return RESTfulService.makeRequest('GET', "/administrator/admins", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the admins!');
            _this.shouldShowAdminsAlert(true);
            return _this.adminsAlertText('Hubo un problema buscando la información de los administradores');
          } else {
            console.log(success);
            if (success.length > 0) {
              if (_this.adminsPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 10);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  _this.adminsPages.allPages.push({
                    num: i + 1
                  });
                }
                _this.adminsPages.activePage = 1;
                _this.adminsPages.lowerLimit = 0;
                _this.adminsPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.adminsPages.showablePages(_this.adminsPages.allPages.slice(_this.adminsPages.lowerLimit, _this.adminsPages.upperLimit));
                $("table.admins .pagination .pages .item:first-of-type").addClass('active');
              }
              _this.currentAdmins(success);
              _this.shouldShowAdminsAlert(false);
            } else {
              _this.shouldShowAdminsAlert(true);
              _this.adminsAlertText('No hay administradores');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    AdminsVM.prototype.setPrevUserPage = function() {
      var nextPage;
      if (this.usersPages.activePage === 1) {
        nextPage = this.usersPages.allPages.length - 1;
      } else {
        nextPage = this.usersPages.activePage - 1;
      }
      return this.fetchUsersPage({
        num: nextPage
      });
    };

    AdminsVM.prototype.setNextUserPage = function() {
      var nextPage;
      if (this.usersPages.activePage === this.usersPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.usersPages.activePage + 1;
      }
      return this.fetchUsersPage({
        num: nextPage
      });
    };

    AdminsVM.prototype.fetchUsersPage = function(page) {
      this.usersPages.activePage = page.num;
      this.setPaginationItemsToShow(this.usersPages, 'table.users');
      return this.fetchUsers(page.num);
    };

    AdminsVM.prototype.fetchUsers = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      this.isLoading(true);
      data = {
        page: numPage
      };
      return RESTfulService.makeRequest('GET', "/administrator/users", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the clients!');
            _this.shouldShowAdminsAlert(true);
            return _this.usersAlertText('Hubo un problema buscando la información de los usuarios');
          } else {
            console.log(success);
            if (success.length > 0) {
              if (_this.usersPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 10);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  _this.usersPages.allPages.push({
                    num: i + 1
                  });
                }
                _this.usersPages.activePage = 1;
                _this.usersPages.lowerLimit = 0;
                _this.usersPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.usersPages.showablePages(_this.usersPages.allPages.slice(_this.usersPages.lowerLimit, _this.usersPages.upperLimit));
                console.log('user pages');
                console.log(_this.usersPages);
                $("table.users .pagination .pages .item:first-of-type").addClass('active');
              }
              _this.currentUsers(success);
              _this.shouldShowUsersAlert(false);
            } else {
              _this.shouldShowUsersAlert(true);
              _this.usersAlertText('No hay usuarios');
            }
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return _this.fetchAdmins();
          }
        };
      })(this));
    };

    AdminsVM.prototype.setRulesValidation = function() {
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
          address: {
            identifier: 'address',
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

    AdminsVM.prototype.setDOMProperties = function() {
      return $('.ui.modal').modal({
        onHidden: function() {
          return $('.ui.modal form').form('clear');
        }
      });
    };

    return AdminsVM;

  })(AdminPageVM);

  admins = new AdminsVM;

  ko.applyBindings(admins);

}).call(this);
