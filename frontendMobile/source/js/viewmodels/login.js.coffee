class LoginVM
	constructor: ->
		@email = ko.observable()
		@password = ko.observable()
		@errorTextResponse = ko.observable()
		@shouldShowError = ko.observable(false)

	login: ->
		@shouldShowError(false)
		if !!@email() and !!@password()
			# data =
			# 	email: @email()
			# 	password: @password()
			data =
				email: 'shopper@frepi.com'
				password: 'frepi123'

			$('.loader .preloader-wrapper').addClass('active')
			$('form .btn').addClass('disabled')
			RESTfulService.makeRequest('POST', '/auth_shopper/sign_in', data, (error, success, headers) =>
					$('.loader .preloader-wrapper').removeClass('active')
					$('form .btn').removeClass('disabled')
					if error
						console.log 'An error has ocurred in the authentication.'
						console.log error.responseJSON
						@shouldShowError(true)
						if error.responseJSON
							@errorTextResponse(error.responseJSON.errors.toString())
						else
							@errorTextResponse('No se pudo establecer conexión!')
					else
						console.log success
						Config.setItem('accessToken', headers.accessToken)
						Config.setItem('client', headers.client)
						Config.setItem('uid', headers.uid)
						Config.setItem('userObject', JSON.stringify(success.data))
						window.location.href = '../../home.html'
				)
		else
			console.log 'INCOMPLETE FIELDS'
			@errorTextResponse('INCOMPLETE FIELDS')
			@shouldShowError(true)

login = new LoginVM
ko.applyBindings(login)