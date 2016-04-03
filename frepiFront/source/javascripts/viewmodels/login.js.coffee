class LoginVM
	constructor: ->
		@setDOMElements()

	login: ->
		LoginService.regularLogin(true)
		# REVIEW: I had to add this timeout because there is a lag between the userObject
		# is set in LocalStorage in LoginService and here when I try to get the item from
		# the LocalStorage, so the real value it's not updating instantly
		setTimeout((=>
				if Config.getItem('userObject')
					@setUserInfo()
					$('.login.modal').modal('hide')
			), 1000)

	loginFB: ->
		LoginService.FBLogin( (error, success) =>
					if error
						console.log 'An error ocurred while trying to login to FB'
					else
						if success.user.administrator
							window.location.href = 'admin/products.html'
						else
							window.location.href = 'store/index.html'
			)

	resetPassword: ->
		$form = $('.reset-password .form')
		if $form.form('is valid')
			data =
				email: $form.form('get value', 'email')
				redirect_url: 'localhost:4567/change-password.html'
			$('.reset-password .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/auth/password", data, (error, success, headers) =>
				$('.reset-password .green.button').removeClass('loading')
				if error
					console.log 'An error has ocurred while fetching the categories!'
					console.log error
				else
					console.log success
					$('.reset-password .green.button').addClass('disabled')
					$('.reset-password .success.segment').transition('fade down')
					setTimeout((->
							$('.reset-password.modal').modal('hide')
						), 5000)
			)

	setDOMElements: ->
		$('.reset-password .form').form(
				fields:
					email:
						identifier: 'email'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner el correo'
							}, {
								type: 'email'
								prompt: 'La dirección de correo no es válida'
							}
						]
				inline: true
				keyboardShortcuts: false
			)
		$('.ui.login.form').form(
				fields:
					username:
						identifier: 'username'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner un usuario'
							}, {
								type: 'email'
								prompt: 'La dirección de correo no es válida'
							}
						]
					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner una contraseña'
							}, {
								type: 'length[6]'
								prompt: 'La contraseña debe tener por lo menos 6 caracteres'
							}
						]
				inline: true
				keyboardShortcuts: false
			)
		$('.reset-password.modal').modal(
				onHidden: ->
					$('.reset-password form').form('clear')
			)
			.modal('attach events', '.reset.trigger', 'show')
			.modal('attach events', '.reset-password .cancel.button', 'hide')

login = new LoginVM
ko.applyBindings(login)
