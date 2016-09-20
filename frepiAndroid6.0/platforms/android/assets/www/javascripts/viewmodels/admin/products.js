(function() {
  var ProductsVM, products,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ProductsVM = (function(superClass) {
    extend(ProductsVM, superClass);

    function ProductsVM() {
      this.uploadProduct = bind(this.uploadProduct, this);
      this.editProduct = bind(this.editProduct, this);
      this.uploadImage = bind(this.uploadImage, this);
      this.setAWSCredentials = bind(this.setAWSCredentials, this);
      this.previewImage = bind(this.previewImage, this);
      this.searchProduct = bind(this.searchProduct, this);
      this.fetchSubcategories = bind(this.fetchSubcategories, this);
      this.fetchProductsPage = bind(this.fetchProductsPage, this);
      this.showDelete = bind(this.showDelete, this);
      this.showUpdate = bind(this.showUpdate, this);
      this.deleteProduct = bind(this.deleteProduct, this);
      this.updateProduct = bind(this.updateProduct, this);
      ProductsVM.__super__.constructor.call(this);
      this.AWSBucket = null;
      this.currentProduct = null;
      this.currentUniqueID = null;
      this.shouldSetProductInfo = true;
      this.fileHasBeenUploaded = false;
      this.previewingImageHasChanged = false;
      this.productsAlertText = ko.observable();
      this.shouldShowProductsAlert = ko.observable(true);
      this.currentProducts = ko.observableArray();
      this.availableSucursals = ko.observableArray();
      this.availableCategories = ko.observableArray();
      this.availableSubcategories = ko.observableArray();
      this.chosenProduct = {
        id: ko.observable(),
        iva: ko.observable(),
        image: ko.observable(),
        name: ko.observable(),
        size: ko.observable(),
        sucursalID: ko.observable(),
        frepiPrice: ko.observable(),
        storePrice: ko.observable(),
        description: ko.observable(),
        subcategoryID: ko.observable()
      };
      this.productsPages = {
        allPages: [],
        activePage: 0,
        lowerLimit: 0,
        upperLimit: 0,
        showablePages: ko.observableArray()
      };
      this.fetchProducts();
      this.setDOMProperties();
      this.setAWSCredentials();
      this.setRulesValidation();
    }

    ProductsVM.prototype.createProduct = function() {
      var $form, data;
      $form = $('.create.modal form');
      data = {
        iva: $form.form('get value', 'iva'),
        name: $form.form('get value', 'name'),
        size: $form.form('get value', 'size'),
        frepiPrice: $form.form('get value', 'frepiPrice'),
        storePrice: $form.form('get value', 'storePrice'),
        description: $form.form('get value', 'description'),
        subcategoryId: $form.form('get value', 'subcategoryID'),
        image: 'http://s3-sa-east-1.amazonaws.com/frepi/products/' + this.currentUniqueID
      };
      console.log(data);
      if ($form.form('is valid')) {
        return RESTfulService.makeRequest('POST', "/stores/1/sucursals/" + ($form.form('get value', 'sucursalID')) + "/products", data, (function(_this) {
          return function(error, success, headers) {
            $('.create.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the authentication.');
              return console.log(error);
            } else {
              if (headers.accessToken) {
                Config.setItem('headers', JSON.stringify(headers));
              }
              _this.currentProducts.push(success);
              return $('.create.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    ProductsVM.prototype.updateProduct = function() {
      var $form, data;
      $form = $('.update.modal form');
      data = {
        iva: $form.form('get value', 'iva'),
        name: $form.form('get value', 'name'),
        size: $form.form('get value', 'size'),
        frepiPrice: $form.form('get value', 'frepiPrice'),
        storePrice: $form.form('get value', 'storePrice'),
        description: $form.form('get value', 'description'),
        subcategoryId: $form.form('get value', 'subcategoryID')
      };
      if (this.previewingImageHasChanged) {
        data.image = 'http://s3-sa-east-1.amazonaws.com/frepi/products/' + this.currentUniqueID;
      }
      console.log(data);
      if ($form.form('is valid')) {
        $('.update.modal form .green.button').addClass('loading');
        return RESTfulService.makeRequest('PUT', "/stores/1/sucursals/" + (this.chosenProduct.sucursalID()) + "/products/" + (this.chosenProduct.id()), data, (function(_this) {
          return function(error, success, headers) {
            $('.update.modal form .green.button').removeClass('loading');
            if (error) {
              console.log('An error has ocurred in the product update.');
              return console.log(error);
            } else {
              _this.shouldSetProductInfo = true;
              _this.fetchProducts(_this.productsPages.activePage);
              return $('.update.modal').modal('hide');
            }
          };
        })(this));
      }
    };

    ProductsVM.prototype.deleteProduct = function() {
      $('.delete.modal .green.button').addClass('loading');
      return RESTfulService.makeRequest('DELETE', "/stores/1/sucursals/" + (this.chosenProduct.sucursalID()) + "/products/" + (this.chosenProduct.id()), '', (function(_this) {
        return function(error, success, headers) {
          $('.delete.modal .green.button').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            _this.currentProducts.remove(function(product) {
              return product.id === _this.chosenProduct.id();
            });
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return $('.delete.modal').modal('hide');
          }
        };
      })(this));
    };

    ProductsVM.prototype.generateUniqueID = function() {
      var asciiCode, idstr;
      idstr = String.fromCharCode(Math.floor((Math.random() * 25) + 65));
      while (true) {
        asciiCode = Math.floor((Math.random() * 42) + 48);
        if (asciiCode < 58 || asciiCode > 64) {
          idstr += String.fromCharCode(asciiCode);
        }
        if (!(idstr.length < 32)) {
          break;
        }
      }
      return idstr;
    };

    ProductsVM.prototype.showUpdate = function(product) {
      this.chosenProduct.id(product.id);
      this.chosenProduct.iva(product.iva);
      this.chosenProduct.size(product.size);
      this.chosenProduct.description(product.description);
      this.chosenProduct.name(product.name);
      this.chosenProduct.sucursalID(product.sucursalID || product.sucursal.id);
      this.currentProduct = product;
      return $('.update.modal').modal('show');
    };

    ProductsVM.prototype.setProductInfo = function() {
      console.log('Setting info');
      this.chosenProduct.image(this.currentProduct.image);
      console.log(this.currentProduct);
      return $('.update.modal form').form('set values', {
        name: this.currentProduct.name,
        size: this.currentProduct.size,
        iva: this.currentProduct.iva,
        frepiPrice: this.currentProduct.frepiPrice,
        storePrice: this.currentProduct.storePrice,
        sucursalID: this.currentProduct.sucursal.id,
        description: this.currentProduct.description,
        subcategoryID: this.currentProduct.subcategory.id,
        categoryID: this.currentProduct.subcategory.categoryId
      });
    };

    ProductsVM.prototype.showDelete = function(product) {
      this.chosenProduct.id(product.id);
      this.chosenProduct.name(product.name);
      this.chosenProduct.sucursalID(product.sucursal.id);
      return $('.delete.modal').modal('show');
    };

    ProductsVM.prototype.setPrevProductPage = function() {
      var nextPage;
      if (this.productsPages.activePage === 1) {
        nextPage = this.productsPages.allPages.length - 1;
      } else {
        nextPage = this.productsPages.activePage - 1;
      }
      return this.fetchProductsPage({
        num: nextPage
      });
    };

    ProductsVM.prototype.setNextProductPage = function() {
      var nextPage;
      if (this.productsPages.activePage === this.productsPages.allPages.length - 1) {
        nextPage = 1;
      } else {
        nextPage = this.productsPages.activePage + 1;
      }
      return this.fetchProductsPage({
        num: nextPage
      });
    };

    ProductsVM.prototype.fetchProductsPage = function(page) {
      this.productsPages.activePage = page.num;
      this.setPaginationItemsToShow(this.productsPages, 'table.products');
      return this.fetchProducts(page.num);
    };

    ProductsVM.prototype.fetchProducts = function(numPage) {
      var data;
      if (numPage == null) {
        numPage = 1;
      }
      this.isLoading(true);
      data = {
        page: numPage,
        per_page: 30
      };
      return RESTfulService.makeRequest('GET', "/administrator/products", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the products!');
            _this.shouldShowProductsAlert(true);
            return _this.productsAlertText('Hubo un problema buscando la información de los productos');
          } else {
            _this.shouldShowProductsAlert(false);
            console.log('After fetching products');
            if (success.length > 0) {
              _this.shouldShowProductsAlert(false);
              if (_this.productsPages.allPages.length === 0) {
                totalPages = Math.ceil(headers.totalItems / 30);
                for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                  _this.productsPages.allPages.push({
                    num: i + 1
                  });
                }
                _this.productsPages.activePage = 1;
                _this.productsPages.lowerLimit = 0;
                _this.productsPages.upperLimit = totalPages < 10 ? totalPages : 10;
                _this.productsPages.showablePages(_this.productsPages.allPages.slice(_this.productsPages.lowerLimit, _this.productsPages.upperLimit));
                $("table.products .pagination .pages .item:first-of-type").addClass('active');
              }
              _this.currentProducts(success);
            } else {
              _this.shouldShowProductsAlert(true);
              _this.productsAlertText('No hay productos');
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    ProductsVM.prototype.fetchCategories = function() {
      return RESTfulService.makeRequest('GET', "/categories", '', (function(_this) {
        return function(error, success, headers) {
          if (error) {
            return console.log('An error has ocurred while fetching the categories!');
          } else {
            _this.availableCategories(success);
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return _this.fetchSubcategories();
          }
        };
      })(this));
    };

    ProductsVM.prototype.fetchSubcategories = function() {
      var $currentForm, categoryID;
      $currentForm = $('.create.modal').modal('is active') ? $('.create.modal form') : $('.update.modal form');
      categoryID = $currentForm.form('get value', 'categoryID') || this.currentProduct.subcategory.categoryId;
      $('.ui.modal .subcategory.dropdown').addClass('loading');
      return RESTfulService.makeRequest('GET', "/categories/" + categoryID + "/subcategories", '', (function(_this) {
        return function(error, success, headers) {
          $('.ui.modal .subcategory.dropdown').removeClass('loading');
          if (error) {
            return console.log('An error has ocurred while fetching the subcategories!');
          } else {
            _this.availableSubcategories(success);
            if (_this.shouldSetProductInfo && $('.update.modal').modal('is active')) {
              console.log("It's here setting the info");
              setTimeout((function() {
                return _this.setProductInfo();
              }), 100);
              return _this.shouldSetProductInfo = false;
            }
          }
        };
      })(this));
    };

    ProductsVM.prototype.fetchSucursals = function() {
      return RESTfulService.makeRequest('GET', "/stores/1/sucursals", {
        page: 1,
        perPage: 25
      }, (function(_this) {
        return function(error, success, headers) {
          if (error) {
            return console.log('An error has ocurred while updating the user!');
          } else {
            _this.availableSucursals(success);
            if (headers.accessToken) {
              Config.setItem('headers', JSON.stringify(headers));
            }
            return _this.fetchCategories();
          }
        };
      })(this));
    };

    ProductsVM.prototype.setRulesValidation = function() {
      var emptyRule;
      emptyRule = {
        type: 'empty',
        prompt: 'No puede estar vacío'
      };
      return $('.create.modal form, .update.modal form').form({
        fields: {
          name: {
            identifier: 'name',
            rules: [emptyRule]
          },
          sucursal: {
            identifier: 'sucursal',
            rules: [emptyRule]
          },
          size: {
            identifier: 'size',
            rules: [emptyRule]
          },
          iva: {
            identifier: 'iva',
            rules: [emptyRule]
          },
          categoryID: {
            identifier: 'categoryID',
            rules: [emptyRule]
          },
          subcategoryID: {
            identifier: 'subcategoryID',
            rules: [emptyRule]
          },
          storePrice: {
            identifier: 'storePrice',
            rules: [emptyRule]
          },
          frepiPrice: {
            identifier: 'frepiPrice',
            rules: [emptyRule]
          }
        },
        inline: true,
        keyboardShortcuts: false
      });
    };

    ProductsVM.prototype.searchProduct = function() {
      var data, valueInput;
      valueInput = $('#product-searcher').form('get value', 'value');
      data = {
        search: valueInput
      };
      return RESTfulService.makeRequest('GET', "/search/products", data, (function(_this) {
        return function(error, success, headers) {
          var i, j, ref, totalPages;
          _this.isLoading(false);
          if (error) {
            console.log('An error has ocurred while fetching the products!');
            _this.shouldShowProductsAlert(true);
            return _this.productsAlertText('Hubo un problema buscando la información de los productos');
          } else {
            _this.shouldShowProductsAlert(false);
            console.log('After searching products with ' + valueInput);
            _this.currentProducts.removeAll();
            _this.productsPages.allPages = [];
            if (success.length > 0) {
              _this.shouldShowProductsAlert(false);
              totalPages = Math.ceil(headers.totalItems / 10);
              for (i = j = 0, ref = totalPages; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
                _this.productsPages.allPages.push({
                  num: i + 1
                });
              }
              _this.productsPages.activePage = 1;
              _this.productsPages.lowerLimit = 0;
              _this.productsPages.upperLimit = totalPages < 10 ? totalPages : 10;
              _this.productsPages.showablePages(_this.productsPages.allPages.slice(_this.productsPages.lowerLimit, _this.productsPages.upperLimit));
              $("table.products .pagination .pages .item:first-of-type").addClass('active');
              _this.currentProducts(success);
            } else {
              _this.shouldShowProductsAlert(true);
              _this.productsAlertText("Sin resultados para " + valueInput);
            }
            if (headers.accessToken) {
              return Config.setItem('headers', JSON.stringify(headers));
            }
          }
        };
      })(this));
    };

    ProductsVM.prototype.setDOMProperties = function() {
      $('.ui.modal').modal({
        onHidden: (function(_this) {
          return function() {
            console.log('closing');
            $('.ui.modal img')[0].src = '../../images/landing/image.png';
            $('.ui.modal .progress').progress({
              percent: 0
            });
            $('.ui.modal form').form('clear');
            return _this.shouldSetProductInfo = true;
          };
        })(this),
        onShow: (function(_this) {
          return function() {
            console.log('opening');
            return _this.fetchSucursals();
          };
        })(this)
      }).modal('attach events', '.ui.modal .cancel.button', 'hide');
      $('.modal .ui.image').dimmer({
        on: 'hover'
      });
      return $('.ui.progress').progress({
        percent: 0
      });
    };

    ProductsVM.prototype.previewImage = function(data, event) {
      console.log('previewing');
      this.chosenProduct.image(URL.createObjectURL(event.target.files[0]));
      $('.ui.modal img')[0].src = URL.createObjectURL(event.target.files[0]);
      return this.previewingImageHasChanged = true;
    };

    ProductsVM.prototype.setAWSCredentials = function() {
      AWS.config.region = 'us-east-1';
      AWS.config.update({
        accessKeyId: 'AKIAJPKUUYXNQVWSKLHA',
        secretAccessKey: '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'
      });
      return this.AWSBucket = new AWS.S3({
        params: {
          Bucket: 'frepi'
        }
      });
    };

    ProductsVM.prototype.uploadImage = function(file) {
      var $currentProgressBar, isCreationModalActive, objKey, params;
      this.currentUniqueID = this.generateUniqueID();
      if (file) {
        objKey = 'products/' + this.currentUniqueID;
        params = {
          Key: objKey,
          ContentType: file.type,
          Body: file,
          ACL: 'public-read'
        };
        this.fileHasBeenUploaded = false;
        isCreationModalActive = $('.create.modal').modal('is active');
        if (isCreationModalActive) {
          $currentProgressBar = $('.create.modal .progress');
          $('.create.modal form .green.button').addClass('loading');
        } else {
          $currentProgressBar = $('.update.modal .progress');
          $('.update.modal form .green.button').addClass('loading');
        }
        return this.AWSBucket.upload(params).on('httpUploadProgress', function(evt) {
          var AWSprogress;
          AWSprogress = parseInt((evt.loaded * 100) / evt.total);
          console.log("Uploaded :: " + parseInt((evt.loaded * 100) / evt.total) + '%');
          return $currentProgressBar.progress({
            percent: AWSprogress
          });
        }).send((function(_this) {
          return function(err, data) {
            if (!err) {
              _this.fileHasBeenUploaded = true;
              if (isCreationModalActive) {
                return _this.createProduct();
              } else {
                return _this.updateProduct();
              }
            } else {
              return $('.ui.modal form .green.button').removeClass('loading');
            }
          };
        })(this));
      } else {
        return alert('Nothing to upload');
      }
    };

    ProductsVM.prototype.editProduct = function() {
      var $fileChooser, $form, fileToUpload;
      if (this.previewingImageHasChanged) {
        $fileChooser = $('.update.modal .dimmer input')[0];
        $form = $('.update.modal form');
        fileToUpload = $fileChooser.files[0];
        if ($('.update.modal form').form('is valid')) {
          return this.uploadImage(fileToUpload);
        }
      } else {
        return this.updateProduct();
      }
    };

    ProductsVM.prototype.uploadProduct = function() {
      var $fileChooser, $form, fileToUpload;
      $fileChooser = $('.create.modal .dimmer input')[0];
      $form = $('.create.modal form');
      fileToUpload = $fileChooser.files[0];
      if ($('.create.modal form').form('is valid')) {
        return this.uploadImage(fileToUpload);
      }
    };

    return ProductsVM;

  })(AdminPageVM);

  products = new ProductsVM;

  ko.applyBindings(products);

}).call(this);
