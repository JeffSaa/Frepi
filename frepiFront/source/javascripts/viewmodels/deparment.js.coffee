class DeparmentVM extends TransactionalPageVM
	constructor: ->
		super()
		@deparment = ko.mapping.fromJS(DefaultModels.DEPARMENT)
		@subcategories = ko.observableArray()
		@products = ko.observableArray()

		@currentSubcatBtn = null

		# Modal variables
		@selectedProduct = null
		@selectedProductCategory = ko.observable()
		@selectedProductImage = ko.observable()
		@selectedProductName = ko.observable()
		@selectedProductPrice = ko.observable()

		@setExistingSession()
		@setUserInfo()
		@setDeparment()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		# @fetchStoreSucursals()
		@setDOMElements()
		# # @setSucursal()
		# @setSizeSidebar()

	setDeparment: ->
		RESTfulService.makeRequest('GET', "/categories/#{@session.currentDeparmentID}", '', (error, success, headers) =>
			if error
				# console.log 'An error has ocurred while fetching the categories!'
				console.log error
			else
				console.log success
				ko.mapping.fromJS(success, @deparment)
				RESTfulService.makeRequest('GET', "/categories/#{@session.currentDeparmentID}/subcategories", '', (error, success, headers) =>
					if error
					# console.log 'An error has ocurred while fetching the categories!'
						console.log error
					else
						console.log success
						@subcategories(success)
						@fetchProducts(@subcategories()[0])
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				)
		)

	fetchCategories: ->
		RESTfulService.makeRequest('GET', "/stores/#{@session.currentStore.id()}/sucursals/#{@session.currentSucursal.id()}/products", '', (error, success, headers) =>
			if error
				# console.log 'An error has ocurred while fetching the categories!'
				@shouldShowError(true)
			else
				console.log success
				@setProductsToShow(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchStoreSucursals: ->
		RESTfulService.makeRequest('GET', "/stores/#{@session.currentStore.id()}/sucursals", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred while fetching the sucursals!'
			else
				console.log success
				@session.sucursals(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchProducts: (subcategory, clickedButton) =>
		console.log 'Btn'
		if !!@currentSubcatBtn
			@currentSubcatBtn.addClass('basic')
			@currentSubcatBtn = $(clickedButton.toElement)
		else
			@currentSubcatBtn = $('.list .item:first-of-type .button')
		console.log @currentSubcatBtn
		@currentSubcatBtn.removeClass('basic')
		# currentButton = clickedButton.toElement if !!clickedButton
		RESTfulService.makeRequest('GET', "/subcategories/#{subcategory.id}/products", '', (error, success, headers) =>
			if error
			# console.log 'An error has ocurred while fetching the categories!'
				console.log error
			else
				console.log success
				@products(success)
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

	showProduct: (product) ->
		@selectedProduct = product
		@selectedProductCategory(product.subcategoryName)
		@selectedProductImage(product.image)
		@selectedProductName(product.name)
		@selectedProductPrice("$#{product.frepiPrice}")
		$('#product-desc').modal('show')

store = new DeparmentVM
ko.applyBindings(store)