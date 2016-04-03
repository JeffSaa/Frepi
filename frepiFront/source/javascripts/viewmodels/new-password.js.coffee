class ChangePasswordVM
	constructor: ->
		@setDOMElements()

	changePassword: ->
		$form = $('.ui.form')
		if $form.form('is valid')
			alert('Hmm, I dont know that to do here')
			# data =
			# 	email: $form.form('get value', 'email')
			# 	redirect_url: 'localhost:4567/store'
			# $('.reset-password .green.button').addClass('loading')
			# RESTfulService.makeRequest('POST', "/auth/password", data, (error, success, headers) =>
			# 	$('.reset-password .green.button').removeClass('loading')
			# 	if error
			# 		console.log 'An error has ocurred while fetching the categories!'
			# 		console.log error
			# 	else
			# 		console.log success
			# )

	setDOMElements: ->
		$('.ui.form').form(
				fields:
					newPassword:
						identifier: 'new-password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacía'
							}, {
								type: 'length[6]'
								prompt: 'La contraseña debe tener por lo menos 6 caracteres'
							}
						]
					match:
						identifier: 'confirmation-new-password'
						rules: [
							{
								type: 'match[new-password]'
								prompt: 'Las contraseñas no coinciden'
							}
						]
				inline: true
				keyboardShortcuts: false
			)

changePassword = new ChangePasswordVM
ko.applyBindings(changePassword)
