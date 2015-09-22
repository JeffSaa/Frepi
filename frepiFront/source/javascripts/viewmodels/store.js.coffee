class LoginVM
	constructor: ->
		@categories = ko.observableArray()
		@itemsToBuy = ko.observable('0 items')
		@itemsInCart = ko.observableArray([])
		@priceInCart = ko.observable(0.0)
		@shouldShowError = ko.observable(false)
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
			productToAdd.totalPrice = Math.round(parseFloat(productToAdd.frepi_price)*100)/100
			@itemsInCart.push(productToAdd)
		else
			oldProduct = product
			newProduct =
				available: oldProduct.available
				frepi_price: oldProduct.frepi_price
				id: oldProduct.id
				image: oldProduct.image
				name: oldProduct.name
				quantity: oldProduct.quantity + quantitySelected
				referenceCode: oldProduct.referenceCode
				salesCount: oldProduct.salesCount
				storePrice: oldProduct.storePrice
				subcategoryName: oldProduct.subcategoryName
				subcategoryId: oldProduct.subcategoryId
				totalPrice: oldProduct.totalPrice + (Math.round(parseFloat(product.frepi_price) * 100) / 100)*quantitySelected

			@itemsInCart.replace(oldProduct, newProduct)
		
		@priceInCart(Math.round((@priceInCart() + productToAdd.frepi_price*quantitySelected)*100) / 100)
		console.log @priceInCart()
		$('#modal-dropdown').dropdown('set text', 'Cantidad')
		$('#modal-dropdown').dropdown('set value', '1')
		$('.ui.modal').modal('hide')
		console.log @itemsInCart()

		if @itemsInCart().length isnt 1
			@itemsToBuy("#{@itemsInCart().length} items")
		else
			@itemsToBuy("1 item")

	checkout: ->
		if @itemsInCart().length > 0
			sucursalID = 1
			orderToPay =
				price: @priceInCart()
				products: @itemsInCart()
				sucursalId: sucursalID
			console.log orderToPay
			Config.setItem('orderToPay', JSON.stringify(orderToPay))
			window.location.href = '../../checkout.html'
		else
			console.log 'There is nothing in the cart...'

	# Returns null or a product if is currently in the cart
	getProductByName: (name) ->
		for product in @itemsInCart()
			return product if product.name is name      
		
		return null

	goToProfile: ->
		window.location.href = '../../profile.html'

	removeFromCart: (product) ->

		if product.quantity is 1
			@removeItem(product)
		else
			oldProduct = product
			newProduct =
				available: oldProduct.available
				frepi_price: oldProduct.frepi_price
				id: oldProduct.id
				image: oldProduct.image
				name: oldProduct.name
				quantity: oldProduct.quantity - 1
				referenceCode: oldProduct.referenceCode
				salesCount: oldProduct.salesCount
				storePrice: oldProduct.storePrice
				subcategoryName: oldProduct.subcategoryName
				subcategoryId: oldProduct.subcategoryId
				totalPrice: oldProduct.totalPrice - (Math.round(parseFloat(product.frepi_price) * 100) / 100)

			@itemsInCart.replace(oldProduct, newProduct)
			
			@priceInCart(Math.round((@priceInCart() - product.frepi_price)*100) / 100)
			console.log @priceInCart()
			console.log @itemsInCart()

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
		@selectedProductPrice("$#{product.frepi_price}")
		$('.ui.modal').modal('show')

	showShoppingCart: ->
		$('#shopping-cart').sidebar('show')

	showStoreInfo: ->
		$('#store-banner').dimmer('show')

	setUserInfo: ->
		user = JSON.parse(Config.getItem('userObject'))
		@userName(user.name.split(' ')[0])

	getCategories: ->
		storeID = 2
		sucursalID = 1
		data = ''
		RESTfulService.makeRequest('GET', "/stores/#{storeID}/sucursals/#{sucursalID}/products", data, (error, success, headers) =>
			if error
				# console.log 'An error has ocurred while fetching the categories!'
				@shouldShowError(true)
			else
				console.log success
				@setProductsToShow(success)
		)

	logout: ->
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'

	removeItem: (item) ->
		@priceInCart(Math.round((@priceInCart() - item.totalPrice) * 100)/100)
		console.log @priceInCart()
		@itemsInCart.remove(item)

		if @itemsInCart().length isnt 1
			@itemsToBuy("#{@itemsInCart().length} items")
		else
			@itemsToBuy("1 item")


	# Set the products that are going to be showed on the Store's view
	setProductsToShow: (categories) ->
		for category in categories
			productsToShow = []
			allProductsCategory = []
			for subCategory in category.subcategories
				for product in subCategory.products
					product.subcategoryName = subCategory.name
					product.totalPrice = 0.0
				allProductsCategory = allProductsCategory.concat(subCategory.products)

			# console.log 'Products per category'
			# console.log allProductsCategory

			while productsToShow.length < 4 and productsToShow.length < allProductsCategory.length
				# productsToShow.push(allProductsCategory[productsToShow.length])
				random = Math.floor(Math.random()*(allProductsCategory.length))
				if productsToShow.indexOf(allProductsCategory[random]) == -1
				  productsToShow.push(allProductsCategory[random])

			category.productsToShow = productsToShow

		@categories(categories)
			

login = new LoginVM
ko.applyBindings(login)