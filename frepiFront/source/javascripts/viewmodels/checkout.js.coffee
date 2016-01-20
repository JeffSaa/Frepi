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
		@user = JSON.parse(Config.getItem('userObject'))
		@headerMessage = ko.observable('Confirma tu orden')
		@orderGenerated = ko.observable(false)
		@selectedDay = ko.observable()
		@selectedDate = ko.observable()
		@selectedHour = ko.observable()
		@selectedExpiredHour = ko.observable()
		@availableDays = ko.observableArray()
		@availableHours = ko.observableArray()
		@userName = ko.observable()
		@comment = ko.observable()
		@address = ko.observable(@user.address)
		@setDOMElements()
		@setOrderToPay()
		@setSizeButtons()
		@setAvailableDeliveryDateTime()
		console.log @availableDateTime

	seeDeliveryRight: ->
		$('#products-icon').removeClass('active')
		$('#delivery-icon').addClass('active')
		$('#products').transition('fade right')
		$('#delivery').transition('fade left')

	seeDeliveryLeft: ->
		$('#confirm-icon').removeClass('active')
		$('#delivery-icon').addClass('active')
		$('#confirm').transition('fade left')
		$('#delivery').transition('fade right')

	seeProducts: ->
		$('#delivery-icon').removeClass('active')
		$('#products-icon').addClass('active')
		$('#products').transition('fade right')
		$('#delivery').transition('fade left')

	seeConfirm: ->
		if !!@selectedDay() and !!@selectedHour() and !!@address()
			$('#delivery-icon').removeClass('active')
			$('#confirm-icon').addClass('active')
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

		for product in @session.currentOrder.products()
			productsToSend.push({
					id: product.id
					quantity: product.quantity
				})

		data =
			comment 				: @comment()
			products 				:	productsToSend
			arrivalTime			: @selectedHour()
			scheduledDate		: @selectedDate()
			expiryTime			: @selectedExpiredHour()

		RESTfulService.makeRequest('POST', "/users/#{@user.id}/orders", data, (error, success, headers) =>
			if error
				console.log 'An error has ocurred while updating the user!'
				@headerMessage('Ha ocurrido un error generando la orden. Intenta más tarde.')
			else
				@orderGenerated(true)
				console.log 'Order has been created'
				setTimeout(( ->
						window.location.href = '../../store'
					), 2500)
				console.log success
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
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
		# $('.dropdown').dropdown()

	setHours: =>
		console.log 'It should set the new hours'
		if !!@selectedDay()
			@availableHours(@selectedDay().availableHours)
			@selectedDate(@selectedDay().date)
		else
			@availableHours([])
			@selectedDate('')

	setExpireHour: =>
		if !!@selectedHour()
			expireHour = moment(@selectedHour(), 'H:mm').add(1, 'hours')
			@selectedExpiredHour(expireHour.format('H:mm'))


	setAvailableDeliveryDateTime: =>
		if moment().hours() > 8 and moment().hours() < 22
			today = moment().add(2, 'hours').minutes(0)
		else
			today = moment().hours(8).minutes(0)
		tomorrow = moment().add(1, 'days').hours(8).minutes(0)
		aftertomorrow = moment().add(2, 'days').hours(8).minutes(0)
		@availableDateTime =
			today:
				date: today.format('YYYY-MM-DD')
				availableHours: @generateAvailableHours(today)
			tomorrow:
				date: tomorrow.format('YYYY-MM-DD')
				availableHours: @generateAvailableHours(tomorrow)
			aftertomorrow:
				date: aftertomorrow.format('YYYY-MM-DD')
				availableHours: @generateAvailableHours(aftertomorrow)

		@availableDays([
				@availableDateTime.today
				@availableDateTime.tomorrow
				@availableDateTime.aftertomorrow
			])
		console.log @availableDays()

	generateAvailableHours: (startHour) ->
		endHour = moment(startHour.format('YYYY-MM-DD'), 'YYYY-MM-DD').hours(19).minutes(0)
		hours = []
		difference = endHour.diff(startHour, 'hours')
		if difference > 0
			for i in [0..difference]
				hours.push(startHour.add(1, 'hours').format('H:mm'))

		return hours


	setOrderToPay: ->
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
