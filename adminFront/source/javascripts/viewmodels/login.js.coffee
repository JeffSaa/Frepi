class LoginVM
	constructor: ->		
		@errorTextResponse = ko.observable()
		@setDOMElements()

	login: ->
		$form = $('.ui.form')
		$form.removeClass('error')
		if $form.form('is valid')
			data =
				email: $('#login-grid form').form('get value', 'username')
				password: $('#login-grid form').form('get value', 'password')
			$('#login').addClass('loading')

			RESTfulService.makeRequest('POST', '/auth_supervisor/sign_in', data, (error, success, headers) =>
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
						Config.setItem('headers', JSON.stringify(headers))
						Config.setItem('credentials', JSON.stringify(data))
						Config.setItem('userObject', JSON.stringify(success.data))
						window.location.href = '../../home'

						# if success.data.user_type is 'USER'
						# 	window.location.href = '../../store/index.html'
						# else
						# 	window.location.href = '../../admin.html'
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