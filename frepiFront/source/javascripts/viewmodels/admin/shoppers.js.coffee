class ShoppersVM extends AdminPageVM
	constructor: ->
		super()
		@shouldShowShoppersAlert = ko.observable(true)
		@shoppersAlertText = ko.observable()
		@currentShoppers = ko.observableArray()
		@shoppersPages = ko.observableArray()
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

	updateShopper: ->
		$form = $('.update.modal form')
		data =
			email: $form.form('get value', 'email')
			identification: $form.form('get value', 'cc')
			lastName: $form.form('get value', 'lastName')
			firstName: $form.form('get value', 'firstName')
			phoneNumber: $form.form('get value', 'phoneNumber')
			shopperType: $form.form('get value', 'shopperType')

		if $form.form('is valid')
			$('.update.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('PUT', "/shoppers/#{@chosenShopper.id()}", data, (error, success, headers) =>
					$('.update.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the admin.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						$('.update.modal').modal('hide')
						@fetchShoppers()
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

	showUpdate: (shopper) =>
		@chosenShopper.id(shopper.id)
		$('.update.modal form')
			.form('set values',
					email					: shopper.email
					cc 				 	  : shopper.identification
					lastName		  : shopper.lastName
					firstName			: shopper.firstName
					phoneNumber 	: shopper.phoneNumber
					shopperType		: shopper.shopperType
				)
		$('.update.modal').modal('show')

	showDelete: (shopper) =>
		@chosenShopper.id(shopper.id)
		@chosenShopper.name(shopper.firstName+' '+shopper.lastName)
		$('.delete.modal').modal('show')

	fetchShoppersPage: (page) =>
		$('table.shoppers .pagination .pages .item').removeClass('active')
		$("table.shoppers .pagination .pages .item:nth-of-type(#{page.num})").addClass('active')
		@fetchShoppers(page.num)

	fetchShoppers: (numPage = 1) ->
		@isLoading(true)
		data =
			page : numPage

		RESTfulService.makeRequest('GET', "/shoppers", data, (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the shoppers!'
				@shouldShowShoppersAlert(true)
				@shoppersAlertText('Hubo un problema buscando la información de los shoppers')
			else
				console.log success
				if success.length > 0
					if @shoppersPages().length is 0
						pages = []
						for i in [0..headers.totalItems/10]
							pages.push({num: i+1})
						
						@shoppersPages(pages)
						$("table.shoppers .pagination .pages .item:first-of-type").addClass('active')
					@currentShoppers(success)
					@shouldShowShoppersAlert(false)
				else
					@shouldShowShoppersAlert(true)
					@shoppersAlertText('No hay shoppers')

				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.ui.modal form')
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
								{
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
		$('.ui.modal .dropdown')
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