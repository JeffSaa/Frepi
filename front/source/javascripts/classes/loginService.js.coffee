class window.LoginService
	@initFB: ->
		FB.init({
				appId: 433427986841087
				cookie: true
				version: 'v2.4'
			})

	@FBLogin: (callback) =>
		@initFB()
		FBInfo = {}
		FB.login(((response) ->
				if response.status is 'connected'
					RESTfulService.makeRequest('POST', '/auth/facebook/callback', {uid: response.authResponse.userID}, (error, success, headers) =>
							if error
								FB.api('/me', {fields: 'email, first_name, last_name, picture.height(400).width(400)'}, (responseAPI) ->
										FBInfo =
											email: responseAPI.email
											name: responseAPI.first_name
											last_name: responseAPI.last_name
											image: responseAPI.picture.data.url
											uid: responseAPI.id

										RESTfulService.makeRequest('POST', '/auth/facebook/callback', FBInfo, (error, success, headers) =>
												if error
													console.log 'The user couldnt be created'
													callback(error, null)
												else
													Config.destroyLocalStorage()
													Config.setItem('headers', JSON.stringify(headers))
													Config.setItem('userObject', JSON.stringify(success.user))
										)
								)
							else
								Config.destroyLocalStorage()
								Config.setItem('headers', JSON.stringify(headers))
								Config.setItem('userObject', JSON.stringify(success.user))

							callback(null, success)
					)
				else if response.status is 'not_authorized'
					console.log 'Doesnt logged into FrepiTest!'
					callback(response.status, null)
				else
					console.log 'Doesnt logged into Facebook!'
					callback(response.status, null)
			), {
					scope: 'public_profile,email'
			})

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
						console.log 'An error has ocurred in the authentication.'
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
