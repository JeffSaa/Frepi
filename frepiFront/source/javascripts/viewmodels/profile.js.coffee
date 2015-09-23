class ProfileVM
	constructor: ->   
		# Observables
		@session =
			categories: ko.observableArray()
			currentOrder:
				numberProducts: ko.observable()
				products: ko.observableArray()
				price: ko.observable()
				sucursalId: null
		@email = ko.observable('asd')
		@errorLabelText = ko.observable()
		@lastName = ko.observable()
		@name = ko.observable()
		@orders = ko.observableArray([])
		@phone = ko.observable()
		@profilePicture = ko.observable()
		@showEmptyMessage = ko.observable()
		@userName = ko.observable()

		# General variables
		@user = null

		# Methods to execute on instance
		@setUserInfo()
		@setExistingSession()
		@fetchOrders()		
		@setDOMElements()
		@shouldShowOrders()
		@checkOrders = ko.computed( =>
				@showEmptyMessage(@orders().length is 0)
				# setTimeout((=>
				# 		@session.currentOrder.numberProducts("#{@session.categories().length} items")
				# 	), 5000)
			)

	closeEditEmail: ->
		$('#edit-email').modal('hide')
		$('#edit-email form').form('clear')

	closeEditPassword: ->
		$('#edit-password').modal('hide')
		$('#edit-password form').form('clear')

	fetchOrders: ->
		console.log 'Fetching the orders...'
		RESTfulService.makeRequest('GET', "/users/#{@user.id}/orders", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred while fetching the orders!'
			else
				console.log success
				Config.setItem('accessToken', headers.accessToken)
				Config.setItem('client', headers.client)
				Config.setItem('uid', headers.uid)
				for order in success
					order.date = new Date(order.date).toLocaleDateString()
				
				@orders(success)
		)

	setExistingSession: ->
		session = Config.getItem('currentSession')

		if session
			session = JSON.parse(Config.getItem('currentSession'))
			@session.categories(session.categories)
			@session.currentOrder.numberProducts(session.currentOrder.numberProducts)
			@session.currentOrder.products(session.currentOrder.products)
			@session.currentOrder.price(session.currentOrder.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId
		else
			@session.categories([])
			@session.currentOrder.numberProducts('0 items')
			@session.currentOrder.products([])
			@session.currentOrder.price(0.0)
			@session.currentOrder.sucursalId = 1

	setUserInfo: ->
		@user = JSON.parse(Config.getItem('userObject'))
		console.log @user
		@email(@user.email)
		@lastName(@user.lastName or @user.last_name)
		@name(@user.name)
		@phone(@user.phoneNumber or @user.phone_number)
		@profilePicture(@user.image)
		@userName(@user.name.split(' ')[0])

	shouldShowOrders: ->
		if Config.getItem('showOrders') is 'true'
			$('.secondary.menu .item').tab('change tab', 'history')

	logout: ->
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'
		
	setDOMElements: ->
		$('#edit-email form').form({
				fields:
					newEmail:
						identifier: 'new-email'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacío'
							}, {
								type: 'email'
								prompt: 'Por favor digite una dirección de correo válida'
							}
						]
					match:
						identifier: 'confirmation-new-email'
						rules: [
							{
								type: 'match[new-email]'
								prompt: 'Por favor ponga el mismo correo'
							}, {
								type: 'empty'
								prompt: 'No puede estar vacío'
							}, {
								type: 'email'
								prompt: 'Por favor digite una dirección de correo válida'
							}
						]

					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacía'
							}
						]
				inline: true
				keyboardShortcuts: false
			})
		$('#edit-password form').form({
				fields:
					newPassword:
						identifier: 'new-password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacía'
							}
						]
					match:
						identifier: 'confirmation-new-password'
						rules: [
							{
								type: 'match[new-password]'
								prompt: 'Por favor ponga la misma contraseña'
							}, {
								type: 'empty'
								prompt: 'No puede estar vacía'
							}
						]
					currentPassword:
						identifier: 'current-password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacía'
							}
						]
				inline: true
				keyboardShortcuts: false
			})
		$('#edit-user-info form').form({
				fields:
					firstName:
						identifier: 'first-name'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacío'
							}							
						]
					lastName:
						identifier: 'last-name'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacío'
							}							
						]
					phone:
						identifier: 'phone'
						rules: [
							{
								type: 'regExp[/^[0-9 ().+-]{7,16}$/]'
								prompt: 'El teléfono debe ser numérico'
							}							
						]
					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacío'
							}							
						]
				inline: true
				keyboardShortcuts: false
			})
		$('#edit-email').modal(
				onHidden: ->
					$('#edit-email form').form('clear')
			).modal('attach events', '#edit-email .cancel.button', 'hide')

		$('#edit-password').modal(
				onHidden: ->
					$('#edit-password form').form('clear')
			).modal('attach events', '#edit-password .cancel.button', 'hide')

		$('#edit-user-info').modal(
				onHidden: ->
					console.log 'Im closing user'
			).modal('attach events', '#edit-user-info .cancel.button', 'hide')

		$('.secondary.menu .item').tab()
		$('#departments-menu').sidebar({        
				transition: 'overlay'
			})

	showDepartments: ->    
		$('#departments-menu').sidebar('toggle')

	showEditEmail: ->
		$('#edit-email').modal('show')

	showEditPassword: ->
		$('#edit-password').modal('show')

	showEditUser: ->
		$('#edit-user-info').modal('show')

	setStatus: (status, truncated) ->
		switch status
			when 'delivering'
				if not truncated then 'En camino' else 'E'
			when 'dispatched'
				if not truncated then 'Entregada' else 'E'
			when 'received'
				if not truncated then 'Recibida' else 'R'

	updateUser: (attributeToUpdate) ->
		data = {}

		switch attributeToUpdate
			when 'email'
				if $('#edit-email form').form('is valid')
					newEmail = $('#edit-email form').form('get value', 'new-email')

					data = 
						email: newEmail

					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							console.log success
							Config.setItem('userObject', JSON.stringify(success))
							Config.setItem('accessToken', headers.accessToken)
							Config.setItem('client', headers.client)
							Config.setItem('user', newEmail)
							Config.setItem('uid', headers.uid)
							@setUserInfo()
							$('#edit-email').modal('hide')
					)
				# newEmail = $('#edit-email form').form('get value', 'new-email')
				# confirmationEmail = $('#edit-email form').form('get value', 'confirmation-new-email')
				# currentPassword = $('#edit-email form').form('get value', 'password')
				# storedPassword = Config.getItem('pass')
				

			when 'password'
				
				# confirmationPassword = $('#edit-password form').form('get value', 'confirmation-new-password')
				# currentPassword = $('#edit-password form').form('get value', 'current-password')
				# storedPassword = Config.getItem('pass')

				if $('#edit-password form').form('is valid')
					newPassword = $('#edit-password form').form('get value', 'new-password')

					data = 
						password: newPassword

					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							console.log success
							Config.setItem('userObject', JSON.stringify(success))
							Config.setItem('accessToken', headers.accessToken)
							Config.setItem('client', headers.client)
							Config.setItem('pass', newPassword)
							Config.setItem('uid', headers.uid)
							@setUserInfo()
							$('#edit-password').modal('hide')
					)

			when 'user'
				if $('#edit-user-info form').form('is valid')
					console.log 'Editing user info'
					newFirstName = $('#edit-user-info form').form('get value', 'first-name')
					newLastName = $('#edit-user-info form').form('get value', 'last-name')
					newPhone = $('#edit-user-info form').form('get value', 'phone')

					data =
						name: newFirstName
						last_name: newLastName
						phone_number: newPhone

					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							console.log success
							Config.setItem('userObject', JSON.stringify(success))
							Config.setItem('accessToken', headers.accessToken)
							Config.setItem('client', headers.client)
							Config.setItem('uid', headers.uid)
							@setUserInfo()
							$('#edit-password').modal('hide')
					)				

profile = new ProfileVM
ko.applyBindings(profile)