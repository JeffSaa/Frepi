class LoginVM
	constructor: ->		
		@errorTextResponse = ko.observable()
		@setDOMElements()

	login: ->
		data =
			email: $('#login-grid form').form('get value', 'username')
			password: $('#login-grid form').form('get value', 'password')
		$('#login').addClass('loading')

		RESTfulService.makeRequest('POST', '/auth/sign_in', data, (error, success, headers) =>
				if error
					$('#login').removeClass('loading')
					$('.ui.form').addClass('error')
					console.log 'An error has ocurred in the authentication.'
					@errorTextResponse(error.responseJSON.errors.toString())
				else
					encryptedClient = Encryptor.encrypt(headers.client, 'myKey')
					encryptedPassword = Encryptor.encrypt(data.password, 'myKey')
					encryptedToken = Encryptor.encrypt(headers.accessToken, 'myKey')
					encryptedUser = Encryptor.encrypt(data.email, 'myKey')
					Config.setItem('accessToken', encryptedToken)
					Config.setItem('client', encryptedClient)
					Config.setItem('pass', encryptedPassword)
					Config.setItem('user', encryptedUser)
					Config.setItem('uid', headers.uid)

					if success.data.user_type is 'user'
						window.location.href = '../../store.html'
					else
						window.location.href = '../../admin.html'
			)

	setDOMElements: ->
		$('.ui.form').form(
				fields: 
					username:
						identifier: 'username'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite un usuario'
							}, {
								type: 'email'
								prompt: 'Por favor digite un e-mail válido'
							}								
						]
					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite una contraseña'
							}, {
								type: 'length[6]'
								prompt: 'La contraseña debe tener por lo menos 6 caracteres'
							}								
						]
				inline: true
				keyboardShortcuts: false
			)

login = new LoginVM
ko.applyBindings(login)