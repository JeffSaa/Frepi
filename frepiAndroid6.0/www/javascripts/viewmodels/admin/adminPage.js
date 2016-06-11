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

    AdminPageVM.prototype.setPaginationItemsToShow = function(objPage, DOMParent) {
      var activePage, midPoint, module, moduleFive, numShownPages, possibleUpperLimit;
      numShownPages = objPage.showablePages().length;
      module = objPage.activePage % 10;
      moduleFive = module % 5;
      if (module === 0 || moduleFive === 0) {
        activePage = 5;
      } else {
        if (moduleFive === 1 && objPage.activePage !== 1) {
          activePage = 6;
        } else {
          activePage = numShownPages < 10 ? module : moduleFive;
        }
      }
      midPoint = parseInt((objPage.lowerLimit + objPage.upperLimit) / 2);
      if (!(numShownPages < 10)) {
        if (objPage.activePage > midPoint) {
          objPage.lowerLimit = midPoint;
          possibleUpperLimit = objPage.lowerLimit + 10;
          if (possibleUpperLimit < objPage.allPages.length) {
            objPage.upperLimit = possibleUpperLimit;
          } else {
            objPage.upperLimit = objPage.allPages.length - 1;
          }
        }
      }
      if ((objPage.activePage - 1) === objPage.lowerLimit && (objPage.activePage - 1) !== 0) {
        objPage.upperLimit = numShownPages < 10 ? objPage.showablePages()[4].num : midPoint;
        objPage.lowerLimit = objPage.upperLimit - 10;
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
