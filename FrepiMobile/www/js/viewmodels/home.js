(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.HomeVM = (function() {
    function HomeVM() {
      this.initGeolocation = bind(this.initGeolocation, this);
      this.getCurrentLocation = bind(this.getCurrentLocation, this);
      this.activeOrders = ko.observableArray();
      this.nearbyOrders = ko.observableArray();
      this.initGeolocation();
      this.fetchActiveOrders();
    }

    HomeVM.prototype.confirmOrder = function() {
      console.log('entra');
      return $('#confirmation').openModal();
    };

    HomeVM.prototype.fetchActiveOrders = function() {
      return RESTfulService.makeRequest('GET', "/shoppers/" + currentSession.user.id + "/orders", "", (function(_this) {
        return function(error, success, headers) {
          console.log('Fetching shopper active orders...');
          if (error) {
            return console.log('Orders couldnt be fetched');
          } else {
            console.log(success);
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            currentSession.activeOrders = success;
            _this.activeOrders(success);
            console.log(_this.activeOrders());
            return console.log('ACTIVE ORDERS FETCHING DONE');
          }
        };
      })(this));
    };

    HomeVM.prototype.fetchNearbyOrders = function(currentLocation) {
      console.log(currentLocation);
      return RESTfulService.makeRequest('GET', '/orders', currentLocation, (function(_this) {
        return function(error, success, headers) {
          console.log('Fetching nearby orders by location...');
          if (error) {
            console.log('Nearby orders couldnt be fetched');
            return console.log(error);
          } else {
            console.log(success);
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            currentSession.nearbyOrders = success;
            _this.nearbyOrders(success);
            return console.log('NEARBY ORDERS FETCHING DONE');
          }
        };
      })(this));
    };

    HomeVM.prototype.getCurrentLocation = function(position) {
      var currentLocation;
      console.log('Getting current location...');
      currentLocation = {};
      currentLocation.latitude = position.coords.latitude;
      currentLocation.longitude = position.coords.longitude;
      currentSession.location = currentLocation;
      return this.fetchNearbyOrders(currentLocation);
    };

    HomeVM.prototype.initGeolocation = function() {
      console.log('Initializing geolocation...');
      if (navigator.geolocation) {
        return navigator.geolocation.getCurrentPosition(this.getCurrentLocation);
      } else {
        return alert("Browser doesn't support geolocation");
      }
    };

    return HomeVM;

  })();

}).call(this);
