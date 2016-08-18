class StoreVM extends TransactionalPageVM
	constructor: ->
		super()
		@shouldShowError = ko.observable(false)
		@shouldDisplayLoader = ko.observable(true)
		@showDepartmentButton = ko.observable($(window).width() < 991)
		# Methods to execute on instance
		@setExistingSession()
		@session.categories([])
		@setUserInfo()
		@fetchCategories()
		@setDOMElements()
		@setSizeSidebar()

	fetchCategories: ->
		RESTfulService.makeRequest('GET', "/stores/#{@session.currentStore.id()}/categories", '', (error, success, headers) =>
			@shouldDisplayLoader(false)
			$('section.products').css('display', 'block')
			if error
				# console.log 'An error has ocurred while fetching the categories!'
				# @shouldShowError(true)
				$('#error-container').css('display', 'block')
				console.log error
			else
				@session.categories(success)
				@setDOMElems()
				@setCartItemsLabels()
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
				mobileTransition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar button.basic', 'show')
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('setting', 'mobileTransition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show')
		$('#modal-dropdown').dropdown()

	setSizeSidebar: ->
		if $(window).width() < 480
			$('#shopping-cart').removeClass('wide')
		else
			$('#shopping-cart').addClass('wide')

		$(window).resize(=>
			@showDepartmentButton($(window).width() < 976)
			if $(window).width() < 480
				$('#shopping-cart').removeClass('wide')
			else
				$('#shopping-cart').addClass('wide')
		)

store = new StoreVM
ko.applyBindings(store)
