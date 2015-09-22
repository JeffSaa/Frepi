class CheckoutVM
	constructor: ->   
		# Observables
		@order = null
		@userName = ko.observable()
		@user = null
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
		window.location.href = '../../profile.html'

	setDOMElements: ->
		$('#departments-menu').sidebar({        
				transition: 'overlay'
			})

	showDepartments: ->    
		$('#departments-menu').sidebar('toggle')

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