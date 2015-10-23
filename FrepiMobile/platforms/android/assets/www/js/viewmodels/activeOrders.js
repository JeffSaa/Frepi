(function() {
  window.ActiveOrdersVM = (function() {
    function ActiveOrdersVM() {
      console.log('Its here in active Orders');
      this.setOrdersAttributes();
      this.orders = ko.mapping.fromJS(currentSession.activeOrders);
      this.test = ko.observable('MOTOROLA');
    }

    ActiveOrdersVM.prototype.setOrdersAttributes = function() {
      var i, len, order, product, ref, results;
      console.log('Setting order attributes');
      ref = currentSession.activeOrders;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        order = ref[i];
        order.checkedItems = 0;
        results.push((function() {
          var j, len1, ref1, results1;
          ref1 = order.ordersProducts;
          results1 = [];
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            product = ref1[j];
            results1.push(product.checked = false);
          }
          return results1;
        })());
      }
      return results;
    };

    ActiveOrdersVM.prototype.markAsChecked = function(product, order) {
      product.checked(!product.checked());
      if (product.checked()) {
        return order.checkedItems(order.checkedItems() + 1);
      } else {
        return order.checkedItems(order.checkedItems() - 1);
      }
    };

    return ActiveOrdersVM;

  })();

}).call(this);
