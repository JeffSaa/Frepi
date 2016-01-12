class window.AdminPageVM
	constructor: ->
		@shouldShowError = ko.observable(false)
		@isLoading = ko.observable(true)
		@user = JSON.parse(Config.getItem('userObject'))

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@setDOMElements()

	logout: ->
		# RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (error, success, headers) =>
		# 	if error
		# 		console.log 'An error has ocurred'
		# 	else
		# 		Config.destroyLocalStorage()
		# 		window.location.href = '../../login.html'
		# )
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'

	setUserInfo: =>
		tempUser = JSON.parse(Config.getItem('userObject'))
		# @user = ko.mapping.fromJS(tempUser)
		console.log tempUser
		console.log @user

	setDOMElements: ->
		$('.ui.create.modal')
			.modal('attach events', '.create.button', 'show')