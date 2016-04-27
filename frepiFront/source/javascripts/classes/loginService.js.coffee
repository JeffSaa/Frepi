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
					console.log 'User logged into FrepiTest'
					console.log "FB user ID is #{response.authResponse.userID}"

					RESTfulService.makeRequest('POST', '/auth/facebook/callback', {uid: response.authResponse.userID}, (error, success, headers) =>
							if error
								console.log 'First time this user is trying to log with FB'
								console.log 'Now the request with user info is going to be sent...'
								FB.api('/me', {fields: 'email, first_name, last_name, picture.height(400).width(400)'}, (responseAPI) ->
										console.log 'Successful login for: ' + responseAPI.name
										console.log 'Successful login for: ' + responseAPI.email
										FBInfo =
											email: responseAPI.email
											name: responseAPI.first_name
											last_name: responseAPI.last_name
											image: responseAPI.picture.data.url
											uid: responseAPI.id

										console.log responseAPI
										RESTfulService.makeRequest('POST', '/auth/facebook/callback', FBInfo, (error, success, headers) =>
												if error
													console.log 'The user couldnt be created'
													callback(error, null)
												else
													console.log success
													Config.destroyLocalStorage()
													Config.setItem('headers', JSON.stringify(headers))
													Config.setItem('userObject', JSON.stringify(success.user))

										)
								)
							else
								console.log success
								Config.destroyLocalStorage()
								Config.setItem('headers', JSON.stringify(headers))
								Config.setItem('userObject', JSON.stringify(success.user))
								console.log 'FB user is registered in our DB'

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

	@regularLogin: (isLoginFromStore = false) =>
		console.log 'normal log'
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
					else
						Config.setItem('headers', JSON.stringify(headers))
						# Config.setItem('credentials', JSON.stringify(data))
						Config.setItem('userObject', JSON.stringify(success.data))

						unless isLoginFromStore
							if success.data.administrator
								window.location.href = 'admin/products.html'
							else
								window.location.href = 'store/index.html'
						# else
						# 	callback(null, data)
				)
