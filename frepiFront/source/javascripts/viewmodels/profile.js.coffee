class ProfileVM
	constructor: ->   
		# Observables
		@email = ko.observable('asd')
		@lastName = ko.observable()
		@name = ko.observable()
		@orders = ko.observableArray([])
		@phone = ko.observable()
		@profilePicture = ko.observable()
		@showEmptyMessage = ko.observable()

		# General variables
		@user = JSON.parse(Config.getItem('userObject'))

		# Methods to execute on instance
		@getOrders()
		@setUserInfo()
		@setDOMElements()
		@checkOrders = ko.computed( =>
				@showEmptyMessage(@orders().length is 0)
			)

	getOrders: ->
		console.log 'Fetching the orders...'
		RESTfulService.makeRequest('GET', "/users/#{@user.id}/orders", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred while fetching the orders!'
			else
				console.log success
				Config.setItem('accessToken', headers.accessToken)
				Config.setItem('client', headers.client)
				Config.setItem('uid', headers.uid)
				@orders(success)
		)

	setUserInfo: ->
		@email(@user.email)
		@lastName(@user.lastName or @user.last_name)
		@name(@user.name)
		@phone(@user.phoneNumber or @user.phone_number)
		@profilePicture(@user.image)

	logout: ->
		
	setDOMElements: ->
		$('.secondary.menu .item').tab()
		$('#departments-menu').sidebar({        
				transition: 'overlay'
			})

	showDepartments: ->    
		$('#departments-menu').sidebar('toggle')

	setStatus: (status, truncated) ->
		switch status
			when 'delivering'
				if not truncated then 'En camino' else 'E'
			when 'dispatched'
				if not truncated then 'Entregada' else 'E'
			when 'received'
				if not truncated then 'Recibida' else 'R'

profile = new ProfileVM
ko.applyBindings(profile)