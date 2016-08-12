class CheckoutVM
	constructor: ->
		# Observables
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
		@phoneNumber = ko.observable(@user.phoneNumber or @user.phone_number)
		@setDOMElements()
		@setExistingSession()
		@setSizeButtons()
		@setAvailableDeliveryDateTime()
		@finalOrderPrice = ko.computed( =>
				finalPrice = 0
				if @session.currentOrder.price() > 80000 and @user.discount > 0
					finalPrice = @session.currentOrder.price() - @user.discount
				else
					finalPrice = @session.currentOrder.price()

				return finalPrice
			)

	seeDeliveryRight: ->
		$('.form .field').removeClass('error')
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
		isInvalidPhone = !@phoneNumber() or not @isValidPhoneNumber(@phoneNumber())
		if !!@selectedDay() and !!@selectedHour() and !!@address() and !isInvalidPhone
			$('#delivery-icon').removeClass('active')
			$('#confirm-icon').addClass('active')
			$('#delivery').transition('fade right')
			$('#confirm').transition('fade left')
		else
			$('.address.field').addClass('error') if !@address()
			$('.date.field').addClass('error') if !@selectedDay()
			$('.time.field').addClass('error') if !@selectedHour()
			$('.phone.field').addClass('error') if isInvalidPhone

	logout: ->
		RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (error, success, headers) =>
			if error
			else
				Config.destroyLocalStorage()
				window.location.href = '../index.html'
		)

	cancel: ->
		window.location.href = 'store/index.html'

	generate: ->

		productsToSend = []

		for product in @session.currentOrder.products()
			productsToSend.push({
					comment: product.comment
					id: product.id
					quantity: product.quantity
				})

		data =
			address					: @address()
			comment 				: @comment()
			telephone				: @phoneNumber()
			products 				:	productsToSend
			arrivalTime			: @selectedHour()
			scheduledDate		: @selectedDate()
			expiryTime			: @selectedExpiredHour()


		$('.generate.button').addClass('loading')
		RESTfulService.makeRequest('POST', "/users/#{@user.id}/orders", data, (error, success, headers) =>
			$('.generate.button').removeClass('loading')
			if error
				@headerMessage('Ha ocurrido un error generando la orden. Intenta más tarde.')
			else
				@session.currentOrder.numberProducts('0 items')
				@session.currentOrder.products([])
				@session.currentOrder.price(0.0)

				@saveSession()
				$('.successful.modal').modal('show')
		)

	goToProfile: ->
		Config.setItem('showOrders', 'false')
		window.location.href = 'store/profile.html'

	goToOrders: ->
		Config.setItem('showOrders', 'true')
		window.location.href = 'store/profile.html'

	setDOMElements: ->
		$('#departments-menu').sidebar({
				transition: 'overlay'
				mobileTransition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar .basic.button', 'show')
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('setting', 'mobileTransition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show')
		$('.time.field')
			.popup({inline: true})
		$('.successful.modal')
			.modal(
				onHidden: ->
					window.location.href = 'store/index.html'
			)

	inputGotFocus: (data, event) ->
		$(event.target.parentElement).removeClass('error')

	isValidPhoneNumber: (phoneNumber) ->
		# TODO: Use library for validating phone number or add other restrictions
		phoneNumber.length > 6 and not(phoneNumber.match(/[^\s|\d]/g))

	setHours: =>
		$('.date.field').removeClass('error')
		if !!@selectedDay()
			@availableHours(@selectedDay().availableHours)
			@selectedDate(@selectedDay().date)
			if @selectedDay().availableHours.length is 0 then $('.hours.dropdown').addClass('disabled') else $('.hours.dropdown').removeClass('disabled')
		else
			@availableHours([])
			@selectedDate('')

	setExpireHour: =>
		$('.time.field').removeClass('error')
		if !!@selectedHour()
			expireHour = moment(@selectedHour(), 'H:mm').add(1, 'hours')
			@selectedExpiredHour(expireHour.format('H:mm'))


	setAvailableDeliveryDateTime: =>
		if moment().hours() < 17
			if moment().hours() > 7
				today = moment().add(1, 'hours').minutes(0)
			else
				today = moment().hours(7).minutes(0)
		else
			today = moment().hours(moment().hours()).minutes(0)

		tomorrow = moment().add(1, 'days').hours(7).minutes(0)
		aftertomorrow = moment().add(2, 'days').hours(7).minutes(0)
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

	generateAvailableHours: (startHour) ->
		endHour = moment(startHour.format('YYYY-MM-DD'), 'YYYY-MM-DD').hours(16).minutes(0)
		hours = []
		difference = endHour.diff(startHour, 'minutes')
		if difference > 0
			for i in [0..difference/60]
				hours.push(startHour.add(1, 'hours').format('HH:00'))

		return hours

	saveSession: ->
		session =
			categories: @session.categories()
			currentStore: ko.mapping.toJS(@session.currentStore)
			currentSucursal: ko.mapping.toJS(@session.currentSucursal)
			currentDeparmentID: @session.currentDeparmentID
			signedUp: @session.signedUp()
			sucursals: @session.sucursals()
			currentOrder:
				numberProducts: @session.currentOrder.numberProducts()
				products: @session.currentOrder.products()
				price: @session.currentOrder.price()
				sucursalId: @session.currentOrder.sucursalId

		Config.setItem('currentSession', JSON.stringify(session))

	setExistingSession: ->
		session = Config.getItem('currentSession')

		if session
			@userName(@user.name.split(' ')[0])
			order = JSON.parse(Config.getItem('orderToPay'))
			session = JSON.parse(Config.getItem('currentSession'))
			@session.currentStore = ko.mapping.fromJS(session.currentStore)
			@session.currentSucursal = ko.mapping.fromJS(session.currentSucursal)
			@session.currentDeparmentID = session.currentDeparmentID
			@session.categories(session.categories)
			@session.sucursals(session.sucursals)
			@session.signedUp(session.signedUp)
			@session.currentOrder.numberProducts(order.numberProducts)
			@session.currentOrder.products(order.products)
			@session.currentOrder.price(order.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId

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

RouteValidator.checkUser()
RouteValidator.checkCart()
checkout = new CheckoutVM
ko.applyBindings(checkout)
