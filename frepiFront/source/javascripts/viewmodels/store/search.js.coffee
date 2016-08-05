class SearchVM extends TransactionalPageVM
	constructor: ->
		super()
		@deparment = ko.mapping.fromJS(DefaultModels.DEPARMENT)
		@subcategories = ko.observableArray()
		@products = ko.observableArray([])
		@valueSearchingFor = ko.observable()

		# Modal variables
		@selectedProduct = null
		@selectedProductCategory = ko.observable()
		@selectedProductImage = ko.observable()
		@selectedProductName = ko.observable()
		@selectedProductPrice = ko.observable()
		@shouldShowLoadMore = ko.observable(false)
		@pages =
			currentPage: 1
			totalNumber: 0

		@setExistingSession()
		@setUserInfo()
		@fetchProducts()

		@setDOMElements()
		@setSizeSidebar()

	fetchProducts: =>
		data =
			search: @session.stringToSearch

		# currentButton = clickedButton.toElement if !!clickedButton
		RESTfulService.makeRequest('GET', "/search/products", data, (error, success, headers) =>
			if error
			# console.log 'An error has ocurred while fetching the categories!'
				console.log error
			else
				if success.length > 0
					@pages.totalNumber = Math.ceil(headers.totalItems/10)
					@products(success)
					@setCartItemsLabels()
					if @pages.totalNumber > 1 then @shouldShowLoadMore(true)
		)

	fetchNextPage: =>
		$loadMoreButton = $('.load-more.button');
		data =
			search: @session.stringToSearch
			page: @pages.currentPage + 1

		$loadMoreButton.addClass('loading')
		RESTfulService.makeRequest('GET', "/search/products", data, (error, success, headers) =>
			$loadMoreButton.removeClass('loading')
			if error
			# console.log 'An error has ocurred while fetching the categories!'
				console.log error
			else
				@pages.currentPage += 1
				@products.push.apply(@products, success)
				@setCartItemsLabels()
				if @pages.totalNumber <= @pages.currentPage then @shouldShowLoadMore(false)
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
		$('#modal-dropdown').dropdown()

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

searchVM = new SearchVM
ko.applyBindings(searchVM)
