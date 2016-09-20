(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.TransactionalPageVM = (function() {
    function TransactionalPageVM() {
      this.signUp = bind(this.signUp, this);
      this.setUserInfo = bind(this.setUserInfo, this);
      this.addToCart = bind(this.addToCart, this);
      this.chooseDeparment = bind(this.chooseDeparment, this);
      this.checkout = bind(this.checkout, this);
      this.searchInput = bind(this.searchInput, this);
      this.session = {
        currentStore: null,
        stringToSearch: null,
        currentSucursal: null,
        currentDeparmentID: null,
        currentSubcategorID: null,
        categories: ko.observableArray([]),
        signedUp: ko.observable(),
        sucursals: ko.observableArray([]),
        currentOrder: {
          numberProducts: ko.observable(),
          products: ko.observableArray([]),
          price: ko.observable(),
          sucursalId: null
        }
      };
      this.user = {
        id: null,
        provider: null,
        discount: ko.observable(),
        email: ko.observable(),
        name: ko.observable(),
        firstName: ko.observable(),
        lastName: ko.observable(),
        phone: ko.observable(),
        profilePicture: ko.observable(),
        fullName: ko.observable()
      };
      this.selectedProduct = null;
      this.selectedProductCategory = ko.observable();
      this.selectedProductImage = ko.observable();
      this.selectedProductName = ko.observable();
      this.selectedProductPrice = ko.observable();
      this.selectedProductSize = ko.observable();
      this.selectedProductDescription = ko.observable();
      this.errorTextSignUp = ko.observable();
      this.isLogged = ko.observable(false);
      this.shouldShowDiscountMessage = ko.observable(false);
      this.setUserInfo();
      this.setRulesValidation();
    }

    TransactionalPageVM.prototype.searchInput = function() {
      var valueInput;
      valueInput = $('#product-searcher').form('get value', 'value');
      this.session.stringToSearch = valueInput;
      this.saveOrder();
      return window.location.href = '../store/search.html';
    };

    TransactionalPageVM.prototype.checkout = function() {
      var orderToPay;
      if (this.user.id !== null) {
        if (this.session.currentOrder.products().length > 0) {
          orderToPay = {
            price: this.session.currentOrder.price(),
            products: this.session.currentOrder.products(),
            sucursalId: this.session.currentOrder.sucursalId
          };
          console.log(orderToPay);
          Config.setItem('orderToPay', JSON.stringify(orderToPay));
          return window.location.href = '../checkout.html';
        } else {
          return console.log('There is nothing in the cart...');
        }
      } else {
        $('#shopping-cart .checkout').addClass('hide');
        return $('#shopping-cart .sign-up-banner').addClass('show');
      }
    };

    TransactionalPageVM.prototype.getProductByID = function(id) {
      var i, len, product, ref;
      ref = this.session.currentOrder.products();
      for (i = 0, len = ref.length; i < len; i++) {
        product = ref[i];
        if (product.id === id) {
          return product;
        }
      }
      return null;
    };

    TransactionalPageVM.prototype.chooseStore = function(store) {
      ko.mapping.fromJS(store, this.session.currentSucursal);
      return $('#choose-store').modal('hide');
    };

    TransactionalPageVM.prototype.chooseDeparment = function(subdeparment) {
      if (subdeparment.categoryId) {
        this.session.currentDeparmentID = subdeparment.categoryId;
        this.session.currentSubcategorID = subdeparment.id;
      } else {
        this.session.currentDeparmentID = subdeparment.id;
        this.session.currentSubcategorID = null;
      }
      this.saveOrder();
      return window.location.href = '../store/deparment.html';
    };

    TransactionalPageVM.prototype.showTextArea = function(data, event) {
      var $noteLabel, $saveComment, $textArea;
      $noteLabel = $(event.currentTarget);
      $textArea = $(event.currentTarget).parent().children('textarea');
      $saveComment = $(event.currentTarget).parent().children('.save.comment');
      $noteLabel.css('display', 'none');
      $textArea.css('display', 'block');
      return $saveComment.css('display', 'inline-block');
    };

    TransactionalPageVM.prototype.addComment = function(product, event) {
      var $noteLabel, $saveComment, $textArea, newProduct, oldProduct, textareaValue;
      $noteLabel = $(event.currentTarget).parent().children('.note.label');
      $textArea = $(event.currentTarget).parent().children('textarea');
      $saveComment = $(event.currentTarget);
      textareaValue = $textArea.val();
      oldProduct = product;
      newProduct = {
        comment: textareaValue,
        frepiPrice: product.frepiPrice,
        id: product.id,
        image: product.image,
        name: product.name,
        quantity: product.quantity,
        subcategoryId: product.subcategoryId,
        totalPrice: parseInt(product.frepiPrice)
      };
      this.session.currentOrder.products.replace(oldProduct, newProduct);
      this.saveOrder();
      $noteLabel.css('display', 'inline-block');
      $textArea.css('display', 'none');
      return $saveComment.css('display', 'none');
    };

    TransactionalPageVM.prototype.showInputField = function() {
      $('.modal .input.field').addClass('show');
      return $('.modal .dropdown.field').addClass('hide');
    };

    TransactionalPageVM.prototype.addProductModal = function() {
      var isntInputFieldShown, quantity;
      isntInputFieldShown = $('.modal .input.field').attr('class').split(' ').indexOf('show') === -1;
      if (isntInputFieldShown) {
        if ($('#product-desc form').form('get value', 'quantityDropdown')) {
          quantity = $('#product-desc form').form('get value', 'quantityDropdown');
          this.addToCart(this.selectedProduct, parseInt(quantity));
          return $('#product-desc').modal('hide');
        }
      } else {
        if ($('#product-desc form').form('get value', 'quantity') > 0) {
          quantity = $('#product-desc form').form('get value', 'quantity');
          this.addToCart(this.selectedProduct, parseInt(quantity));
          return $('#product-desc').modal('hide');
        }
      }
    };

    TransactionalPageVM.prototype.addToCart = function(productToAdd, quantitySelected) {
      var newProduct, oldProduct, product;
      product = this.getProductByID(productToAdd.id);
      quantitySelected = parseInt(quantitySelected);
      if (!isNaN(quantitySelected)) {
        if (!product) {
          this.session.currentOrder.products.push({
            comment: "",
            frepiPrice: productToAdd.frepiPrice || productToAdd.frepi_price,
            id: productToAdd.id,
            image: productToAdd.image,
            name: productToAdd.name,
            size: productToAdd.size,
            quantity: quantitySelected,
            subcategoryId: productToAdd.subcategoryId,
            totalPrice: parseInt(productToAdd.frepiPrice || productToAdd.frepi_price) * quantitySelected
          });
          $("#" + productToAdd.id + " .image .label .quantity").text(quantitySelected);
          $("#" + productToAdd.id + " .image .label").addClass('show');
        } else {
          oldProduct = product;
          newProduct = {
            comment: oldProduct.comment,
            frepiPrice: oldProduct.frepiPrice || oldProduct.frepi_price,
            id: oldProduct.id,
            image: oldProduct.image,
            name: oldProduct.name,
            size: oldProduct.size,
            quantity: oldProduct.quantity + quantitySelected,
            subcategoryId: oldProduct.subcategoryId,
            totalPrice: parseInt((oldProduct.frepiPrice || oldProduct.frepi_price) * (oldProduct.quantity + quantitySelected))
          };
          this.session.currentOrder.products.replace(oldProduct, newProduct);
          $("#" + productToAdd.id + " .image .label .quantity").text(oldProduct.quantity + quantitySelected);
        }
        this.session.currentOrder.price(parseInt(this.session.currentOrder.price() + (productToAdd.frepiPrice || productToAdd.frepi_price) * quantitySelected));
        if (this.session.currentOrder.products().length !== 1) {
          this.session.currentOrder.numberProducts((this.session.currentOrder.products().length) + " items");
        } else {
          this.session.currentOrder.numberProducts("1 item");
        }
        return this.saveOrder();
      }
    };

    TransactionalPageVM.prototype.logout = function() {
      return RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (function(_this) {
        return function(error, success, headers) {
          if (error) {
            return console.log('An error has ocurred');
          } else {
            Config.destroyLocalStorage();
            return window.location.href = '../store/index.html';
          }
        };
      })(this));
    };

    TransactionalPageVM.prototype.saveOrder = function() {
      var session;
      session = {
        categories: this.session.categories(),
        currentStore: ko.mapping.toJS(this.session.currentStore),
        currentSucursal: ko.mapping.toJS(this.session.currentSucursal),
        stringToSearch: this.session.stringToSearch,
        currentDeparmentID: this.session.currentDeparmentID,
        currentSubcategorID: this.session.currentSubcategorID,
        signedUp: this.session.signedUp(),
        sucursals: this.session.sucursals(),
        currentOrder: {
          numberProducts: this.session.currentOrder.numberProducts(),
          products: this.session.currentOrder.products(),
          price: this.session.currentOrder.price(),
          sucursalId: this.session.currentOrder.sucursalId
        }
      };
      return Config.setItem('currentSession', JSON.stringify(session));
    };

    TransactionalPageVM.prototype.store = function() {
      this.saveOrder();
      return window.location.href = '../store/index.html';
    };

    TransactionalPageVM.prototype.removeFromCart = function(product) {
      var newProduct, oldProduct;
      if (product.quantity === 1) {
        return this.removeItem(product);
      } else {
        oldProduct = product;
        newProduct = {
          comment: oldProduct.comment,
          frepiPrice: oldProduct.frepiPrice || oldProduct.frepi_price,
          id: oldProduct.id,
          image: oldProduct.image,
          name: oldProduct.name,
          quantity: oldProduct.quantity - 1,
          subcategoryId: oldProduct.subcategoryId,
          totalPrice: parseInt((oldProduct.frepiPrice || oldProduct.frepi_price) * (oldProduct.quantity - 1))
        };
        $("#" + product.id + " .image .label .quantity").text(oldProduct.quantity - 1);
        this.session.currentOrder.products.replace(oldProduct, newProduct);
        this.session.currentOrder.price(parseInt(this.session.currentOrder.price() - (product.frepiPrice || product.frepi_price)));
        return this.saveOrder();
      }
    };

    TransactionalPageVM.prototype.removeItem = function(item) {
      this.session.currentOrder.price(parseInt(this.session.currentOrder.price() - item.totalPrice));
      this.session.currentOrder.products.remove(item);
      $("#" + item.id + " .image .label").removeClass('show');
      if (this.session.currentOrder.products().length !== 1) {
        this.session.currentOrder.numberProducts((this.session.currentOrder.products().length) + " items");
      } else {
        this.session.currentOrder.numberProducts("1 item");
      }
      return this.saveOrder();
    };

    TransactionalPageVM.prototype.setCartItemsLabels = function() {
      var i, len, product, ref, results;
      ref = this.session.currentOrder.products();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        product = ref[i];
        $("#" + product.id + " .image .label .quantity").text(product.quantity);
        results.push($("#" + product.id + " .image .label").addClass('show'));
      }
      return results;
    };

    TransactionalPageVM.prototype.setExistingSession = function() {
      var session;
      session = Config.getItem('currentSession');
      if (session) {
        session = JSON.parse(Config.getItem('currentSession'));
        this.session.currentStore = ko.mapping.fromJS(session.currentStore);
        this.session.currentSucursal = ko.mapping.fromJS(session.currentSucursal);
        this.session.currentDeparmentID = session.currentDeparmentID;
        this.session.currentSubcategorID = session.currentSubcategorID;
        this.session.stringToSearch = session.stringToSearch;
        this.session.categories(session.categories);
        this.session.sucursals(session.sucursals);
        this.session.signedUp(session.signedUp);
        this.session.currentOrder.numberProducts(session.currentOrder.numberProducts);
        this.session.currentOrder.products(session.currentOrder.products);
        this.session.currentOrder.price(session.currentOrder.price);
        this.session.currentOrder.sucursalId = session.currentOrder.sucursalId;
        return this.setDOMElems();
      } else {
        this.session.currentStore = ko.mapping.fromJS(DefaultModels.STORE_PARTNER);
        this.session.stringToSearch = '';
        this.session.currentSucursal = ko.mapping.fromJS(DefaultModels.SUCURSAL);
        this.session.currentDeparmentID = 1;
        this.session.currentSubcategorID = 1;
        this.session.categories([]);
        this.session.sucursals([]);
        this.session.signedUp(false);
        this.session.currentOrder.numberProducts('0 items');
        this.session.currentOrder.products([]);
        this.session.currentOrder.price(0.0);
        console.log('session price');
        console.log(this.session.currentOrder.price());
        return this.session.currentOrder.sucursalId = 1;
      }
    };

    TransactionalPageVM.prototype.setUserInfo = function() {
      var tempUser;
      if (!!Config.getItem('userObject')) {
        tempUser = JSON.parse(Config.getItem('userObject'));
        this.user.id = tempUser.id;
        this.user.provider = tempUser.provider;
        this.user.email(tempUser.email);
        this.user.discount(tempUser.discount);
        this.user.name(tempUser.name);
        this.user.discount(tempUser.discount);
        this.user.firstName(tempUser.name.split(' ')[0]);
        this.user.lastName(tempUser.lastName || tempUser.last_name);
        this.user.fullName(this.user.firstName() + ' ' + this.user.lastName());
        this.user.phone(tempUser.phoneNumber || tempUser.phone_number);
        this.user.profilePicture(tempUser.image || '../images/male_avatar.png');
        this.shouldShowDiscountMessage(tempUser.discount > 0);
        return this.isLogged(true);
      } else {
        this.user.firstName('amigo');
        this.isLogged(false);
        return this.shouldShowDiscountMessage(false);
      }
    };

    TransactionalPageVM.prototype.signUp = function() {
      var $form, data;
      $form = $('#sign-up .ui.form');
      $form.removeClass('error');
      if ($form.form('is valid')) {
        data = {
          name: $form.form('get value', 'firstName'),
          address: $form.form('get value', 'address'),
          last_name: $form.form('get value', 'lastName'),
          email: $form.form('get value', 'email'),
          phone_number: $form.form('get value', 'phoneNumber'),
          password: $form.form('get value', 'password'),
          password_confirmation: $form.form('get value', 'password')
        };
        $('#sign-up .form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', '/users', data, (function(_this) {
          return function(error, success, headers) {
            if (error) {
              $('#sign-up .form .green.button').removeClass('loading');
              $form.addClass('error');
              console.log(error);
              if (error.responseJSON) {
                return _this.errorTextSignUp('No se pudo crear la cuenta');
              } else {
                return _this.errorTextSignUp('No se pudo establecer conexión');
              }
            } else {
              console.log(success);
              Config.setItem('userObject', JSON.stringify(success));
              Config.setItem('headers', JSON.stringify(headers));
              _this.setUserInfo();
              _this.session.signedUp(true);
              $('#shopping-cart .checkout').removeClass('hide');
              $('#shopping-cart .sign-up-banner').removeClass('show');
              $('#sign-up').modal('hide');
              return $('#shopping-cart').sidebar('hide');
            }
          };
        })(this));
      }
    };

    TransactionalPageVM.prototype.resetPassword = function() {
      var $form, data;
      $form = $('.reset-password .form');
      $form.removeClass('error');
      if ($form.form('is valid')) {
        data = {
          email: $form.form('get value', 'email'),
          redirect_url: '/'
        };
        $('.reset-password .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/auth/password", data, (function(_this) {
          return function(error, success, headers) {
            $('.reset-password .green.button').removeClass('loading');
            if (error) {
              $form.addClass('error');
              console.log('An error has ocurred while reseting the password!');
              console.log(error);
              if (error.responseJSON) {
                return $form.form('add errors', error.responseJSON.errors);
              } else {
                return $form.form('add errors', ['No se pudo establecer conexión']);
              }
            } else {
              console.log(success);
              $('.reset-password .green.button').addClass('disabled');
              $('.reset-password .success.segment').transition('fade down');
              return setTimeout((function() {
                return $('.reset-password.modal').modal('hide');
              }), 5000);
            }
          };
        })(this));
      }
    };

    TransactionalPageVM.prototype.hideLoader = function(product) {
      $("#" + product.id + " .image img.loading").hide();
      $("#" + product.id + " .image .loader").hide();
      return $("#" + product.id + " .image img.product").show();
    };

    TransactionalPageVM.prototype.login = function() {
      return LoginService.regularLogin((function(_this) {
        return function(error, success) {
          if (error) {
            return console.log('An error ocurred while trying to login');
          } else {
            _this.setUserInfo();
            $('.login.modal').modal('hide');
            return $('#shopping-cart').sidebar('hide');
          }
        };
      })(this));
    };

    TransactionalPageVM.prototype.loginFB = function() {
      return LoginService.FBLogin((function(_this) {
        return function(error, success) {
          if (error) {
            return console.log('An error ocurred while trying to login to FB');
          } else {
            _this.setUserInfo();
            return $('#shopping-cart').sidebar('hide');
          }
        };
      })(this));
    };

    TransactionalPageVM.prototype.showProduct = function(product) {
      this.selectedProduct = product;
      this.selectedProductCategory(product.subcategoryName);
      this.selectedProductImage(product.image);
      this.selectedProductName(product.name);
      this.selectedProductSize(product.size);
      if (product.description && product.description.startsWith('$')) {
        this.selectedProductDescription(product.desc);
      } else {
        this.selectedProductDescription(product.description);
      }
      this.selectedProductPrice("$" + ((product.frepi_price || product.frepiPrice).toLocaleString()));
      if (this.getProductByID(product.id)) {
        $("#product-desc .ribbon.label").addClass('show');
      }
      return $('#product-desc').modal('show');
    };

    TransactionalPageVM.prototype.setRulesValidation = function() {
      return $.fn.form.settings.rules.isValidQuantity = function(value) {
        return value > 0;
      };
    };

    TransactionalPageVM.prototype.setSizeSidebar = function() {
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

    TransactionalPageVM.prototype.setDOMElems = function() {
      $('.ui.search').search({
        minCharacters: 3,
        error: {
          noResults: 'No hay resultados para la búsqueda'
        },
        apiSettings: {
          url: 'http://ec2-54-68-79-250.us-west-2.compute.amazonaws.com:8080/api/v1/search/products?search={query}',
          onResponse: function(APIResponse) {
            var response;
            response = {
              results: []
            };
            $.each(APIResponse, (function(index, item) {
              var maxResults;
              maxResults = 5;
              if (index > maxResults) {
                return false;
              }
              return response.results.push({
                id: item.id,
                size: item.size,
                name: item.name,
                title: item.name,
                desc: item.description,
                description: "$" + (item.frepi_price.toLocaleString()),
                image: item.image,
                frepiPrice: item.frepi_price
              });
            }));
            return response;
          }
        },
        onSelect: (function(_this) {
          return function(result, response) {
            return _this.showProduct(result);
          };
        })(this)
      });
      $('.ui.dropdown:not(#user-account)').dropdown();
      $('#departments-menu .ui.dropdown').dropdown({
        on: 'hover'
      });
      $('.ui.accordion').accordion();
      $('#shopping-cart').sidebar({
        dimPage: false,
        transition: 'overlay',
        mobileTransition: 'overlay',
        onHide: function() {
          $('#shopping-cart .checkout').removeClass('hide');
          return $('#shopping-cart .sign-up-banner').removeClass('show');
        }
      }).sidebar('attach events', '#store-secondary-navbar .right.menu button', 'show').sidebar('attach events', '#shopping-cart i', 'show');
      $('#product-desc').modal({
        onHidden: function() {
          $('#product-desc form').form('clear');
          $('.modal .input.field').removeClass('show');
          $('.modal .dropdown.field').removeClass('hide');
          return $("#product-desc .ribbon.label").removeClass('show');
        }
      });
      $('.reset-password.modal').modal({
        onHidden: function() {
          $('.reset-password .success.segment').attr('style', 'display: none !important');
          $('.reset-password .green.button').removeClass('disabled');
          return $('.reset-password form').form('clear');
        }
      }).modal('attach events', '.reset.trigger', 'show').modal('attach events', '.reset-password .cancel.button', 'hide');
      $('.login.modal').modal({
        onShow: function() {
          return $('#mobile-menu').sidebar('hide');
        },
        onHide: function() {
          return $('.login.modal form').form('clear');
        }
      }).modal('attach events', '.login.trigger', 'show').modal('attach events', '.login.modal .cancel.button', 'hide');
      $('#sign-up').modal({
        onShow: function() {
          $('#shopping-cart').sidebar('hide');
          return $('#mobile-menu').sidebar('hide');
        },
        onHide: function() {
          return $('#sign-up.modal form').form('clear');
        }
      }).modal('attach events', '.sign-up.trigger', 'show').modal('attach events', '#sign-up.modal .cancel.button', 'hide');
      $('.reset-password .form').form({
        fields: {
          email: {
            identifier: 'email',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner el correo'
              }, {
                type: 'email',
                prompt: 'La dirección de correo no es válida'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
      $('#product-desc form').form({
        fields: {
          quantity: {
            identifier: 'quantity',
            rules: [
              {
                type: 'empty',
                prompt: 'Debes poner la cantidad'
              }, {
                type: 'integer',
                prompt: 'Cantidad no válida'
              }, {
                type: 'isValidQuantity[quantity]',
                prompt: 'Cantidad no válida'
              }
            ]
          },
          quantityDropdown: {
            identifier: 'quantityDropdown',
            rules: [
              {
                type: 'empty',
                prompt: 'Debes poner la cantidad'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
      $('.login.modal .form').form({
        fields: {
          username: {
            identifier: 'username',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner un usuario'
              }, {
                type: 'email',
                prompt: 'La dirección de correo no es válida'
              }
            ]
          },
          password: {
            identifier: 'password',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner una contraseña'
              }, {
                type: 'length[6]',
                prompt: 'La contraseña debe tener por lo menos 6 caracteres'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
      return $('#sign-up .form').form({
        fields: {
          firstName: {
            identifier: 'firstName',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner tus nombres'
              }
            ]
          },
          lastName: {
            identifier: 'lastName',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner tus apellidos'
              }
            ]
          },
          address: {
            identifier: 'address',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner tu dirección'
              }
            ]
          },
          phoneNumber: {
            identifier: 'phoneNumber',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner tu teléfono'
              }
            ]
          },
          email: {
            identifier: 'email',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner tu e-mail'
              }, {
                type: 'email',
                prompt: 'Digitaste un e-mail no válido'
              }
            ]
          },
          password: {
            identifier: 'password',
            rules: [
              {
                type: 'empty',
                prompt: 'Olvidaste poner una contraseña'
              }, {
                type: 'length[6]',
                prompt: 'La contraseña debe tener por lo menos 6 caracteres'
              }
            ]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
    };

    return TransactionalPageVM;

  })();

}).call(this);
