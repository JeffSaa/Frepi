class window.LoginService
	@initFB = ->
		openFB.init appId: '433427986841087'

	@FBLogin = (callback) ->
		LoginService.initFB()
		FBcredentials = {}
		token = null
		openFB.login ((response) ->
			if response.status == 'connected'
				token = response.authResponse.accessToken
				openFB.api
					path: '/me'
					success: ((_this) ->
						(responseAPI) ->
							idFB = undefined
							idFB = responseAPI.id
							RESTfulService.makeRequest 'POST', '/auth/facebook/callback', { uid: idFB }, (error, success, headers) ->
								if error
									openFB.api
										path: '/' + idFB
										params:
											'fields': 'email,first_name,last_name,picture.height(400).width(400)'
											'access_token': token
										success: (responseAPI) ->
											FBcredentials =
												email: responseAPI.email
												name: responseAPI.first_name
												last_name: responseAPI.last_name
												image: responseAPI.picture.data.url
												uid: responseAPI.id
											RESTfulService.makeRequest 'POST', '/auth/facebook/callback', FBcredentials, ((_this) ->
												(error, success, headers) ->
													if error
														callback error, null
													else
														Config.destroyLocalStorage()
														Config.setItem 'headers', JSON.stringify(headers)
														Config.setItem 'userObject', JSON.stringify(success.user)
											)(this)
								else
									Config.destroyLocalStorage()
									Config.setItem 'headers', JSON.stringify(headers)
									Config.setItem 'userObject', JSON.stringify(success.user)
								callback null, success
					)(this)
			else if response.status == 'not_authorized'
				callback response.status, null
			else
				callback response.status, null
		), scope: 'public_profile,email'

	@regularLogin: (callback) =>
		$form = $('.ui.login.form')
		$form.removeClass('error')
		if $form.form('is valid')
			data =
				email: $form.form('get value', 'username')
				password: $form.form('get value', 'password')
			$('.login.button').addClass('loading')

			RESTfulService.makeRequest('POST', '/auth/sign_in', data, (error, success, headers) =>
					if error
						$('.login.button').removeClass('loading')
						$form.addClass('error')
						if error.responseJSON
							$form.form('add errors', error.responseJSON.errors)
						else
							$form.form('add errors', ['No se pudo establecer conexión'])
						callback(error, null)
					else
						Config.setItem('headers', JSON.stringify(headers))
						Config.setItem('userObject', JSON.stringify(success.data))
						callback(null, success)
				)
