class StoreVM extends TransactionalPageVM
	constructor: ->
		super()
		@shouldShowError = ko.observable(false)
		@shouldDisplayLoader = ko.observable(true)
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
			@shouldDisplayLoader(false)
			if error
				# console.log 'An error has ocurred while fetching the categories!'
				@shouldShowError(true)
				console.log error
			else
				console.log success
				@session.categories(success)
				@setCartItemsLabels()
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

store = new StoreVM
ko.applyBindings(store)
