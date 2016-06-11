(function() {
  var ProfileVM, profile,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ProfileVM = (function(superClass) {
    extend(ProfileVM, superClass);

    RouteValidator.checkUser();

    moment.locale('es');

    function ProfileVM() {
      this.showOrderDetails = bind(this.showOrderDetails, this);
      this.uploadImage = bind(this.uploadImage, this);
      this.setAWSCredentials = bind(this.setAWSCredentials, this);
      this.previewImage = bind(this.previewImage, this);
      ProfileVM.__super__.constructor.call(this);
      this.AWSBucket = null;
      this.errorLabelText = ko.observable();
      this.currentOrders = ko.observableArray();
      this.showEmptyMessage = ko.observable();
      this.checkOrders = ko.computed((function(_this) {
        return function() {
          return _this.showEmptyMessage(_this.currentOrders().length === 0);
        };
      })(this));
      this.chosenOrder = {
        id: ko.observable(),
        status: ko.observable(""),
        creationDate: ko.observable(),
        arrivalDate: ko.observable(),
        address: ko.observable(),
        totalPrice: ko.observable(),
        products: ko.observableArray()
      };
      this.setUserInfo();
      this.setExistingSession();
      this.fetchOrders();
      this.setDOMElements();
      this.shouldShowOrders();
      this.setSizeSidebar();
    }

    ProfileVM.prototype.closeEditEmail = function() {
      $('#edit-email').modal('hide');
      return $('#edit-email form').form('clear');
    };

    ProfileVM.prototype.closeEditPassword = function() {
      $('#edit-password').modal('hide');
      return $('#edit-password form').form('clear');
    };

    ProfileVM.prototype.fetchOrders = function() {
      console.log('Fetching the orders...');
      return RESTfulService.makeRequest('GET', "/users/" + this.user.id + "/orders", '', (function(_this) {
        return function(error, success, headers) {
          if (error) {
            return console.log('An error has ocurred while fetching the orders!');
          } else {
            console.log(success);
            _this.setDOMElems();
            return _this.currentOrders(success);
          }
        };
      })(this));
    };

    ProfileVM.prototype.profile = function() {
      Config.setItem('showOrders', 'false');
      return $('.secondary.menu .item').tab('change tab', 'account');
    };

    ProfileVM.prototype.orders = function() {
      Config.setItem('showOrders', 'true');
      return $('.secondary.menu .item').tab('change tab', 'history');
    };

    ProfileVM.prototype.parseOrderDate = function(orders) {
      var i, len, order;
      for (i = 0, len = orders.length; i < len; i++) {
        order = orders[i];
        order.date = moment(order.date, moment.ISO_8601).format('YYYY-MM-DD HH:mm:ss');
        order.arrivalTime = moment(order.arrivalTime, moment.ISO_8601).format('HH:mm');
        order.expiryTime = moment(order.expiryTime, moment.ISO_8601).format('HH:mm');
        order.scheduledDate = moment(order.scheduledDate, moment.ISO_8601).format('YYYY-MM-DD');
      }
      return orders;
    };

    ProfileVM.prototype.shouldShowOrders = function() {
      console.log('Showing orders');
      if (Config.getItem('showOrders') === 'true') {
        $('.secondary.menu .item').tab('change tab', 'history');
      }
      return console.log('Orders shown');
    };

    ProfileVM.prototype.setDOMElements = function() {
      $('#edit-email form').form({
        fields: {
          newEmail: {
            identifier: 'new-email',
            rules: [
              {
                type: 'empty',
                prompt: 'No puede estar vacío'
              }, {
                type: 'email',
                prompt: 'Digite una dirección de correo válida'
              }
            ]
          },
          match: {
            identifier: 'confirmation-new-email',
            rules: [
              {
                type: 'match[new-email]',
                prompt: 'Las direcciones de correo deben ser iguales'
              }, {
                type: 'empty',
                prompt: 'No puede estar vacío'
              }, {
                type: 'email',
                prompt: 'Digite una dirección de correo válida'
              }
            ]
          },
          password: {
            identifier: 'password',
            rules: [
              {
                type: 'empty',
                prompt: 'No puede estar vacía'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
      $('#edit-password form').form({
        fields: {
          newPassword: {
            identifier: 'new-password',
            rules: [
              {
                type: 'empty',
                prompt: 'No puede estar vacía'
              }, {
                type: 'length[6]',
                prompt: 'La contraseña debe tener por lo menos 6 caracteres'
              }
            ]
          },
          match: {
            identifier: 'confirmation-new-password',
            rules: [
              {
                type: 'match[new-password]',
                prompt: 'Las contraseñas no coinciden'
              }, {
                type: 'empty',
                prompt: 'No puede estar vacía'
              }
            ]
          },
          currentPassword: {
            identifier: 'current-password',
            rules: [
              {
                type: 'empty',
                prompt: 'No puede estar vacía'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
      $('#edit-user-info form').form({
        fields: {
          firstName: {
            identifier: 'firstName',
            rules: [
              {
                type: 'empty',
                prompt: 'No puede estar vacío'
              }
            ]
          },
          lastName: {
            identifier: 'lastName',
            rules: [
              {
                type: 'empty',
                prompt: 'No puede estar vacío'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
      $('#edit-email').modal({
        onHidden: function() {
          return $('#edit-email form').form('clear');
        }
      }).modal('attach events', '#edit-email .cancel.button', 'hide');
      $('#edit-password').modal({
        onHidden: function() {
          return $('#edit-password form').form('clear');
        }
      }).modal('attach events', '#edit-password .cancel.button', 'hide');
      $('#edit-user-info').modal({
        onHidden: function() {
          return $('#edit-user-info form').form('clear');
        }
      }).modal('attach events', '#edit-user-info .cancel.button', 'hide');
      $('.secondary.menu .item').tab({
        cache: false
      });
      $('#departments-menu').sidebar({
        transition: 'overlay'
      }).sidebar('attach events', '#store-secondary-navbar button.basic', 'show');
      $('#mobile-menu').sidebar('setting', 'transition', 'overlay').sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show');
      return $('.circular.image .ui.dimmer').dimmer({
        on: 'hover'
      });
    };

    ProfileVM.prototype.showDepartments = function() {
      return $('#departments-menu').sidebar('toggle');
    };

    ProfileVM.prototype.showEditEmail = function() {
      return $('#edit-email').modal('show');
    };

    ProfileVM.prototype.showEditPassword = function() {
      return $('#edit-password').modal('show');
    };

    ProfileVM.prototype.showEditUser = function() {
      $('#edit-user-info').modal('show');
      return $('#edit-user-info form').form('set values', {
        firstName: this.user.name(),
        lastName: this.user.lastName(),
        phone: this.user.phone()
      });
    };

    ProfileVM.prototype.cancelOrder = function() {
      $('#order-details .red.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/users/" + this.user.id + "/orders/" + (this.chosenOrder.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('#order-details .red.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while cancelling the orders!');
          } else {
            console.log(success);
            _this.currentOrders.remove(function(order) {
              return order.id === _this.chosenOrder.id();
            });
            return $('#order-details').modal('hide');
          }
        };
      })(this));
    };

    ProfileVM.prototype.setStatus = function(status, truncated) {
      switch (status) {
        case 'DELIVERING':
          if (!truncated) {
            return 'En camino';
          } else {
            return 'E';
          }
          break;
        case 'DISPATCHED':
          if (!truncated) {
            return 'Entregada';
          } else {
            return 'E';
          }
          break;
        case 'RECEIVED':
          if (!truncated) {
            return 'Recibida';
          } else {
            return 'R';
          }
          break;
        case 'SHOPPING':
          if (!truncated) {
            return 'Comprando';
          } else {
            return 'C';
          }
      }
    };

    ProfileVM.prototype.updateUser = function(attributeToUpdate) {
      var data, newEmail, newFirstName, newLastName, newPassword, newPhone;
      data = {};
      switch (attributeToUpdate) {
        case 'email':
          if ($('#edit-email form').form('is valid')) {
            newEmail = $('#edit-email form').form('get value', 'new-email');
            data = {
              email: newEmail
            };
            $('#edit-email .green.button').addClass('loading');
            return RESTfulService.makeRequest('PUT', "/users/" + this.user.id, data, (function(_this) {
              return function(error, success, headers) {
                $('#edit-email .green.button').removeClass('loading');
                if (error) {
                  return console.log('An error has ocurred while updating the user!');
                } else {
                  console.log('User has been updated');
                  console.log(success);
                  if (headers.accessToken) {
                    Config.setItem('headers', JSON.stringify(headers));
                  }
                  Config.setItem('userObject', JSON.stringify(success));
                  _this.setUserInfo();
                  return $('#edit-email').modal('hide');
                }
              };
            })(this));
          }
          break;
        case 'password':
          if ($('#edit-password form').form('is valid')) {
            newPassword = $('#edit-password form').form('get value', 'new-password');
            data = {
              password: newPassword
            };
            $('#edit-password .green.button').addClass('loading');
            return RESTfulService.makeRequest('PUT', "/users/" + this.user.id, data, (function(_this) {
              return function(error, success, headers) {
                $('#edit-password .green.button').removeClass('loading');
                if (error) {
                  return console.log('An error has ocurred while updating the user!');
                } else {
                  console.log('User has been updated');
                  console.log(success);
                  if (headers.accessToken) {
                    Config.setItem('headers', JSON.stringify(headers));
                  }
                  Config.setItem('userObject', JSON.stringify(success));
                  _this.setUserInfo();
                  return $('#edit-password').modal('hide');
                }
              };
            })(this));
          }
          break;
        case 'user':
          if ($('#edit-user-info form').form('is valid')) {
            console.log('Editing user info');
            newFirstName = $('#edit-user-info form').form('get value', 'firstName');
            newLastName = $('#edit-user-info form').form('get value', 'lastName');
            newPhone = $('#edit-user-info form').form('get value', 'phone');
            data = {
              name: newFirstName,
              last_name: newLastName,
              phone_number: newPhone
            };
            $('#edit-user-info .green.button').addClass('loading');
            return RESTfulService.makeRequest('PUT', "/users/" + this.user.id, data, (function(_this) {
              return function(error, success, headers) {
                $('#edit-user-info .green.button').removeClass('loading');
                if (error) {
                  return console.log('An error has ocurred while updating the user!');
                } else {
                  console.log('User has been updated');
                  console.log(success);
                  Config.setItem('userObject', JSON.stringify(success));
                  if (headers.accessToken) {
                    Config.setItem('headers', JSON.stringify(headers));
                  }
                  _this.setUserInfo();
                  return $('#edit-user-info').modal('hide');
                }
              };
            })(this));
          }
      }
    };

    ProfileVM.prototype.setSizeButtons = function() {
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

    ProfileVM.prototype.generateUniqueID = function() {
      var asciiCode, idstr;
      idstr = String.fromCharCode(Math.floor((Math.random() * 25) + 65));
      while (true) {
        asciiCode = Math.floor((Math.random() * 42) + 48);
        if (asciiCode < 58 || asciiCode > 64) {
          idstr += String.fromCharCode(asciiCode);
        }
        if (!(idstr.length < 32)) {
          break;
        }
      }
      return idstr;
    };

    ProfileVM.prototype.previewImage = function(data, event) {
      this.user.profilePicture(URL.createObjectURL(event.target.files[0]));
      return $('.circular.image img')[0].src = URL.createObjectURL(event.target.files[0]);
    };

    ProfileVM.prototype.setAWSCredentials = function() {
      AWS.config.region = 'us-east-1';
      AWS.config.update({
        accessKeyId: 'AKIAJPKUUYXNQVWSKLHA',
        secretAccessKey: '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'
      });
      return this.AWSBucket = new AWS.S3({
        params: {
          Bucket: 'frepi'
        }
      });
    };

    ProfileVM.prototype.uploadImage = function() {
      var $fileChooser, fileToUpload, objKey, params;
      $fileChooser = $('.circular.image .dimmer input')[0];
      fileToUpload = $fileChooser.files[0];
      this.currentUniqueID = this.generateUniqueID();
      if (fileToUpload) {
        objKey = 'profile/' + this.currentUniqueID;
        params = {
          Key: objKey,
          ContentType: fileToUpload.type,
          Body: fileToUpload,
          ACL: 'public-read'
        };
        $('.circular.image .dimmer .button').addClass('loading');
        return this.AWSBucket.upload(params).on('httpUploadProgress', function(evt) {
          var AWSprogress;
          AWSprogress = parseInt((evt.loaded * 100) / evt.total);
          console.log("Uploaded :: " + parseInt((evt.loaded * 100) / evt.total) + '%');
          return $currentProgressBar.progress({
            percent: AWSprogress
          });
        }).send((function(_this) {
          return function(err, data) {
            if (!err) {
              _this.fileHasBeenUploaded = true;
              if (isCreationModalActive) {
                return _this.createProduct();
              } else {
                return _this.updateProduct();
              }
            } else {
              return $('.circular.image .dimmer .button').removeClass('loading');
            }
          };
        })(this));
      } else {
        return alert('Nothing to upload');
      }
    };

    ProfileVM.prototype.dateFormatter = function(datetime) {
      return moment(datetime, moment.ISO_8601).format('DD MMMM YYYY [, ] h:mm A');
    };

    ProfileVM.prototype.parseDate = function(date) {
      return moment(date, moment.ISO_8601).format('DD MMMM YYYY');
    };

    ProfileVM.prototype.parseTime = function(date) {
      return moment(date, moment.ISO_8601).utcOffset("00:00").format('h:mm A');
    };

    ProfileVM.prototype.ProductsFormatter = function(products) {
      var i, information, len, product;
      information = '';
      for (i = 0, len = products.length; i < len; i++) {
        product = products[i];
        information += product.product.name + " x " + product.quantity;
        if (products.indexOf(product) !== products.length - 1) {
          information += ", ";
        }
      }
      return information;
    };

    ProfileVM.prototype.productsText = function(products) {
      var numberProducts;
      numberProducts = products.length;
      if (numberProducts === 1) {
        return numberProducts + " producto";
      } else {
        return numberProducts + " productos";
      }
    };

    ProfileVM.prototype.showOrderDetails = function(order) {
      this.chosenOrder.id(order.id);
      this.chosenOrder.status(order.status);
      this.chosenOrder.creationDate(this.dateFormatter(order.date));
      this.chosenOrder.arrivalDate((this.parseDate(order.scheduledDate)) + ", " + (this.parseTime(order.arrivalTime)));
      this.chosenOrder.address(order.address);
      this.chosenOrder.products(order.products);
      this.chosenOrder.totalPrice(order.totalPrice.toLocaleString());
      return $('#order-details').modal('show');
    };

    return ProfileVM;

  })(TransactionalPageVM);

  profile = new ProfileVM;

  ko.applyBindings(profile);

}).call(this);
