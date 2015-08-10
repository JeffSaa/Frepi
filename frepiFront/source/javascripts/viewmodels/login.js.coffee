class LoginVM
	constructor: ->
		$('.ui.form').form(
				fields: 
					username:
						identifier: 'username'
						rules: [
							type: 'empty'
							prompt: 'Por favor digite un usuario'
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
			)


login = new LoginVM