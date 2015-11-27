class CheckoutVM
	constructor: ->   
		# Observables
		constructor: ->
		@session =
			currentStore				: null
			currentSucursal			: null
			currentDeparmentID	: null
			categories					: ko.observableArray()
			signedUp						: ko.observable()
			sucursals						: ko.observableArray()
			currentOrder:
				numberProducts	: ko.observable()
				products 				: ko.observableArray()
				price 					: ko.observable()
		@availableDateTime = null
		@headerMessage = ko.observable('Confirma tu orden')
		@orderGenerated = ko.observable(false)
		@userName = ko.observable()
		@user = null
		@setDOMElements()
		@setOrderToPay()
		@setSizeButtons()
		@setAvailableDeliveryDateTime()
		console.log 'ava date'
		console.log @availableDateTime

	seeDeliveryRight: ->
		$('#products').transition('fade right')
		$('#delivery').transition('fade left')

	seeDeliveryLeft: ->
		$('#confirm').transition('fade left')
		$('#delivery').transition('fade right')

	seeProducts: ->
		$('#products').transition('fade right')
		$('#delivery').transition('fade left')

	seeConfirm: ->
		$('#delivery').transition('fade right')
		$('#confirm').transition('fade left')

	logout: ->
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'

	cancel: ->
		window.location.href = '../../store/index.html'

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
		Config.setItem('showOrders', 'false')
		#Config.setItem('currentSession', JSON.stringify(session))
		window.location.href = '../../store/profile.html'

	goToOrders: ->
		Config.setItem('showOrders', 'true')
		#Config.setItem('currentSession', JSON.stringify(session))
		window.location.href = '../../store/profile.html'

	setDOMElements: ->
		$('#departments-menu').sidebar({
				transition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar .basic.button', 'show')
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show')
		$('.dropdown').dropdown()

	setAvailableDeliveryDateTime: =>
		today = moment().minutes(0)
		tomorrow = moment().add(1, 'days').hours(8).minutes(0)
		aftertomorrow = moment().add(2, 'days').hours(8).minutes(0)
		@availableDateTime =
			today: 
				date: today.format('MMMM Do YYYY, h:mm a')
				availableHours: @generateAvailableHours(today)
			tomorrow: 
				date: tomorrow.format('MMMM Do YYYY, h:mm a')
				availableHours: @generateAvailableHours(tomorrow)
			aftertomorrow: 
				date: aftertomorrow.format('MMMM Do YYYY, h:mm a')
				availableHours: @generateAvailableHours(aftertomorrow)

	generateAvailableHours: (startHour) ->
		endHour = moment(startHour.format('MMMM Do YYYY, h:mm a'), 'MMMM Do YYYY, h:mm a').hours(19).minutes(0)
		hours = []
		for i in [0..startHour.diff(endHour, 'hours')]
			hours.push(startHour.add(1, 'hours').format('MMMM Do YYYY, h:mm a'))

		return hours


	setOrderToPay: ->
		@user = JSON.parse(Config.getItem('userObject'))
		console.log @user
		@userName(@user.name.split(' ')[0])
		order = JSON.parse(Config.getItem('orderToPay'))
		console.log order
		session = JSON.parse(Config.getItem('currentSession'))
		@session.currentOrder.numberProducts(order.numberProducts)
		@session.currentOrder.products(order.products)
		@session.currentOrder.price(order.price)
		@session.currentSucursal = ko.mapping.toJS(session.currentSucursal)

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