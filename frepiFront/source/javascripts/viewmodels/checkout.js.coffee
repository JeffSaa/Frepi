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
		@userName = ko.observable()
		@user = null
		@setDOMElements()
		@setExistingSession()
		@setOrderToPay()
		@setSizeButtons()

	logout: ->
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'

	delete: ->
		console.log 'hgjk'

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
			else
				console.log 'Order has been created'
				console.log success
				Config.setItem('accessToken', headers.accessToken)
				Config.setItem('client', headers.client)
				Config.setItem('uid', headers.uid)
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

	setDOMElements: ->
		$('#departments-menu').sidebar({
				transition: 'overlay'
			})

	showDepartments: ->    
		$('#departments-menu').sidebar('toggle')

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