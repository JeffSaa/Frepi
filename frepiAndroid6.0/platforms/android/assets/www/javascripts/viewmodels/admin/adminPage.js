(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AdminPageVM = (function() {
    function AdminPageVM() {
      this.setUserInfo = bind(this.setUserInfo, this);
      this.shouldShowError = ko.observable(false);
      this.isLoading = ko.observable(true);
      this.user = JSON.parse(Config.getItem('userObject'));
      this.setDOMElements();
      this.setDOMEventsHandlers();
    }

    AdminPageVM.prototype.logout = function() {
      return RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (function(_this) {
        return function(error, success, headers) {
          if (error) {
            return console.log('An error has ocurred');
          } else {
            Config.destroyLocalStorage();
            return window.location.href = '../login.html';
          }
        };
      })(this));
    };

    AdminPageVM.prototype.setUserInfo = function() {
      var tempUser;
      tempUser = JSON.parse(Config.getItem('userObject'));
      console.log(tempUser);
      return console.log(this.user);
    };

    AdminPageVM.prototype.setPaginationItemsToShow = function(objPage, DOMParent, itemsPerPage) {
      var activePage, lessThanLimit, module, numShownPages, possibleUpperLimit, totalPages;
      if (itemsPerPage == null) {
        itemsPerPage = 10;
      }
      numShownPages = objPage.showablePages().length;
      module = objPage.activePage % 10;
      activePage = module;
      if (activePage === 0) {
        activePage = objPage.showablePages().length;
      }
      lessThanLimit = false;
      if ((objPage.activePage <= objPage.lowerLimit && objPage.activePage !== 1) || objPage.activePage === (objPage.allPages.length - 1)) {
        lessThanLimit = true;
      }
      if (objPage.activePage === objPage.lowerLimit + 1) {
        $(DOMParent + " .pagination .pages .item").removeClass('active');
        $(DOMParent + " .pagination .pages .item:nth-of-type(" + 1. + ")").addClass('active');
        return;
      }
      if (lessThanLimit) {
        if (objPage.activePage === (objPage.allPages.length - 1)) {
          objPage.lowerLimit = (objPage.allPages.length - 1) - activePage;
          objPage.upperLimit = objPage.activePage;
        } else {
          objPage.lowerLimit -= 10;
          objPage.upperLimit = objPage.lowerLimit + 10;
          activePage = 10;
        }
      } else {
        if (module === 1) {
          possibleUpperLimit = objPage.upperLimit + 10;
          objPage.lowerLimit = objPage.activePage === 1 ? 0 : objPage.lowerLimit += 10;
          if (possibleUpperLimit >= objPage.allPages.length) {
            totalPages = objPage.allPages.length - 1;
            if (objPage.activePage === 1) {
              objPage.upperLimit = totalPages < 10 ? totalPages : 10;
            } else {
              objPage.upperLimit = totalPages;
            }
          } else {
            objPage.upperLimit = possibleUpperLimit;
          }
        }
      }
      objPage.showablePages(objPage.allPages.slice(objPage.lowerLimit, objPage.upperLimit));
      $(DOMParent + " .pagination .pages .item").removeClass('active');
      return $(DOMParent + " .pagination .pages .item:nth-of-type(" + activePage + ")").addClass('active');
    };

    AdminPageVM.prototype.setDOMEventsHandlers = function() {
      $('.ui.create.button').on('click', function() {
        return $('.ui.create.modal').modal('show');
      });
      return $('.ui.modal .cancel.button').on('click', function() {
        return $('.ui.modal').modal('hide');
      });
    };

    AdminPageVM.prototype.setDOMElements = function() {
      return $('.ui.modal .dropdown').dropdown();
    };

    return AdminPageVM;

  })();

}).call(this);
