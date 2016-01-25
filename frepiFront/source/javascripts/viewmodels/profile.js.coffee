class ProfileVM extends TransactionalPageVM
	moment.locale('es')

	constructor: ->
		# Observables
		super()
		@errorLabelText = ko.observable()
		@currentOrders = ko.observableArray([])
		@showEmptyMessage = ko.observable()

		# Methods to execute on instance
		@setUserInfo()
		@setExistingSession()
		@fetchOrders()
		@setDOMElements()
		@shouldShowOrders()
		@setSizeButtons()
		@checkOrders = ko.computed( =>
				@showEmptyMessage(@currentOrders().length is 0)
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
				if headers.accessToken
						Config.setItem('headers', JSON.stringify(headers))

				@currentOrders(success)
		)

	profile: ->
		Config.setItem('showOrders', 'false')
		$('.secondary.menu .item').tab('change tab', 'account')

	orders: ->
		Config.setItem('showOrders', 'true')
		$('.secondary.menu .item').tab('change tab', 'history')

	parseOrderDate: (orders) ->
		for order in orders
			order.date = moment(order.date, moment.ISO_8601).format('YYYY-MM-DD HH:mm:ss')
			order.arrivalTime = moment(order.arrivalTime, moment.ISO_8601).format('HH:mm')
			order.expiryTime = moment(order.expiryTime, moment.ISO_8601).format('HH:mm')
			order.scheduledDate = moment(order.scheduledDate, moment.ISO_8601).format('YYYY-MM-DD')

		return orders

	shouldShowOrders: ->
		if Config.getItem('showOrders') is 'true'
			$('.secondary.menu .item').tab('change tab', 'history')

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

		$('.secondary.menu .item').tab(
				{
					cache: false
				}
			)
		$('#departments-menu').sidebar({
				transition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar button.basic', 'show')
		$('#shopping-cart').sidebar({
				dimPage: false
				transition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar .right.menu button', 'show')
		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show')

	showDepartments: ->
		$('#departments-menu').sidebar('toggle')

	showEditEmail: ->
		$('#edit-email').modal('show')

	showEditPassword: ->
		$('#edit-password').modal('show')

	showEditUser: ->
		$('#edit-user-info').modal('show')
		$('#edit-user-info form')
			.form('set values',
					firstName 	: @user.name()
					lastName 		: @user.lastName()
					phone 			: @user.phone()
				)

	showShoppingCart: ->
		$('#shopping-cart').sidebar('show')

	setStatus: (status, truncated) ->
		switch status
			when 'DELIVERING'
				if not truncated then 'En camino' else 'E'
			when 'DISPATCHED'
				if not truncated then 'Entregada' else 'E'
			when 'RECEIVED'
				if not truncated then 'Recibida' else 'R'
			when 'SHOPPING'
				if not truncated then 'Comprando' else 'C'

	updateUser: (attributeToUpdate) ->
		data = {}

		switch attributeToUpdate
			when 'email'
				if $('#edit-email form').form('is valid')
					data =
						email: $('#edit-email form').form('get value', 'new-email')

					$('#edit-email .submit').addClass('loading')
					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						$('#edit-email .submit').removeClass('loading')
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							console.log success
							if headers.accessToken
								Config.setItem('headers', JSON.stringify(headers))
							Config.setItem('userObject', JSON.stringify(success))
							credentials = JSON.parse(Config.getItem('credentials'))
							credentials.user = newEmail
							Config.setItem('credentials', credentials)
							@setUserInfo()
							$('#edit-email').modal('hide')
					)

			when 'password'
				if $('#edit-password form').form('is valid')
					data =
						password: $('#edit-password form').form('get value', 'new-password')

					$('#edit-password .submit').addClass('loading')
					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						$('#edit-password .submit').removeClass('loading')
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							console.log success
							Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
							Config.setItem('userObject', JSON.stringify(success))
							credentials = JSON.parse(Config.getItem('credentials'))
							credentials.pass = newPassword
							Config.setItem('credentials', credentials)
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

					$('#edit-user-info .submit').addClass('loading')
					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						$('#edit-user-info .submit').removeClass('loading')
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							console.log success
							Config.setItem('userObject', JSON.stringify(success))
							Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
							@setUserInfo()
							$('#edit-user-info').modal('hide')
					)

	setSizeButtons: ->
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

	DateFormatter: (datetime)->
		return moment(datetime, moment.ISO_8601).format('lll')

profile = new ProfileVM
ko.applyBindings(profile)