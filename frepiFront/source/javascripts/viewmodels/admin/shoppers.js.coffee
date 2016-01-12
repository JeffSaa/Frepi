class ShoppersVM extends AdminPageVM
	constructor: ->
		super()
		@shouldShowError = ko.observable(false)
		@currentShoppers = ko.observableArray()
		@chosenShopper =
			id : ko.observable()
			name : ko.observable()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@fetchShoppers()
		@setRulesValidation()
		@setDOMProperties()

	createShopper: ->
		$form = $('.create.modal form')
		data =
			email: $form.form('get value', 'email')
			identification: $form.form('get value', 'cc')
			lastName: $form.form('get value', 'lastName')
			firstName: $form.form('get value', 'firstName')			
			phoneNumber: $form.form('get value', 'phoneNumber')
			shopperType: $form.form('get value', 'shopperType')

		console.log data

		if $form.form('is valid')
			$('.create.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/shoppers", data, (error, success, headers) =>
					$('.create.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the shopper.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						@currentShoppers.push(success)
						$('.create.modal').modal('hide')
				)

	deleteShopper: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/shoppers/#{@chosenShopper.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@currentShoppers.remove( (shopper) =>
						return shopper.id is @chosenShopper.id()
					)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')				
		)

	showDelete: (shopper) =>
		@chosenShopper.id(shopper.id)
		@chosenShopper.name(shopper.firstName+' '+shopper.lastName)
		$('.delete.modal').modal('show')

	fetchShoppers: ->
		RESTfulService.makeRequest('GET', "/shoppers", '', (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the shoppers!'
			else
				console.log success
				@currentShoppers(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.create.modal form')
			.form({
					fields:
						cc:
							identifier: 'cc'
							rules: [emptyRule]
						firstName:
							identifier: 'firstName'
							rules: [emptyRule]
						lastName:
							identifier: 'lastName'
							rules: [emptyRule]
						phoneNumber:
							identifier: 'phoneNumber'
							rules: [emptyRule]
						email:
							identifier: 'email'
							rules: [
								emptyRule, {
									type: 'email'
									prompt: 'Ingrese un email válido'
								}
							]
						shopperType:
							identifier: 'shopperType'
							rules: [emptyRule]
					inline: true
					keyboardShortcuts: false
				})

	setDOMProperties: ->
		$('.create.modal .dropdown')
			.dropdown()

	setSizeSidebar: ->
		if $(window).width() < 480
			$('#shopping-cart').removeClass('wide')
		else
			$('#shopping-cart').addClass('wide')

		$(window).resize(->
			if $(window).width() < 480
				$('#shopping-cart').removeClass('wide')
			else
				$('#shopping-cart').addClass('wide')
		)

shoppers = new ShoppersVM
ko.applyBindings(shoppers)