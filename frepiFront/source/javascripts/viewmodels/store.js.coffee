class StoreVM extends TransactionalPageVM
	constructor: ->
		super()
		@shouldShowError = ko.observable(false)

		# Modal variables
		# @selectedProduct = null
		# @selectedProductCategory = ko.observable()
		# @selectedProductImage = ko.observable()
		# @selectedProductName = ko.observable()
		# @selectedProductPrice = ko.observable()

		# Methods to execute on instance
		@setExistingSession()
		@setUserInfo()
		# @fetchStoreSucursals()
		@fetchCategories()
		@setDOMElements()
		# @setSucursal()
		@setSizeSidebar()
		console.log 'Is signed Up? ' + @session.signedUp()

	fetchCategories: ->
		RESTfulService.makeRequest('GET', "/stores/#{@session.currentStore.id()}/categories", '', (error, success, headers) =>
			if error
				# console.log 'An error has ocurred while fetching the categories!'
				# @shouldShowError(true)
				console.log error
			else
				console.log success
				@session.categories(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	profile: ->
		@saveOrder()
		Config.setItem('showOrders', 'false')
		window.location.href = '../../store/profile.html'

	orders: ->
		@saveOrder()
		Config.setItem('showOrders', 'true')
		window.location.href = '../../store/profile.html'

	setSucursal: ->
		if @session.currentSucursal.id() is -1
			$('#choose-store').modal('show')

	setDOMElements: ->
		$('#departments-menu').sidebar({
				transition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar button.basic', 'show')
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show')
		$('#shopping-cart').sidebar({
				dimPage: false
				transition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar .right button', 'show')
				.sidebar('attach events', '#shopping-cart i', 'show')
		$('#modal-dropdown').dropdown()

	# showProduct: (product) ->
	# 	@selectedProduct = product
	# 	@selectedProductCategory(product.subcategoryName)
	# 	@selectedProductImage(product.image)
	# 	@selectedProductName(product.name)
	# 	@selectedProductPrice("$#{product.frepiPrice}")
	# 	$('#product-desc').modal('show')

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
