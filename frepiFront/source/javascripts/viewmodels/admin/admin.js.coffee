class AdminsVM extends AdminPageVM
	constructor: ->
		super()
		@adminsAlertText = ko.observable()
		@usersAlertText = ko.observable()
		@shouldShowUsersAlert = ko.observable(true)
		@shouldShowAdminsAlert = ko.observable(true)
		@currentAdmins = ko.observableArray()
		@currentUsers = ko.observableArray()
		@chosenUser =
			id : ko.observable()
			name : ko.observable()
			isAdmin : ko.observable()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@fetchUsers()
		@setRulesValidation()
		@setDOMProperties()

	activeTranslation: (active) ->
		if active then 'Si' else 'No'

	createAdmin: ->
		$form = $('.create.modal form')
		data =
			email: $form.form('get value', 'email')
			name: $form.form('get value', 'firstName')
			address: $form.form('get value', 'address')
			identification: $form.form('get value', 'cc')
			lastName: $form.form('get value', 'lastName')
			password: $form.form('get value', 'password')
			phoneNumber: $form.form('get value', 'phoneNumber')
			passwordConfirmation: $form.form('get value', 'confirmationPassword')

		console.log data

		if $form.form('is valid')
			$('.create.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/administrator/users", data, (error, success, headers) =>
					$('.create.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the admin.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						@currentAdmins.push(success)
						$('.create.modal').modal('hide')
				)

	updateUser: ->
		$form = $('.update.modal form')
		data =
			email: $form.form('get value', 'email')
			name: $form.form('get value', 'firstName')
			address: $form.form('get value', 'address')
			identification: $form.form('get value', 'cc')
			lastName: $form.form('get value', 'lastName')
			phoneNumber: $form.form('get value', 'phoneNumber')

		if $form.form('is valid')
			$('.update.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('PUT', "/administrator/users/#{@chosenUser.id()}", data, (error, success, headers) =>
					$('.update.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the admin.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						$('.update.modal').modal('hide')
						@fetchUsers()
				)

	deleteUser: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/administrator/users/#{@chosenUser.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				if @chosenUser.isAdmin()
					@currentAdmins.remove( (user) =>
							return user.id is @chosenUser.id()
						)
				else
					@currentUsers.remove( (user) =>
							return user.id is @chosenUser.id()
						)
					
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')				
		)

	showUpdate: (user) =>
		@chosenUser.id(user.id)
		$('.update.modal form')
			.form('set values',
					email						: user.email
					firstName				: user.name
					lastName				: user.lastName
					address					:	user.address
					cc							: user.identification
					password 				: user.password
					phoneNumber			: user.phoneNumber
				)
		$('.update.modal').modal('show')

	showDelete: (user) =>
		@chosenUser.id(user.id)
		@chosenUser.name(user.name + ' ' + user.lastName)
		@chosenUser.isAdmin(user.administrator)
		$('.delete.modal').modal('show')

	fetchAdmins: =>
		data =
			page : 1

		RESTfulService.makeRequest('GET', "/administrator/admins", data, (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the admins!'
				@shouldShowAdminsAlert(true)
				@adminsAlertText('Hubo un problema buscando la información de los administradores')
			else
				console.log success
				if success.length > 0
					@currentAdmins(success)
					@shouldShowAdminsAlert(false)
				else
					@shouldShowAdminsAlert(true)
					@adminsAlertText('No hay administradores')
				
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchUsers: ->
		@isLoading(true)
		data =
			page : 1

		RESTfulService.makeRequest('GET', "/administrator/users", data, (error, success, headers) =>
			if error
				@isLoading(false)
				console.log 'An error has ocurred while fetching the clients!'
				@shouldShowAdminsAlert(true)
				@adminsAlertText('Hubo un problema buscando la información de los usuarios')
			else
				console.log success
				if success.length > 0
					@currentUsers(success)
					@shouldShowUsersAlert(false)
				else
					@shouldShowUsersAlert(true)
					@usersAlertText('No hay usuarios')
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				@fetchAdmins()
		)

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.ui.modal form')
			.form({
					fields:
						cc:
							identifier: 'cc'
							rules: [emptyRule]
						firstName:
							identifier: 'firstName'
							rules: [emptyRule]
						lastName:
							identifier: 'lastName'
							rules: [emptyRule]
						address:
							identifier: 'address'
							rules: [emptyRule]
						phoneNumber:
							identifier: 'phoneNumber'
							rules: [emptyRule]
						password:
							identifier: 'password'
							rules: [
								emptyRule, {
									type: 'minLength[6]'
									prompt: 'La contraseña debe tener 6 caracteres mínimo'
								}
							]
						confirmationPassword:
							identifier: 'confirmationPassword'
							rules: [
								emptyRule, {
									type: 'match[password]'
									prompt: 'Las contraseñas no coinciden'
								}
							]
						email:
							identifier: 'email'
							rules: [
								emptyRule, {
									type: 'email'
									prompt: 'Ingrese un email válido'
								}
							]
					inline: true
					keyboardShortcuts: false
				})

	setDOMProperties: ->

admins = new AdminsVM
ko.applyBindings(admins)