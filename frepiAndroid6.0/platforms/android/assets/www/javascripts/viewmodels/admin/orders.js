(function() {
  var OrdersVM, orders,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  OrdersVM = (function(superClass) {
    extend(OrdersVM, superClass);

    function OrdersVM() {
      this.fetchOrdersPage = bind(this.fetchOrdersPage, this);
      this.showProducts = bind(this.showProducts, this);
      this.showDelete = bind(this.showDelete, this);
      this.deleteOrder = bind(this.deleteOrder, this);
      OrdersVM.__super__.constructor.call(this);
      this.shouldShowError = ko.observable(false);
      this.currentOrders = ko.observableArray();
      this.chosenOrder = {
        id: ko.observable(),
        totalPrice: ko.observable(),
        products: ko.observableArray()
      };
      this.ordersPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.fetchOrders();
      this.setRulesValidation();
      this.setDOMProperties();
    }

    OrdersVM.prototype.deleteOrder = function() {
      $('.delete.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/orders/" + (this.chosenOrder.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            console.log(success);
            _this.currentOrders.remove(function(order) {
              return order.id === _this.chosenOrder.id();
            });
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.modal').modal('hide');
          }
        };
      })(this));
    };

    OrdersVM.prototype.showDelete = function(order) {
      this.chosenOrder.id(order.id);
      return $('.delete.modal').modal('show');
    };

    OrdersVM.prototype.showProducts = function(order) {
      this.chosenOrder.products(order.products);
      this.chosenOrder.totalPrice(order.totalPrice);
      return $('.see.products.modal').modal('show');
    };

    OrdersVM.prototype.setPrevOrderPage = function() {
      var nextPage;
      if (this.ordersPages.activePage === 1) {
        nextPage = this.ordersPages.allPages.length - 1;
      } else {
        nextPage = this.ordersPages.activePage - 1;
      }
      return this.fetchOrdersPage({
        num: nextPage
      });
    };

    OrdersVM.prototype.setNextOrderPage = function() {
      var nextPage;
      if (this.ordersPages.activePage === this.ordersPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.ordersPages.activePage + 1;
      }
      return this.fetchOrdersPage({
        num: nextPage
      });
    };

    OrdersVM.prototype.fetchOrdersPage = function(page) {
      this.ordersPages.activePage = page.num;
      this.setPaginationItemsToShow(this.ordersPages, 'table.orders');
      return this.fetchOrders(page.num);
    };

    OrdersVM.prototype.fetchOrders = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      this.isLoading(true);
      data = {
        page: numPage
      };
      return RESTfulService.makeRequest('GET', "/orders", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            return console.log('An error has ocurred while fetching the orders!');
          } else {
            console.log(success);
            if (_this.ordersPages.allPages.length === 0) {
              totalPages = Math.ceil(headers.totalItems / 10);
              for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                _this.ordersPages.allPages.push({
                  num: i + 1
                });
              }
              _this.ordersPages.activePage = 1;
              _this.ordersPages.lowerLimit = 0;
              _this.ordersPages.upperLimit = totalPages < 10 ? totalPages : 10;
              _this.ordersPages.showablePages(_this.ordersPages.allPages.slice(_this.ordersPages.lowerLimit, _this.ordersPages.upperLimit));
              $("table.orders .pagination .pages .item:first-of-type").addClass('active');
            }
            _this.currentOrders(success);
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    OrdersVM.prototype.getInStoreShopper = function(shoppers) {
      if (shoppers.length > 0) {
        return shoppers[0].firstName + ' ' + shoppers[0].lastName;
      } else {
        return '--';
      }
    };

    OrdersVM.prototype.getDeliveryShopper = function(shoppers) {
      if (shoppers.length > 1) {
        return shoppers[1].firstName + ' ' + shoppers[1].lastName;
      } else {
        return '--';
      }
    };

    OrdersVM.prototype.isOverdue = function(data) {
      var currentDate, expiryTime, newDateTime, orderDate, scheduledDate;
      scheduledDate = data.scheduledDate.split('T')[0];
      expiryTime = data.expiryTime.split('T')[1];
      newDateTime = scheduledDate + 'T' + expiryTime;
      orderDate = moment(newDateTime, moment.ISO_8601);
      currentDate = moment();
      return currentDate.isAfter(orderDate) && data.status !== 'DISPATCHED';
    };

    OrdersVM.prototype.parseDate = function(date) {
      return moment(date, moment.ISO_8601).format('DD/MM/YYYY');
    };

    OrdersVM.prototype.parseTime = function(date) {
      return moment(date, moment.ISO_8601).format('h:mm A');
    };

    OrdersVM.prototype.setRulesValidation = function() {
      var emptyRule;
      emptyRule = {
        type: 'empty',
        prompt: 'No puede estar vacío'
      };
      return $('.create.modal form').form({
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
              emptyRule, {
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

    OrdersVM.prototype.setDOMProperties = function() {
      return $('.create.modal .dropdown').dropdown();
    };

    return OrdersVM;

  })(AdminPageVM);

  orders = new OrdersVM;

  ko.applyBindings(orders);

}).call(this);
