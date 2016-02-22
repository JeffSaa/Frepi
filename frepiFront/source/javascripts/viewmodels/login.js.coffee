class LoginVM
	constructor: ->
		@errorTextResponse = ko.observable()
		@initFB()
		@setDOMElements()

	initFB: ->
		FB.init({
				appId: 433427986841087
				cookie: true
				version: 'v2.4'
			})

	login: ->
		console.log 'normal log'
		$form = $('.ui.form')
		$form.removeClass('error')
		if $form.form('is valid')
			data =
				email: $('#login-grid form').form('get value', 'username')
				password: $('#login-grid form').form('get value', 'password')
			$('#login').addClass('loading')

			RESTfulService.makeRequest('POST', '/auth/sign_in', data, (error, success, headers) =>
					if error
						$('#login').removeClass('loading')
						$form.addClass('error')
						console.log 'An error has ocurred in the authentication.'
						if error.responseJSON
							@errorTextResponse(error.responseJSON.errors.toString())
						else
							@errorTextResponse('No se pudo establecer conexión')
					else
						console.log success
						Config.destroyLocalStorage()
						Config.setItem('headers', JSON.stringify(headers))
						Config.setItem('credentials', JSON.stringify(data))
						Config.setItem('userObject', JSON.stringify(success.data))

						if success.data.administrator
							window.location.href = '../../admin/products.html'
						else
							window.location.href = '../../store'
				)

	loginFB: ->
		console.log 'fb log'
		FBcredentials = {}

		FB.login(((response) ->
				if response.status is 'connected'
					console.log 'User logged into FrepiTest'
					console.log "FB user ID is #{response.authResponse.userID}"

					RESTfulService.makeRequest('POST', '/auth/facebook/callback', {uid: response.authResponse.userID}, (error, success, headers) =>
							if error
								console.log 'First time this user is trying to log with FB'
								console.log 'Now the request with user info is going to be sent...'
								FB.api('/me', {fields: 'email, first_name, last_name, picture.height(400).width(400)'}, (responseAPI) ->
										console.log 'Successful login for: ' + responseAPI.name
										console.log 'Successful login for: ' + responseAPI.email
										FBcredentials =
											email: responseAPI.email
											name: responseAPI.first_name
											last_name: responseAPI.last_name
											image: responseAPI.picture.data.url
											uid: responseAPI.id

										console.log responseAPI
										RESTfulService.makeRequest('POST', '/auth/facebook/callback', FBcredentials, (error, success, headers) =>
												if error
													console.log 'The user couldnt be created'
												else
													console.log success
													Config.destroyLocalStorage()
													Config.setItem('headers', JSON.stringify(headers))
													Config.setItem('userObject', JSON.stringify(success.user))
													if success.user.administrator
														window.location.href = '../../admin/products.html'
													else
														window.location.href = '../../store'
										)
								)
							else
								console.log success
								Config.destroyLocalStorage()
								Config.setItem('headers', JSON.stringify(headers))
								Config.setItem('userObject', JSON.stringify(success.user))
								console.log 'FB user is registered in our DB'
								if success.user.administrator
									window.location.href = '../../admin/products.html'
								else
									window.location.href = '../../store'
					)
				else if response.status is 'not_authorized'
					console.log 'Doesnt logged into FrepiTest!'
				else
					console.log 'Doesnt logged into Facebook!'
			), {
					scope: 'public_profile,email'
			})

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
