class ProfileVM
	constructor: ->   
		# Observables
		@email = ko.observable('asd')
		@lastName = ko.observable()
		@name = ko.observable()
		@orders = ko.observableArray([])
		@phone = ko.observable()
		@profilePicture = ko.observable()
		@showEmptyMessage = ko.observable()

		# Methods to execute on instance
		@setUserInfo()
		@setDOMElements()
		@checkOrders = ko.computed( =>
				@showEmptyMessage(@orders().length is 0)
			)

	setUserInfo: ->
		user = JSON.parse(Config.getItem('userObject'))
		@email(user.email)
		@lastName(user.lastName or user.last_name)
		@name(user.name)
		@phone(user.phoneNumber or user.phone_number)
		@profilePicture(user.image)

	logout: ->
		

	setDOMElements: ->
		$('.secondary.menu .item').tab()
		$('#departments-menu').sidebar({        
				transition: 'overlay'
			})

	showDepartments: ->    
		$('#departments-menu').sidebar('toggle')

profile = new ProfileVM
ko.applyBindings(profile)