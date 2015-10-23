(function() {
  window.MasterVM = (function() {
    function MasterVM() {
      this.target = ko.observable('login');
    }

    return MasterVM;

  })();

  $(document).ready(function() {
    var router;
    window.MasterVM = new MasterVM;
    ko.components.register('login', {
      viewModel: {
        createViewModel: function(params, componentInfo) {
          return new LoginVM;
        }
      },
      template: {
        require: 'text!../components/login.html'
      }
    });
    ko.components.register('home', {
      viewModel: {
        createViewModel: function(params, componentInfo) {
          return new HomeVM;
        }
      },
      template: {
        require: 'text!../components/home.html'
      }
    });
    ko.components.register('nearby', {
      viewModel: {
        createViewModel: function(params, componentInfo) {
          return new NearbyOrdersVM;
        }
      },
      template: {
        require: 'text!../components/nearbyOrders.html'
      }
    });
    ko.components.register('active', {
      viewModel: {
        createViewModel: function(params, componentInfo) {
          return new ActiveOrdersVM;
        }
      },
      template: {
        require: 'text!../components/activeOrders.html'
      }
    });
    ko.applyBindings(MasterVM);
    router = new FrepiRouter();
    return Backbone.history.start();
  });

}).call(this);
