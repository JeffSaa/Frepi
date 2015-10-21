class CheckoutVM
	constructor: ->   
		# Observables
		constructor: ->
		@session =
			categories: ko.observableArray()
			currentOrder:
				numberProducts: ko.observable()
				products: ko.observableArray()
				price: ko.observable()
				sucursalId: null
		@order = null
		@headerMessage = ko.observable('Confirma tu orden')
		@orderGenerated = ko.observable(false)
		@userName = ko.observable()
		@user = null
		@setDOMElements()
		@setExistingSession()
		@setOrderToPay()
		@setSizeButtons()

	logout: ->
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'

	cancel: ->
		window.location.href = '../../store.html'

	generate: ->
		console.log 'Its here, generating order'

		productsToSend = []

		for product in @order.products()
			productsToSend.push({
					id: product.id()
					quantity: product.quantity()
				})
		
		data =
			products:	productsToSend
			sucursalId: @order.sucursalId()
			totalPrice: @order.price()

		RESTfulService.makeRequest('POST', "/users/#{@user.id}/orders", data, (error, success, headers) =>
			if error
				console.log 'An error has ocurred while updating the user!'
				@headerMessage('Ha ocurrido un error generando la orden. Intenta más tarde.')
			else
				@orderGenerated(true)
				console.log 'Order has been created'
				setTimeout(( ->
						window.location.href = '../../store.html'
					), 2500)
				console.log success
				Config.setItem('headers', JSON.stringify(headers))
		)		

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
		window.location.href = '../../store/profile.html'

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
		window.location.href = '../../store/profile.html'

	setDOMElements: ->
		$('#departments-menu').sidebar({
				transition: 'overlay'
			})
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo', 'show')

	showDepartments: ->    
		$('#departments-menu').sidebar('toggle')

	showShoppingCart: ->
		$('#shopping-cart').sidebar('show')

	setExistingSession: ->
		console.log 'esta aqui'
		session = Config.getItem('currentSession')

		if session
			session = JSON.parse(Config.getItem('currentSession'))
			console.log session
			@session.categories(session.categories)
			@session.currentOrder.numberProducts(session.currentOrder.numberProducts)
			@session.currentOrder.products(session.currentOrder.products)
			@session.currentOrder.price(session.currentOrder.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId
			console.log @session.categories()
		else
			@session.categories([])
			@session.currentOrder.numberProducts('0 items')
			@session.currentOrder.products([])
			@session.currentOrder.price(0.0)
			@session.currentOrder.sucursalId = 1

	setOrderToPay: ->
		@user = JSON.parse(Config.getItem('userObject'))
		console.log @user
		@userName(@user.name.split(' ')[0])
		order = JSON.parse(Config.getItem('orderToPay'))
		@order = ko.mapping.fromJS(order)

	setSizeButtons: ->
		if $(window).width() < 480
			$('.ui.buttons').addClass('tiny')
			$('.ui.labeled.button').addClass('tiny')
		else
			$('.ui.buttons').removeClass('tiny')
			$('.ui.labeled.button').removeClass('tiny')

		$(window).resize(->
			if $(window).width() < 480
				$('.ui.buttons').addClass('tiny')
				$('.ui.labeled.button').addClass('tiny')
			else
				$('.ui.buttons').removeClass('tiny')
				$('.ui.labeled.button').removeClass('tiny')
		)

checkout = new CheckoutVM
ko.applyBindings(checkout)