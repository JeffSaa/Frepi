(function() {
  window.ShopperSessionVM = (function() {
    function ShopperSessionVM(user) {
      this.user = user;
      this.activeOrders = ko.observableArray();
      this.nearbyOrders = ko.observableArray();
    }

    return ShopperSessionVM;

  })();

}).call(this);
