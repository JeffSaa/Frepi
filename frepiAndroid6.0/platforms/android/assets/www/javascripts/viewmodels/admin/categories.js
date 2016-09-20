(function() {
  var CategoriesVM, categories,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  CategoriesVM = (function(superClass) {
    extend(CategoriesVM, superClass);

    function CategoriesVM() {
      this.fetchCategoriesPage = bind(this.fetchCategoriesPage, this);
      this.showDeleteSubcategory = bind(this.showDeleteSubcategory, this);
      this.showDelete = bind(this.showDelete, this);
      this.showUpdateSubcategory = bind(this.showUpdateSubcategory, this);
      this.showUpdate = bind(this.showUpdate, this);
      this.deleteSubcategory = bind(this.deleteSubcategory, this);
      this.deleteCategory = bind(this.deleteCategory, this);
      CategoriesVM.__super__.constructor.call(this);
      this.shouldShowCategoriesAlert = ko.observable(true);
      this.cateogoriesAlertText = ko.observable();
      this.currentCategories = ko.observableArray();
      this.currentSubcategories = ko.observableArray();
      this.chosenCategory = {
        id: ko.observable(),
        name: ko.observable()
      };
      this.chosenSubcategory = {
        id: ko.observable(),
        categoryId: ko.observable(),
        name: ko.observable()
      };
      this.categoriesPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.fetchCategories();
      this.setRulesValidation();
      this.setDOMProperties();
    }

    CategoriesVM.prototype.createCategory = function() {
      var $form, data;
      $form = $('.create.category.modal form');
      data = {
        name: $form.form('get value', 'name')
      };
      if ($form.form('is valid')) {
        $('.create.category.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/categories", data, (function(_this) {
          return function(error, success, headers) {
            $('.create.category.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the category.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              _this.currentCategories.push(success);
              return $('.create.category.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    CategoriesVM.prototype.createSubcategory = function() {
      var $form, categoryId, data;
      $form = $('.create.subcategory.modal form');
      categoryId = $form.form('get value', 'categoryID');
      data = {
        name: $form.form('get value', 'name'),
        category_id: categoryId
      };
      if ($form.form('is valid')) {
        $('.create.subcategory.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('POST', "/categories/" + categoryId + "/subcategories", data, (function(_this) {
          return function(error, success, headers) {
            $('.create.subcategory.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the shopper.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              _this.currentSubcategories.push(success);
              return $('.create.subcategory.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    CategoriesVM.prototype.updateCategory = function() {
      var $form, data;
      $form = $('.edit.category.modal form');
      data = {
        name: $form.form('get value', 'name')
      };
      if ($form.form('is valid')) {
        $('.edit.category.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('PUT', "/categories/" + (this.chosenCategory.id()), data, (function(_this) {
          return function(error, success, headers) {
            $('.edit.category.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the admin.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              $('.edit.category.modal').modal('hide');
              return _this.fetchCategories();
            }
          };
        })(this));
      }
    };

    CategoriesVM.prototype.updateSubcategory = function() {
      var $form, data;
      $form = $('.edit.subcategory.modal form');
      data = {
        name: $form.form('get value', 'name'),
        category_id: $form.form('get value', 'categoryID')
      };
      if ($form.form('is valid')) {
        $('.edit.subcategory.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('PUT', "/categories/" + (this.chosenSubcategory.categoryId()) + "/subcategories/" + (this.chosenSubcategory.id()), data, (function(_this) {
          return function(error, success, headers) {
            $('.edit.subcategory.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the creation of the admin.');
              return console.log(error);
            } else {
              console.log(success);
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              $('.edit.subcategory.modal').modal('hide');
              return _this.fetchSubcategories(_this.chosenSubcategory.categoryId());
            }
          };
        })(this));
      }
    };

    CategoriesVM.prototype.deleteCategory = function() {
      $('.delete.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/categories/" + (this.chosenCategory.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            console.log(success);
            _this.currentCategories.remove(function(shopper) {
              return shopper.id === _this.chosenCategory.id();
            });
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.modal').modal('hide');
          }
        };
      })(this));
    };

    CategoriesVM.prototype.deleteSubcategory = function() {
      $('.delete.subcategory.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/categories/" + (this.chosenSubcategory.categoryId()) + "/subcategories/" + (this.chosenSubcategory.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.subcategory.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            console.log(success);
            _this.currentSubcategories.remove(function(shopper) {
              return shopper.id === _this.chosenSubcategory.id();
            });
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.subcategory.modal').modal('hide');
          }
        };
      })(this));
    };

    CategoriesVM.prototype.showUpdate = function(category) {
      this.chosenCategory.id(category.id);
      $('.edit.category form').form('set values', {
        name: category.name
      });
      return $('.edit.category.modal').modal('show');
    };

    CategoriesVM.prototype.showUpdateSubcategory = function(subcategory) {
      this.chosenSubcategory.id(subcategory.id);
      this.chosenSubcategory.name(subcategory.name);
      this.chosenSubcategory.categoryId(subcategory.categoryId);
      $('.edit.subcategory form').form('set values', {
        name: subcategory.name,
        categoryID: subcategory.categoryId
      });
      return $('.edit.subcategory.modal').modal('show');
    };

    CategoriesVM.prototype.showDelete = function(category) {
      this.chosenCategory.id(category.id);
      this.chosenCategory.name(category.name);
      return $('.delete.category.modal').modal('show');
    };

    CategoriesVM.prototype.showDeleteSubcategory = function(subcategory) {
      this.chosenSubcategory.id(subcategory.id);
      this.chosenSubcategory.name(subcategory.name);
      this.chosenSubcategory.categoryId(subcategory.categoryId);
      return $('.delete.subcategory.modal').modal('show');
    };

    CategoriesVM.prototype.setPrevShopperPage = function() {
      var nextPage;
      if (this.categoriesPages.activePage === 1) {
        nextPage = this.categoriesPages.allPages.length - 1;
      } else {
        nextPage = this.categoriesPages.activePage - 1;
      }
      return this.fetchCategoriesPage({
        num: nextPage
      });
    };

    CategoriesVM.prototype.setNextShopperPage = function() {
      var nextPage;
      if (this.categoriesPages.activePage === this.categoriesPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.categoriesPages.activePage + 1;
      }
      return this.fetchCategoriesPage({
        num: nextPage
      });
    };

    CategoriesVM.prototype.fetchCategoriesPage = function(page) {
      this.categoriesPages.activePage = page.num;
      this.setPaginationItemsToShow(this.categoriesPages, 'table.categories');
      return this.fetchCategories(page.num);
    };

    CategoriesVM.prototype.fetchCategories = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      this.isLoading(true);
      data = {
        page: numPage,
        per_page: 30
      };
      return RESTfulService.makeRequest('GET', "/categories", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the categories!');
            _this.shouldShowCategoriesAlert(true);
            return _this.cateogoriesAlertText('Hubo un problema buscando la información de los categories');
          } else {
            console.log(success);
            if (success.length > 0) {
              if (_this.categoriesPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 30);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  _this.categoriesPages.allPages.push({
                    num: i + 1
                  });
                }
                _this.categoriesPages.activePage = 1;
                _this.categoriesPages.lowerLimit = 0;
                _this.categoriesPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.categoriesPages.showablePages(_this.categoriesPages.allPages.slice(_this.categoriesPages.lowerLimit, _this.categoriesPages.upperLimit));
                $("table.categories .pagination .pages .item:first-of-type").addClass('active');
              }
              _this.currentCategories(success);
              _this.shouldShowCategoriesAlert(false);
            } else {
              _this.shouldShowCategoriesAlert(true);
              _this.cateogoriesAlertText('No hay categories');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    CategoriesVM.prototype.fetchSubcategories = function(categoryID) {
      $('.subcategories .dropdown').addClass('loading');
      return RESTfulService.makeRequest('GET', "/categories/" + categoryID + "/subcategories", '', (function(_this) {
        return function(error, success, headers) {
          $('.subcategories .dropdown').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            return _this.currentSubcategories(success);
          }
        };
      })(this));
    };

    CategoriesVM.prototype.setRulesValidation = function() {
      var emptyRule;
      emptyRule = {
        type: 'empty',
        prompt: 'No puede estar vacío'
      };
      return $('.ui.modal form').form({
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
              {
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

    CategoriesVM.prototype.setDOMProperties = function() {
      $('.ui.modal').modal({
        onHidden: function() {
          return $('.ui.modal form').form('clear');
        }
      });
      return $('.subcategories .dropdown').dropdown({
        onChange: (function(_this) {
          return function(value, text, $selectedItem) {
            return _this.fetchSubcategories(value);
          };
        })(this)
      });
    };

    CategoriesVM.prototype.setDOMEventsHandlers = function() {
      $('.ui.create.category.button').on('click', function() {
        return $('.ui.create.category.modal').modal('show');
      });
      $('.ui.create.subcategory.button').on('click', function() {
        return $('.ui.create.subcategory.modal').modal('show');
      });
      return $('.ui.modal .cancel.button').on('click', function() {
        return $('.ui.modal').modal('hide');
      });
    };

    return CategoriesVM;

  })(AdminPageVM);

  categories = new CategoriesVM;

  ko.applyBindings(categories);

}).call(this);
