class SucursalsVM extends AdminPageVM
	constructor: ->
		super()
		@shouldShowSucursalsAlert = ko.observable(false)
		@sucursalsAlertText = ko.observable()
		@currentSucursals = ko.observableArray()
		@sucursalsPages = ko.observableArray()
		@chosenSucursal =
			id : ko.observable()
			name : ko.observable()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@fetchSucursals(1)
		@setRulesValidation()

	createSucursal: ->
		$form = $('.create.modal form')
		data =
			name: $form.form('get value', 'name')
			address: $form.form('get value', 'address')
			phoneNumber: $form.form('get value', 'phoneNumber')
			managerFullName: $form.form('get value', 'managerFullName')
			managerPhoneNumber: $form.form('get value', 'managerPhoneNumber')

		console.log data

		if $form.form('is valid')
			$('.create.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/stores/1/sucursals", data, (error, success, headers) =>
					$('.create.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the authentication.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						@currentSucursals.push(success)
						$('.create.modal').modal('hide')
				)

	updateSucursal: ->
		$form = $('.update.modal form')
		data =
			name: $form.form('get value', 'name')
			address: $form.form('get value', 'address')
			phoneNumber: $form.form('get value', 'phoneNumber')
			managerFullName: $form.form('get value', 'managerFullName')
			managerPhoneNumber: $form.form('get value', 'managerPhoneNumber')

		if $form.form('is valid')
			$('.update.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('PUT', "/stores/1/sucursals/#{@chosenSucursal.id()}", data, (error, success, headers) =>
					$('.update.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the admin.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						$('.update.modal').modal('hide')
						@fetchSucursals()
				)

	deleteSucursal: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/stores/1/sucursals/#{@chosenSucursal.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@currentSucursals.remove( (sucursal) =>
						return sucursal.id is @chosenSucursal.id()
					)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')				
		)

	showUpdate: (sucursal) =>
		@chosenSucursal.id(sucursal.id)
		@chosenSucursal.name(sucursal.name)
		$('.update.modal form')
			.form('set values',
					name 								: sucursal.name
					address							: sucursal.address
					phoneNumber 				: sucursal.phoneNumber
					managerFullName			: sucursal.managerFullName
					managerPhoneNumber 	: sucursal.managerPhoneNumber
				)
		$('.update.modal').modal('show')

	showDelete: (sucursal) =>
		@chosenSucursal.id(sucursal.id)
		@chosenSucursal.name(sucursal.name)
		$('.delete.modal').modal('show')

	fetchSucursalsPage: (page) =>
		$('table.sucursals .pagination .pages .item').removeClass('active')
		$("table.sucursals .pagination .pages .item:nth-of-type(#{page.num})").addClass('active')
		@fetchSucursals(page.num)

	fetchSucursals: (numPage) ->
		@isLoading(true)
		data =
			page : numPage

		RESTfulService.makeRequest('GET', "/stores/1/sucursals", data, (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the sucursals!'
				@shouldShowSucursalsAlert(true)
				@sucursalsAlertText('Hubo un problema buscando la información de las sucursales')
			else
				console.log success
				if success.length > 0
					pages = []
					for i in [0..headers.totalItems/10]
						pages.push({num: i+1})
					
					@sucursalsPages(pages)
					$("table.sucursals .pagination .pages .item:first-of-type").addClass('active')

					@currentSucursals(success)
					@shouldShowSucursalsAlert(false)
				else
					@shouldShowSucursalsAlert(true)
					@sucursalsAlertText('No hay sucursales')
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.ui.modal form')
			.form({
					fields:
						name:
							identifier: 'name'
							rules: [emptyRule]
						address:
							identifier: 'address'
							rules: [emptyRule]
						phoneNumber:
							identifier: 'phoneNumber'
							rules: [emptyRule]
						managerPhoneNumber:
							identifier: 'managerPhoneNumber'
							rules: [emptyRule]
						managerFullName:
							identifier: 'managerFullName'
							rules: [emptyRule]
					inline: true
					keyboardShortcuts: false
				})

sucursals = new SucursalsVM
ko.applyBindings(sucursals)