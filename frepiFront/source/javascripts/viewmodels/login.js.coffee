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

	setDOMElements: ->
		$('.ui.form').form(
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

login = new LoginVM
ko.applyBindings(login)
