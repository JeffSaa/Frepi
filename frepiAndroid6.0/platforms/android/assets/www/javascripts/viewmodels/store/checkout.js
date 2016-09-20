(function() {
  var CheckoutVM, checkout,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  CheckoutVM = (function() {
    function CheckoutVM() {
      this.setAvailableDeliveryDateTime = bind(this.setAvailableDeliveryDateTime, this);
      this.setPaymentMethod = bind(this.setPaymentMethod, this);
      this.setExpireHour = bind(this.setExpireHour, this);
      this.setHours = bind(this.setHours, this);
      this.session = {
        currentStore: null,
        currentSucursal: null,
        currentDeparmentID: null,
        categories: ko.observableArray(),
        signedUp: ko.observable(),
        sucursals: ko.observableArray(),
        currentOrder: {
          numberProducts: ko.observable(),
          products: ko.observableArray(),
          price: ko.observable()
        }
      };
      this.availableDateTime = null;
      this.user = JSON.parse(Config.getItem('userObject'));
      this.headerMessage = ko.observable('Confirma tu orden');
      this.orderGenerated = ko.observable(false);
      this.selectedDay = ko.observable();
      this.selectedDate = ko.observable();
      this.selectedHour = ko.observable();
      this.selectedExpiredHour = ko.observable();
      this.availableDays = ko.observableArray();
      this.availableHours = ko.observableArray();
      this.paymentTypes = ko.observableArray([
        {
          text: 'Efectivo',
          value: 'CASH'
        }, {
          text: 'Datáfono',
          value: 'PAYMENT_TERMINAL'
        }
      ]);
      this.userName = ko.observable();
      this.comment = ko.observable();
      this.selectedPaymentMethod = ko.observable();
      this.address = ko.observable(this.user.address);
      this.phoneNumber = ko.observable(this.user.phoneNumber || this.user.phone_number);
      this.setDOMElements();
      this.setExistingSession();
      this.setSizeButtons();
      this.setAvailableDeliveryDateTime();
      this.finalOrderPrice = ko.computed((function(_this) {
        return function() {
          var finalPrice;
          finalPrice = 0;
          if (_this.session.currentOrder.price() > 80000 && _this.user.discount > 0) {
            finalPrice = _this.session.currentOrder.price() - _this.user.discount;
          } else {
            finalPrice = _this.session.currentOrder.price();
          }
          return finalPrice;
        };
      })(this));
    }

    CheckoutVM.prototype.seeDeliveryRight = function() {
      $('.form .field').removeClass('error');
      $('#products-icon').removeClass('active');
      $('#delivery-icon').addClass('active');
      $('#products').transition('fade right');
      return $('#delivery').transition('fade left');
    };

    CheckoutVM.prototype.seeDeliveryLeft = function() {
      $('#confirm-icon').removeClass('active');
      $('#delivery-icon').addClass('active');
      $('#confirm').transition('fade left');
      return $('#delivery').transition('fade right');
    };

    CheckoutVM.prototype.seeProducts = function() {
      $('#delivery-icon').removeClass('active');
      $('#products-icon').addClass('active');
      $('#products').transition('fade right');
      return $('#delivery').transition('fade left');
    };

    CheckoutVM.prototype.seeConfirm = function() {
      var isInvalidPhone;
      isInvalidPhone = !this.phoneNumber() || !this.isValidPhoneNumber(this.phoneNumber());
      if (!!this.selectedDay() && !!this.selectedHour() && !!this.address() && !!this.selectedPaymentMethod() && !isInvalidPhone) {
        $('#delivery-icon').removeClass('active');
        $('#confirm-icon').addClass('active');
        $('#delivery').transition('fade right');
        return $('#confirm').transition('fade left');
      } else {
        if (!this.address()) {
          $('.address.field').addClass('error');
        }
        if (!this.selectedDay()) {
          $('.date.field').addClass('error');
        }
        if (!this.selectedHour()) {
          $('.time.field').addClass('error');
        }
        if (!this.selectedPaymentMethod()) {
          $('.payment.field').addClass('error');
        }
        if (isInvalidPhone) {
          return $('.phone.field').addClass('error');
        }
      }
    };

    CheckoutVM.prototype.logout = function() {
      return RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (function(_this) {
        return function(error, success, headers) {
          if (error) {

          } else {
            Config.destroyLocalStorage();
            return window.location.href = 'store/index.html';
          }
        };
      })(this));
    };

    CheckoutVM.prototype.cancel = function() {
      return window.location.href = 'store/index.html';
    };

    CheckoutVM.prototype.generate = function() {
      var data, j, len, product, productsToSend, ref;
      productsToSend = [];
      ref = this.session.currentOrder.products();
      for (j = 0, len = ref.length; j < len; j++) {
        product = ref[j];
        productsToSend.push({
          comment: product.comment,
          id: product.id,
          quantity: product.quantity
        });
      }
      data = {
        address: this.address(),
        comment: this.comment(),
        telephone: this.phoneNumber(),
        payment: this.selectedPaymentMethod().value,
        products: productsToSend,
        arrivalTime: this.selectedHour(),
        scheduledDate: this.selectedDate(),
        expiryTime: this.selectedExpiredHour()
      };
      $('.generate.button').addClass('loading');
      return RESTfulService.makeRequest('POST', "/users/" + this.user.id + "/orders", data, (function(_this) {
        return function(error, success, headers) {
          $('.generate.button').removeClass('loading');
          if (error) {
            return _this.headerMessage('Ha ocurrido un error generando la orden. Intenta más tarde.');
          } else {
            _this.session.currentOrder.numberProducts('0 items');
            _this.session.currentOrder.products([]);
            _this.session.currentOrder.price(0.0);
            _this.saveSession();
            return $('.successful.modal').modal('show');
          }
        };
      })(this));
    };

    CheckoutVM.prototype.goToProfile = function() {
      Config.setItem('showOrders', 'false');
      return window.location.href = 'store/profile.html';
    };

    CheckoutVM.prototype.goToOrders = function() {
      Config.setItem('showOrders', 'true');
      return window.location.href = 'store/profile.html';
    };

    CheckoutVM.prototype.setDOMElements = function() {
      $('#departments-menu').sidebar({
        transition: 'overlay',
        mobileTransition: 'overlay'
      }).sidebar('attach events', '#store-secondary-navbar .basic.button', 'show');
      $('#mobile-menu').sidebar('setting', 'transition', 'overlay').sidebar('setting', 'mobileTransition', 'overlay').sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show');
      $('.time.field').popup({
        inline: true
      });
      return $('.successful.modal').modal({
        onHidden: function() {
          return window.location.href = 'store/index.html';
        }
      });
    };

    CheckoutVM.prototype.inputGotFocus = function(data, event) {
      return $(event.target.parentElement).removeClass('error');
    };

    CheckoutVM.prototype.isValidPhoneNumber = function(phoneNumber) {
      return phoneNumber.length > 6 && !(phoneNumber.match(/[^\s|\d]/g));
    };

    CheckoutVM.prototype.setHours = function() {
      $('.date.field').removeClass('error');
      if (!!this.selectedDay()) {
        this.availableHours(this.selectedDay().availableHours);
        this.selectedDate(this.selectedDay().date);
        if (this.selectedDay().availableHours.length === 0) {
          return $('.hours.dropdown').addClass('disabled');
        } else {
          return $('.hours.dropdown').removeClass('disabled');
        }
      } else {
        this.availableHours([]);
        return this.selectedDate('');
      }
    };

    CheckoutVM.prototype.setExpireHour = function() {
      var expireHour;
      $('.time.field').removeClass('error');
      if (!!this.selectedHour()) {
        expireHour = moment(this.selectedHour(), 'H:mm').add(1, 'hours');
        return this.selectedExpiredHour(expireHour.format('H:mm'));
      }
    };

    CheckoutVM.prototype.setPaymentMethod = function() {
      return $('.payment.field').removeClass('error');
    };

    CheckoutVM.prototype.setAvailableDeliveryDateTime = function() {
      var aftertomorrow, today, tomorrow;
      if (moment().hours() < 17) {
        if (moment().hours() > 7) {
          today = moment().add(1, 'hours').minutes(0);
        } else {
          today = moment().hours(7).minutes(0);
        }
      } else {
        today = moment().hours(moment().hours()).minutes(0);
      }
      tomorrow = moment().add(1, 'days').hours(7).minutes(0);
      aftertomorrow = moment().add(2, 'days').hours(7).minutes(0);
      this.availableDateTime = {
        today: {
          date: today.format('YYYY-MM-DD'),
          availableHours: this.generateAvailableHours(today)
        },
        tomorrow: {
          date: tomorrow.format('YYYY-MM-DD'),
          availableHours: this.generateAvailableHours(tomorrow)
        },
        aftertomorrow: {
          date: aftertomorrow.format('YYYY-MM-DD'),
          availableHours: this.generateAvailableHours(aftertomorrow)
        }
      };
      return this.availableDays([this.availableDateTime.today, this.availableDateTime.tomorrow, this.availableDateTime.aftertomorrow]);
    };

    CheckoutVM.prototype.generateAvailableHours = function(startHour) {
      var difference, endHour, hours, i, j, ref;
      endHour = moment(startHour.format('YYYY-MM-DD'), 'YYYY-MM-DD').hours(16).minutes(0);
      hours = [];
      difference = endHour.diff(startHour, 'minutes');
      if (difference > 0) {
        for (i = j = 0, ref = difference / 60; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          hours.push(startHour.add(1, 'hours').format('HH:00'));
        }
      }
      return hours;
    };

    CheckoutVM.prototype.saveSession = function() {
      var session;
      session = {
        categories: this.session.categories(),
        currentStore: ko.mapping.toJS(this.session.currentStore),
        currentSucursal: ko.mapping.toJS(this.session.currentSucursal),
        currentDeparmentID: this.session.currentDeparmentID,
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

    CheckoutVM.prototype.setExistingSession = function() {
      var order, session;
      session = Config.getItem('currentSession');
      if (session) {
        this.userName(this.user.name.split(' ')[0]);
        order = JSON.parse(Config.getItem('orderToPay'));
        session = JSON.parse(Config.getItem('currentSession'));
        this.session.currentStore = ko.mapping.fromJS(session.currentStore);
        this.session.currentSucursal = ko.mapping.fromJS(session.currentSucursal);
        this.session.currentDeparmentID = session.currentDeparmentID;
        this.session.categories(session.categories);
        this.session.sucursals(session.sucursals);
        this.session.signedUp(session.signedUp);
        this.session.currentOrder.numberProducts(order.numberProducts);
        this.session.currentOrder.products(order.products);
        this.session.currentOrder.price(order.price);
        return this.session.currentOrder.sucursalId = session.currentOrder.sucursalId;
      }
    };

    CheckoutVM.prototype.setSizeButtons = function() {
      if ($(window).width() < 480) {
        $('.ui.buttons').addClass('tiny');
        $('.ui.labeled.button').addClass('tiny');
      } else {
        $('.ui.buttons').removeClass('tiny');
        $('.ui.labeled.button').removeClass('tiny');
      }
      return $(window).resize(function() {
        if ($(window).width() < 480) {
          $('.ui.buttons').addClass('tiny');
          return $('.ui.labeled.button').addClass('tiny');
        } else {
          $('.ui.buttons').removeClass('tiny');
          return $('.ui.labeled.button').removeClass('tiny');
        }
      });
    };

    return CheckoutVM;

  })();

  RouteValidator.checkUser();

  RouteValidator.checkCart();

  checkout = new CheckoutVM;

  ko.applyBindings(checkout);

}).call(this);
