(function() {
  window.NearbyOrdersVM = (function() {
    function NearbyOrdersVM() {
      this.orders = ko.observableArray(currentSession.nearbyOrders);
    }

    return NearbyOrdersVM;

  })();

}).call(this);
