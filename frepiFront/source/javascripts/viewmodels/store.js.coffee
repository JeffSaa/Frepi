class LoginVM
  constructor: ->
    @categories = ko.observableArray()
    @itemsToBuy = ko.observable('0 items')

    # Modal variables
    @selectedProductCategory = ko.observable()
    @selectedProductImage = ko.observable()
    @selectedProductName = ko.observable()
    @selectedProductPrice = ko.observable()

    # Methods to execute
    @getCategories()
    @setDOMComponents()

  setDOMComponents: ->
    $('#departments-menu').sidebar({        
        transition: 'overlay'
      })
    $('#shopping-cart').sidebar({        
        dimPage: false
        transition: 'overlay'
      })
    $('#modal-dropdown').dropdown()

  showDepartments: ->    
    $('#departments-menu').sidebar('toggle')

  showProduct: (name, price, category, image) ->
    @selectedProductCategory(category)
    @selectedProductImage(image)
    @selectedProductName(name)
    @selectedProductPrice("$#{price}")
    $('.ui.modal').modal('show')

  showShoppingCart: ->
    $('#shopping-cart').sidebar('show')

  showStoreInfo: ->
    $('#store-banner').dimmer('show')

  getCategories: ->
    storeID = 1
    sucursalID = 1
    data = ''
    RESTfulService.makeRequest('GET', "/stores/#{storeID}/sucursals/#{sucursalID}/products", data, (error, success) =>
      if error
        console.log 'An error has ocurried while fetching the categories!'
      else
        @setProductsToShow(success)
    )

  # Set the products that are going to be showed on the Store's view
  setProductsToShow: (categories) ->
    console.log categories
    for category in categories
      productsToShow = []
      allProductsCategory = []
      for subCategory in category.subcategories
        for product in subCategory.products
          product.subcategoryName = subCategory.name
        allProductsCategory = allProductsCategory.concat(subCategory.products)

      while productsToShow.length < 4
        random = Math.floor(Math.random()*(allProductsCategory.length - 1))
        if productsToShow.indexOf(allProductsCategory[random]) == -1
          productsToShow.push(allProductsCategory[random])

      category.productsToShow = productsToShow

    @categories(categories)
      

login = new LoginVM
ko.applyBindings(login)