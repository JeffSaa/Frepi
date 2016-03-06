class LoginVM
	constructor: ->
		@setDOMElements()

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
