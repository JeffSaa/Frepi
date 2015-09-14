class LoginVM
  constructor: ->
    @categories = ko.observableArray()
    @itemsToBuy = ko.observable('0 items')
    @itemsInCart = ko.observableArray([])
    @userName = ko.observable()

    # Modal variables
    @selectedProduct = null
    @selectedProductCategory = ko.observable()
    @selectedProductImage = ko.observable()
    @selectedProductName = ko.observable()
    @selectedProductPrice = ko.observable()

    # Methods to execute on instance
    @setUserInfo()
    @getCategories()
    @setDOMElements()

  addToCart: (productToAdd) =>
    quantitySelected = parseInt($('#modal-dropdown').dropdown('get value')[0])
    product = @getProductByName(productToAdd.name)

    if !product
      productToAdd.quantity = quantitySelected
      @itemsInCart.push(productToAdd)
    else
      oldProduct = product
      newProduct =
        available: oldProduct.available
        frepiPrice: oldProduct.frepiPrice
        id: oldProduct.id
        image: oldProduct.image
        name: oldProduct.name
        quantity: oldProduct.quantity + quantitySelected
        referenceCode: oldProduct.referenceCode
        salesCount: oldProduct.salesCount
        storePrice: oldProduct.storePrice
        subcategoryName: oldProduct.subcategoryName
        subcategoryId: oldProduct.subcategoryId

      @itemsInCart.replace(oldProduct, newProduct)
    
    console.log @itemsInCart()

    if @itemsInCart().length isnt 1
      @itemsToBuy("#{@itemsInCart().length} items")
    else
      @itemsToBuy("1 item")

  # Return a product if it's currently in the cart or null
  getProductByName: (name) ->
    for product in @itemsInCart()
      return product if product.name is name      
    
    return null

  setDOMElements: ->
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

  showProduct: (product) ->
    @selectedProduct = product
    @selectedProductCategory(product.subcategoryName)
    @selectedProductImage(product.image)
    @selectedProductName(product.name)
    @selectedProductPrice("$#{product.frepiPrice}")
    $('.ui.modal').modal('show')

  showShoppingCart: ->
    $('#shopping-cart').sidebar('show')

  showStoreInfo: ->
    $('#store-banner').dimmer('show')

  setUserInfo: ->
    user = JSON.parse(Config.getItem('userObject'))
    @userName(user.name.split(' ')[0])

  getCategories: ->
    storeID = 1
    sucursalID = 1
    data = ''
    RESTfulService.makeRequest('GET', "/stores/#{storeID}/sucursals/#{sucursalID}/products", data, (error, success, headers) =>
      if error
        console.log 'An error has ocurried while fetching the categories!'
      else
        console.log success
        @setProductsToShow(success)
    )

  logout: ->
    Config.destroyLocalStorage()
    window.location.href = '../../login.html'

  # Set the products that are going to be showed on the Store's view
  setProductsToShow: (categories) ->
    for category in categories
      productsToShow = []
      allProductsCategory = []
      for subCategory in category.subcategories
        for product in subCategory.products
          product.subcategoryName = subCategory.name
        allProductsCategory = allProductsCategory.concat(subCategory.products)

      console.log 'Products per category'
      console.log allProductsCategory

      while productsToShow.length < 4 and productsToShow.length < allProductsCategory.length
        productsToShow.push(allProductsCategory[productsToShow.length])
        # random = Math.floor(Math.random()*(allProductsCategory.length - 1))
        # if productsToShow.indexOf(allProductsCategory[random]) == -1
        #   productsToShow.push(allProductsCategory[random])

      category.productsToShow = productsToShow

    @categories(categories)
      

login = new LoginVM
ko.applyBindings(login)