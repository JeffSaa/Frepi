class AdminsVM extends AdminPageVM
	constructor: ->
		super()
		@shouldShowError = ko.observable(false)
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

	updateAdmin: ->

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

	showDelete: (user) =>
		@chosenUser.id(user.id)
		@chosenUser.name(user.name + ' ' + user.lastName)
		@chosenUser.isAdmin(user.administrator)
		$('.delete.modal').modal('show')

	fetchAdmins: =>
		RESTfulService.makeRequest('GET', "/administrator/admins", '', (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the admins!'
			else
				console.log success
				@currentAdmins(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchUsers: ->
		RESTfulService.makeRequest('GET', "/administrator/users", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred while fetching the clients!'
			else
				console.log success
				@currentUsers(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				@fetchAdmins()
		)

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.create.modal form')
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