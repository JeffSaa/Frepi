class SupervisorsVM extends AdminPageVM
	constructor: ->
		super()
		@shouldShowSupervisorsAlert = ko.observable(true)
		@supervisorsAlertText = ko.observable()
		@currentSupervisors = ko.observableArray()
		@chosenSupervisor =
			id : ko.observable()
			name : ko.observable()

		@supervisorsPages =
			allPages: []
			activePage: 0
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@fetchSupervisors()
		@setRulesValidation()
		@setDOMProperties()

	createSupervisor: ->
		$form = $('.create.modal form')
		data =
			email: $form.form('get value', 'email')
			identification: $form.form('get value', 'cc')
			firstName: $form.form('get value', 'firstName')
			lastName: $form.form('get value', 'lastName')
			password: $form.form('get value', 'password')
			phoneNumber: $form.form('get value', 'phoneNumber')
			passwordConfirmation: $form.form('get value', 'confirmationPassword')

		if $form.form('is valid')
			$('.create.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/supervisors", data, (error, success, headers) =>
					$('.create.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the supervisor.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						@currentSupervisors.push(success)
						$('.create.modal').modal('hide')
				)

	updateSupervisor: ->
		$form = $('.update.modal form')
		passwordConfirmation = $form.form('get value', 'confirmationPasswordUpdate')
		data =
			email: $form.form('get value', 'email')
			firstName: $form.form('get value', 'firstName')
			lastName: $form.form('get value', 'lastName')
			phoneNumber: $form.form('get value', 'phoneNumber')

		if $form.form('is valid')
			data.password = passwordConfirmation if passwordConfirmation.length > 0
			$('.update.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('PUT', "/supervisors/#{@chosenSupervisor.id()}", data, (error, success, headers) =>
					$('.update.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the update of the supervisor.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						$('.update.modal').modal('hide')
						@fetchSupervisors()
				)

	deleteSupervisor: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/supervisors/#{@chosenSupervisor.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@currentSupervisors.remove( (supervisor) =>
						return supervisor.id is @chosenSupervisor.id()
					)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')
		)

	showUpdate: (supervisor) =>
		@chosenSupervisor.id(supervisor.id)
		$('.update.modal form')
			.form('set values',
					email						: supervisor.email
					firstName				: supervisor.firstName
					lastName				: supervisor.lastName
					address					:	supervisor.address
					phoneNumber			: supervisor.phoneNumber
				)
		$('.update.modal').modal('show')

	showDelete: (supervisor) =>
		@chosenSupervisor.id(supervisor.id)
		@chosenSupervisor.name(supervisor.firstName+' '+supervisor.lastName)
		$('.delete.modal').modal('show')

	setPrevSupervisorPage: ->
		if @supervisorsPages.activePage is 1
			nextPage = @supervisorsPages.allPages.length - 1
		else
			nextPage = @supervisorsPages.activePage - 1

		@fetchSupervisorsPage({num: nextPage})

	setNextSupervisorPage: ->
		if @supervisorsPages.activePage is @supervisorsPages.allPages.length - 1
			nextPage = 1
		else
			nextPage = @supervisorsPages.activePage + 1

		@fetchSupervisorsPage({num: nextPage})

	fetchSupervisorsPage: (page) =>
		@supervisorsPages.activePage = page.num
		@setPaginationItemsToShow(@supervisorsPages, 'table.supervisors')
		@fetchSupervisors(page.num)

	fetchSupervisors: (numPage = 1) ->
		@isLoading(true)
		data =
			page : numPage
			per_page : 30

		RESTfulService.makeRequest('GET', "/supervisors", data, (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the supervisors!'
				@shouldShowSupervisorsAlert(true)
				@supervisorsAlertText('Hubo un problema buscando la información de los supervisors')
			else
				console.log success
				if success.length > 0
					if @supervisorsPages.allPages.length is 0
						totalPages = Math.ceil(headers.totalItems/30)
						for i in [0..totalPages]
							@supervisorsPages.allPages.push({num: i+1})

						@supervisorsPages.activePage = 1
						@supervisorsPages.lowerLimit = 0
						@supervisorsPages.upperLimit = if totalPages < 10 then totalPages else 10
						@supervisorsPages.showablePages(@supervisorsPages.allPages.slice(@supervisorsPages.lowerLimit, @supervisorsPages.upperLimit))

						$("table.supervisors .pagination .pages .item:first-of-type").addClass('active')
					@currentSupervisors(success)
					@shouldShowSupervisorsAlert(false)
				else
					@shouldShowSupervisorsAlert(true)
					@supervisorsAlertText('No hay supervisores')

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
						password:
							identifier: 'password'
							rules: [
								emptyRule, {
									type: 'minLength[6]'
									prompt: 'La contraseña debe tener 6 caracteres mínimo'
								}
							]
						confirmationPassword:
							identifier: 'confirmationPassword'
							rules: [
								emptyRule, {
									type: 'match[password]'
									prompt: 'Las contraseñas no coinciden'
								}
							]
						passwordUpdate:
							identifier: 'passwordUpdate'
							rules: []
						confirmationPasswordUpdate:
							identifier: 'confirmationPasswordUpdate'
							rules: [
								{
									type: 'match[passwordUpdate]'
									prompt: 'Las contraseñas no coinciden'
								}
							]
						email:
							identifier: 'email'
							rules: [
								emptyRule, {
									type: 'email'
									prompt: 'Ingrese un email válido'
								}
							]
					inline: true
					keyboardShortcuts: false
				})

	setDOMProperties: ->
		$('.ui.modal')
			.modal(
					onHidden: ->
						$('.ui.modal form').form('clear') # Clears form when the modal is hidding
				)

		$('.ui.modal .dropdown')
			.dropdown()

supervisors = new SupervisorsVM
ko.applyBindings(supervisors)
