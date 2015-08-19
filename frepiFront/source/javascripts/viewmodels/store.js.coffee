class LoginVM
  constructor: ->
    @categories = ko.observableArray()
    @getCategories()
    $('#departments-menu').sidebar({
        context: $('.main-content')
        transition: 'overlay'
      })
    # Modal variables
    @selectedProductCategory = ko.observable()
    @selectedProductName = ko.observable()
    @selectedProductPrice = ko.observable()

  showDepartments: ->    
    $('#departments-menu').sidebar('toggle')

  showProduct: (name, price, category) ->
    @selectedProductCategory(category)
    @selectedProductName(name)
    @selectedProductPrice("$#{price}")
    $('.ui.modal').modal('show')

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