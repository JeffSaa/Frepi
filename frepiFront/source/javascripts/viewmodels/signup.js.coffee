class SignUpVM
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

	signUp: ->
		$form = $('.ui.form')
		$form.removeClass('error')
		if $form.form('is valid')
			data =
				name: $form.form('get value', 'firstName')
				address: $form.form('get value', 'address')
				last_name: $form.form('get value', 'lastName')
				email: $form.form('get value', 'email')
				phone_number: $form.form('get value', 'phoneNumber')
				password: $form.form('get value', 'password')
				password_confirmation: $form.form('get value', 'password')

			$('.ui.form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', '/users', data, (error, success, headers) =>
					if error
						$('.ui.form .green.button').removeClass('loading')
						$form.addClass('error')
						console.log 'An error has ocurred in the authentication.'
						errors = []
						$.each(error.responseJSON, (key, value) ->
								errors.push "#{key.charAt(0).toUpperCase() + key.slice(1)} #{value[0]}"
							)
						$form.form('add errors', errors)
					else
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						Config.setItem('userObject', JSON.stringify(success))
						window.location.href = '../store/index.html'
				)

	signWithFB: ->
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
													Config.setItem('headers', JSON.stringify(headers))
													Config.setItem('userObject', JSON.stringify(success.user))
													if success.user.administrator
														window.location.href = '../admin/index.html'
													else
														window.location.href = '../store/index.html'
										)
								)
							else
								console.log success
								Config.setItem('accessToken', headers.accessToken)
								Config.setItem('client', headers.client)
								Config.setItem('uid', headers.uid)
								Config.setItem('userObject', JSON.stringify(success.user))
								console.log 'FB user is registered in our DB'
								if success.user.administrator
									window.location.href = '../admin/index.html'
								else
									window.location.href = '../store/index.html'
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
					firstName:
						identifier: 'firstName'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite su nombre'
							}
						]
					lastName:
						identifier: 'lastName'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite su apellido'
							}
						]
					address:
						identifier: 'address'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite su dirección'
							}
						]
					phoneNumber:
						identifier: 'phoneNumber'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite su teléfono'
							}
						]
					email:
						identifier: 'email'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite un email'
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

signUp = new SignUpVM
ko.applyBindings(signUp)
