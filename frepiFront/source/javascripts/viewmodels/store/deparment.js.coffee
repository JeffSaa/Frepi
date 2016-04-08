class DeparmentVM extends TransactionalPageVM
	constructor: ->
		super()
		@deparment = ko.mapping.fromJS(DefaultModels.DEPARMENT)
		@subcategories = ko.observableArray()
		@products = ko.observableArray()

		@currentSubcatBtn = null

		# Display variables
		@shouldDisplayNoResultAlert = ko.observable(false)
		@shouldDisplayLoader = ko.observable(true)

		# Modal variables
		@selectedProduct = null
		@selectedProductCategory = ko.observable()
		@selectedProductImage = ko.observable()
		@selectedProductName = ko.observable()
		@selectedProductPrice = ko.observable()

		@setExistingSession()
		@setUserInfo()
		@setDeparment()
		@setSizeSidebar()
		@setSizeButtons()

		# TODO: Change size of buttons on mobile devices

		@setDOMElements()

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
						@setDOMElems()
						@subcategories(success)
						if @session.currentSubcategorID
							@fetchProducts({id: @session.currentSubcategorID})
						else
							@fetchAllProducts()
						# Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				)
		)

	fetchAllProducts: =>
		@products([])
		@shouldDisplayLoader(true)
		@shouldDisplayNoResultAlert(false)
		$('h1 + .horizontal.list .button').addClass('basic')
		$('.list .item.all .button').removeClass('basic')

		RESTfulService.makeRequest('GET', "/categories/#{@session.currentDeparmentID}/products", '', (error, success, headers) =>
			@shouldDisplayLoader(false)
			if error
			# console.log 'An error has ocurred while fetching the categories!'
				console.log error
			else
				if success.length > 0
					@products(success)
					@setCartItemsLabels()
				else
					@shouldDisplayNoResultAlert(true)
		)

	fetchProducts: (subcategory) =>
		@products([])
		@shouldDisplayLoader(true)
		@shouldDisplayNoResultAlert(false)
		$('h1 + .horizontal.list .button').addClass('basic')
		$("#subcat#{subcategory.id}").removeClass('basic')

		# currentButton = clickedButton.toElement if !!clickedButton
		RESTfulService.makeRequest('GET', "/subcategories/#{subcategory.id}/products", '', (error, success, headers) =>
			@shouldDisplayLoader(false)
			if error
			# console.log 'An error has ocurred while fetching the categories!'
				console.log error
			else
				if success.length > 0
					@products(success)
					@setCartItemsLabels()
				else
					@shouldDisplayNoResultAlert(true)
		)

	profile: ->
		@saveOrder()
		Config.setItem('showOrders', 'false')
		window.location.href = '../store/profile.html'

	orders: ->
		@saveOrder()
		Config.setItem('showOrders', 'true')
		window.location.href = '../store/profile.html'

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

	setSizeButtons: ->
		if $(window).width() < 480
			$('.horizontal.list .button').addClass('mini')

		$(window).resize(->
			if $(window).width() < 480
				$('.horizontal.list .button').addClass('mini')
			else
				$('.horizontal.list .button').removeClass('mini')
		)

store = new DeparmentVM
ko.applyBindings(store)
