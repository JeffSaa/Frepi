class StoreVM
	constructor: ->
		@session =
			categories: ko.observableArray()
			currentOrder:
				numberProducts: ko.observable()
				products: ko.observableArray()
				price: ko.observable()
				sucursalId: null

		@shouldShowError = ko.observable(false)
		@userName = ko.observable()

		# Modal variables
		@selectedProduct = null
		@selectedProductCategory = ko.observable()
		@selectedProductImage = ko.observable()
		@selectedProductName = ko.observable()
		@selectedProductPrice = ko.observable()

		# Methods to execute on instance
		@setExistingSession()
		@setUserInfo()
		@fetchCategories()
		@setDOMElements()
		@setSizeButtons()

	addToCart: (productToAdd) =>
		quantitySelected = parseInt($('#modal-dropdown').dropdown('get value')[0])
		product = @getProductByName(productToAdd.name)

		if !product
			productToAdd.quantity = quantitySelected
			productToAdd.totalPrice = Math.round(parseFloat(productToAdd.frepi_price)*100)/100
			@session.currentOrder.products.push(productToAdd)
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

			@session.currentOrder.products.replace(oldProduct, newProduct)
		
		@session.currentOrder.price(Math.round((@session.currentOrder.price() + productToAdd.frepi_price*quantitySelected)*100) / 100)
		console.log @session.currentOrder.price()
		$('#modal-dropdown').dropdown('set text', 'Cantidad')
		$('#modal-dropdown').dropdown('set value', '1')
		$('.ui.modal').modal('hide')
		console.log @session.currentOrder.products()

		if @session.currentOrder.products().length isnt 1
			@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
		else
			@session.currentOrder.numberProducts("1 item")

	checkout: ->
		if @session.currentOrder.products().length > 0
			orderToPay =
				price: @session.currentOrder.price()
				products: @session.currentOrder.products()
				sucursalId: @session.currentOrder.sucursalId
			console.log orderToPay
			Config.setItem('orderToPay', JSON.stringify(orderToPay))
			window.location.href = '../../checkout.html'
		else
			console.log 'There is nothing in the cart...'

	# Returns null or a product if is currently in the cart
	getProductByName: (name) ->
		for product in @session.currentOrder.products()
			return product if product.name is name      
		
		return null

	goToProfile: ->
		session =
			categories: @session.categories()
			currentOrder:
				numberProducts: @session.currentOrder.numberProducts()
				products: @session.currentOrder.products()
				price: @session.currentOrder.price()
				sucursalId: @session.currentOrder.sucursalId
		Config.setItem('showOrders', 'false')
		Config.setItem('currentSession', JSON.stringify(session))
		window.location.href = '../../profile.html'

	goToOrders: ->
		session =
			categories: @session.categories()
			currentOrder:
				numberProducts: @session.currentOrder.numberProducts()
				products: @session.currentOrder.products()
				price: @session.currentOrder.price()
				sucursalId: @session.currentOrder.sucursalId
		Config.setItem('showOrders', 'true')
		Config.setItem('currentSession', JSON.stringify(session))
		window.location.href = '../../profile.html'

	fetchCategories: ->
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

			@session.currentOrder.products.replace(oldProduct, newProduct)
			
			@session.currentOrder.price(Math.round((@session.currentOrder.price() - product.frepi_price)*100) / 100)
			console.log @session.currentOrder.price()
			console.log @session.currentOrder.products()

	removeItem: (item) ->
		@session.currentOrder.price(Math.round((@session.currentOrder.price() - item.totalPrice) * 100)/100)
		console.log @session.currentOrder.price()
		@session.currentOrder.products.remove(item)

		if @session.currentOrder.products().length isnt 1
			@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
		else
			@session.currentOrder.numberProducts("1 item")

	setExistingOrder: ->
		order = Config.getItem('currentOrder')
		console.log @session

		if order
			order = JSON.parse(Config.getItem('currentOrder'))
			@session.currentOrder.numberProducts(order.numberProducts())
			@session.currentOrder.products(order.products())
			@session.currentOrder.price(order.price())
			@session.currentOrder.sucursalId(order.sucursalId())
		else
			@session.currentOrder.numberProducts('0 items')
			@session.currentOrder.products([])
			@session.currentOrder.price(0.0)
			@session.currentOrder.sucursalId = 1

	setExistingSession: ->
		session = Config.getItem('currentSession')

		if session
			session = JSON.parse(Config.getItem('currentSession'))
			@session.categories(session.categories)
			@session.currentOrder.numberProducts(session.currentOrder.numberProducts)
			@session.currentOrder.products(session.currentOrder.products)
			@session.currentOrder.price(session.currentOrder.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId
		else
			@session.categories([])
			@session.currentOrder.numberProducts('0 items')
			@session.currentOrder.products([])
			@session.currentOrder.price(0.0)
			@session.currentOrder.sucursalId = 1

	setUserInfo: ->
		user = Config.getItem('userObject')
		if user
			user = JSON.parse(Config.getItem('userObject'))
			@userName(user.name.split(' ')[0])
		else
			@userName('amigo')

	setDOMElements: ->
		$('#departments-menu').sidebar({
				transition: 'overlay'
			})
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo', 'show')
		console.log $('#mobile-menu')
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

		@session.categories(categories)

	setSizeButtons: ->
		if $(window).width() < 480
			$('#shopping-cart').removeClass('wide')
		else
			$('#shopping-cart').addClass('wide')

		$(window).resize(->
			if $(window).width() < 480
				$('#shopping-cart').removeClass('wide')
			else
				$('#shopping-cart').addClass('wide')
		)
			

store = new StoreVM
ko.applyBindings(store)