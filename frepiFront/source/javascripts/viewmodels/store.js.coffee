class StoreVM extends TransactionalPageVM
	constructor: ->
		super()
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
		@setSizeSidebar()

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

	profile: ->
		@saveOrder()
		Config.setItem('showOrders', 'false')
		window.location.href = '../../store/profile.html'

	orders: ->
		@saveOrder()
		Config.setItem('showOrders', 'true')
		window.location.href = '../../store/profile.html'

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

	setDOMElements: ->
		$('#departments-menu').sidebar({
				transition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar button.basic', 'show')
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show')
		console.log $('#mobile-menu')
		$('#shopping-cart').sidebar({
				dimPage: false
				transition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar .right button', 'show')
				.sidebar('attach events', '#shopping-cart i', 'show')
		$('#modal-dropdown').dropdown()

	showProduct: (product) ->
		@selectedProduct = product
		@selectedProductCategory(product.subcategoryName)
		@selectedProductImage(product.image)
		@selectedProductName(product.name)
		@selectedProductPrice("$#{product.frepi_price}")
		$('.ui.modal').modal('show')

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

	setSizeSidebar: ->
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